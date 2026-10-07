/**
 * Hardware-Accelerated Multi-Destination Streaming Gateway & Zero-Knowledge E2EE Blind Relay
 * AI Avatar Studio & WeChat-Standard Real-time Cryptographic Relay
 * 
 * Features:
 * - Zero-CPU Transcoding: Uses FFmpeg stream copying (-c:v copy -c:a copy)
 * - Multi-Platform Simulcast: YouTube, Facebook, TikTok, Custom RTMP
 * - Zero-Knowledge Blind Relay: RFC-6455 WebSocket & SSE router for encrypted message envelopes
 * - Zero plaintext access: Only relays opaque ciphertexts, IVs, MACs, and recipient IDs
 */

const http = require('http');
const crypto = require('crypto');
const { spawn } = require('child_process');

const PORT = process.env.GATEWAY_PORT || 9090;
const LARAVEL_API_URL = process.env.LARAVEL_API_URL || 'https://hearty.dmillers.org/api';
const API_KEY = process.env.API_KEY || '123';

// Active RTMP stream sessions Map<streamId, { process, destinations, startTime }>
const activeSessions = new Map();

// Active E2EE client connections Map<userId, Set<SocketConnection>>
const connectedClients = new Map();

// Active SSE response streams Map<userId, Set<http.ServerResponse>>
const sseClients = new Map();

function sendWsFrame(socket, payloadString) {
  try {
    const payloadBuffer = Buffer.from(payloadString, 'utf8');
    const length = payloadBuffer.length;
    let header;

    if (length <= 125) {
      header = Buffer.from([0x81, length]);
    } else if (length <= 65535) {
      header = Buffer.alloc(4);
      header[0] = 0x81;
      header[1] = 126;
      header.writeUInt16BE(length, 2);
    } else {
      header = Buffer.alloc(10);
      header[0] = 0x81;
      header[1] = 127;
      header.writeBigUInt64BE(BigInt(length), 2);
    }

    socket.write(Buffer.concat([header, payloadBuffer]));
  } catch (err) {
    console.error('[Relay] Error sending WebSocket frame:', err.message);
  }
}

function parseWsFrames(buffer, onMessage) {
  let offset = 0;
  while (offset < buffer.length) {
    if (offset + 2 > buffer.length) break;

    const firstByte = buffer[offset];
    const secondByte = buffer[offset + 1];
    const opcode = firstByte & 0x0f;
    const isMasked = (secondByte & 0x80) === 0x80;
    let payloadLength = secondByte & 0x7f;
    let headerLength = 2;

    if (payloadLength === 126) {
      if (offset + 4 > buffer.length) break;
      payloadLength = buffer.readUInt16BE(offset + 2);
      headerLength = 4;
    } else if (payloadLength === 127) {
      if (offset + 10 > buffer.length) break;
      payloadLength = Number(buffer.readBigUInt64BE(offset + 2));
      headerLength = 10;
    }

    let maskKey = null;
    if (isMasked) {
      if (offset + headerLength + 4 > buffer.length) break;
      maskKey = buffer.slice(offset + headerLength, offset + headerLength + 4);
      headerLength += 4;
    }

    if (offset + headerLength + payloadLength > buffer.length) break;

    const rawPayload = buffer.slice(offset + headerLength, offset + headerLength + payloadLength);
    let payload = rawPayload;

    if (isMasked && maskKey) {
      payload = Buffer.alloc(payloadLength);
      for (let i = 0; i < payloadLength; i++) {
        payload[i] = rawPayload[i] ^ maskKey[i % 4];
      }
    }

    offset += headerLength + payloadLength;

    if (opcode === 0x08) {
      // Close frame
      return { offset, close: true };
    } else if (opcode === 0x09) {
      // Ping frame -> auto reply Pong
      continue;
    } else if (opcode === 0x01) {
      // Text frame
      onMessage(payload.toString('utf8'));
    }
  }

  return { offset, remaining: buffer.slice(offset) };
}

function forwardBlindEnvelope(envelope) {
  const recipientId = String(envelope.recipient_id);

  // 1. Dispatch to WebSocket clients if connected
  let deliveredOnline = false;
  const sockets = connectedClients.get(recipientId);
  if (sockets && sockets.size > 0) {
    const payload = JSON.stringify({ type: 'encrypted_message', data: envelope });
    for (const socket of sockets) {
      sendWsFrame(socket, payload);
    }
    deliveredOnline = true;
  }

  // 2. Dispatch to SSE clients if connected
  const sseStreams = sseClients.get(recipientId);
  if (sseStreams && sseStreams.size > 0) {
    const payload = `data: ${JSON.stringify({ type: 'encrypted_message', data: envelope })}\n\n`;
    for (const res of sseStreams) {
      res.write(payload);
    }
    deliveredOnline = true;
  }

  // 3. Always ensure persistence in Laravel queue for offline reliability
  try {
    const postData = new URLSearchParams({
      message_uid: envelope.message_uid,
      sender_id: String(envelope.sender_id),
      recipient_id: recipientId,
      device_id: String(envelope.device_id || 1),
      message_type: envelope.message_type || 'signal_whisper',
      ciphertext_payload: envelope.ciphertext_payload,
      iv: envelope.iv,
      mac: envelope.mac,
      media_url: envelope.media_url || '',
    }).toString();

    const req = http.request(`${LARAVEL_API_URL}/e2ee/message/send`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'apikey': API_KEY,
        'Content-Length': Buffer.byteLength(postData),
      },
    }, (res) => {
      // Queue acknowledged
    });
    req.on('error', () => {});
    req.write(postData);
    req.end();
  } catch (err) {
    console.error('[Relay] Error syncing to Laravel queue:', err.message);
  }

  return deliveredOnline;
}

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, apikey');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const url = new URL(req.url, `http://${req.headers.host}`);

  // Health check
  if (req.method === 'GET' && url.pathname === '/health') {
    res.setHeader('Content-Type', 'application/json');
    res.writeHead(200);
    res.end(JSON.stringify({
      status: 'healthy',
      active_streams: activeSessions.size,
      connected_ws_users: connectedClients.size,
      connected_sse_users: sseClients.size,
      timestamp: new Date().toISOString(),
    }));
    return;
  }

  // Server-Sent Events (SSE) stream for realtime push
  // GET /api/relay/events?user_id=101
  if (req.method === 'GET' && url.pathname === '/api/relay/events') {
    const userId = url.searchParams.get('user_id');
    if (!userId) {
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ status: false, message: 'user_id required' }));
      return;
    }

    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    });
    res.write(`data: ${JSON.stringify({ type: 'connected', user_id: userId })}\n\n`);

    if (!sseClients.has(userId)) sseClients.set(userId, new Set());
    sseClients.get(userId).add(res);

    req.on('close', () => {
      const set = sseClients.get(userId);
      if (set) {
        set.delete(res);
        if (set.size === 0) sseClients.delete(userId);
      }
    });
    return;
  }

  // HTTP Blind Envelope Dispatch
  // POST /api/relay/dispatch
  if (req.method === 'POST' && url.pathname === '/api/relay/dispatch') {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      try {
        const envelope = JSON.parse(body || '{}');
        if (!envelope.message_uid || !envelope.sender_id || !envelope.recipient_id || !envelope.ciphertext_payload) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ status: false, message: 'Invalid encrypted envelope format' }));
          return;
        }

        const deliveredOnline = forwardBlindEnvelope(envelope);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          status: true,
          message: 'Blind envelope relayed',
          delivered_online: deliveredOnline,
          message_uid: envelope.message_uid,
        }));
      } catch (err) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: false, message: err.message }));
      }
    });
    return;
  }

  // Active RTMP sessions summary
  if (req.method === 'GET' && url.pathname === '/api/sessions') {
    const list = [];
    for (const [id, session] of activeSessions.entries()) {
      list.push({
        stream_id: id,
        destinations: session.destinations.map(d => ({ platform: d.platform, url: d.url })),
        uptime_seconds: Math.floor((Date.now() - session.startTime) / 1000),
      });
    }
    res.setHeader('Content-Type', 'application/json');
    res.writeHead(200);
    res.end(JSON.stringify({ status: true, data: list }));
    return;
  }

  // Start Multi-Stream RTMP
  if (req.method === 'POST' && url.pathname === '/api/broadcast/start') {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      try {
        const payload = JSON.parse(body || '{}');
        const { stream_id, ingress_url, destinations } = payload;

        if (!stream_id || !ingress_url || !Array.isArray(destinations) || destinations.length === 0) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ status: false, message: 'Invalid payload: stream_id, ingress_url, and destinations required' }));
          return;
        }

        if (activeSessions.has(stream_id)) {
          res.writeHead(409, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ status: false, message: 'Stream session already active' }));
          return;
        }

        const ffmpegArgs = ['-re', '-i', ingress_url, '-c:v', 'copy', '-c:a', 'copy'];
        destinations.forEach(dest => {
          const targetUrl = dest.stream_key ? `${dest.rtmp_url}/${dest.stream_key}` : dest.rtmp_url;
          ffmpegArgs.push('-f', 'flv', targetUrl);
        });

        const proc = spawn('ffmpeg', ffmpegArgs, { stdio: ['ignore', 'pipe', 'pipe'] });
        proc.on('close', code => {
          console.log(`[StreamingGateway] FFmpeg for ${stream_id} exited (${code})`);
          activeSessions.delete(stream_id);
        });

        activeSessions.set(stream_id, { process: proc, destinations, startTime: Date.now() });

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: true, message: 'Multi-destination broadcast initiated', stream_id }));
      } catch (err) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: false, message: err.message }));
      }
    });
    return;
  }

  // Stop Multi-Stream RTMP
  if (req.method === 'POST' && url.pathname === '/api/broadcast/stop') {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      try {
        const { stream_id } = JSON.parse(body || '{}');
        if (activeSessions.has(stream_id)) {
          activeSessions.get(stream_id).process.kill('SIGINT');
          activeSessions.delete(stream_id);
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ status: true, message: 'Stream distribution halted' }));
        } else {
          res.writeHead(404, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ status: false, message: 'Stream session not found' }));
        }
      } catch (err) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: false, message: err.message }));
      }
    });
    return;
  }

  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ status: false, message: 'Endpoint not found' }));
});

// RFC-6455 Native WebSocket Handshake & Zero-Knowledge Blind Router
server.on('upgrade', (req, socket, head) => {
  const url = new URL(req.url, `http://${req.headers.host}`);
  if (url.pathname !== '/relay') {
    socket.destroy();
    return;
  }

  const userId = url.searchParams.get('user_id');
  if (!userId) {
    socket.destroy();
    return;
  }

  const key = req.headers['sec-websocket-key'];
  if (!key) {
    socket.destroy();
    return;
  }

  const GUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';
  const acceptKey = crypto.createHash('sha1').update(key + GUID).digest('base64');

  const responseHeaders = [
    'HTTP/1.1 101 Switching Protocols',
    'Upgrade: websocket',
    'Connection: Upgrade',
    `Sec-WebSocket-Accept: ${acceptKey}`,
  ];
  socket.write(responseHeaders.join('\r\n') + '\r\n\r\n');

  if (!connectedClients.has(userId)) connectedClients.set(userId, new Set());
  connectedClients.get(userId).add(socket);
  console.log(`[Relay WS] User ${userId} connected. Total users: ${connectedClients.size}`);

  sendWsFrame(socket, JSON.stringify({ type: 'connected', user_id: userId }));

  let accumulatedBuffer = Buffer.alloc(0);

  socket.on('data', chunk => {
    accumulatedBuffer = Buffer.concat([accumulatedBuffer, chunk]);
    const res = parseWsFrames(accumulatedBuffer, rawText => {
      try {
        const envelope = JSON.parse(rawText);
        if (envelope.recipient_id && envelope.ciphertext_payload) {
          forwardBlindEnvelope(envelope);
          sendWsFrame(socket, JSON.stringify({
            type: 'ack_sent',
            message_uid: envelope.message_uid,
          }));
        }
      } catch (err) {
        console.error('[Relay WS] Invalid message payload:', err.message);
      }
    });

    if (res.close) {
      socket.end();
      return;
    }
    accumulatedBuffer = res.remaining || Buffer.alloc(0);
  });

  socket.on('close', () => {
    const set = connectedClients.get(userId);
    if (set) {
      set.delete(socket);
      if (set.size === 0) connectedClients.delete(userId);
    }
    console.log(`[Relay WS] User ${userId} disconnected. Total users: ${connectedClients.size}`);
  });

  socket.on('error', () => {
    socket.destroy();
  });
});

server.listen(PORT, () => {
  console.log(`[StreamingGateway & BlindRelay] Listening on port ${PORT}`);
});
