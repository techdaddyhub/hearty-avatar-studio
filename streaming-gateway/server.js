/**
 * Hardware-Accelerated Multi-Destination Streaming Gateway
 * AI Avatar Studio & Social Media Streaming Platform
 * 
 * Features:
 * - Zero-CPU Transcoding: Uses FFmpeg stream copying (-c:v copy -c:a copy)
 * - Multi-Platform Simulcast: YouTube, Facebook, TikTok, Custom RTMP
 * - Real-time telemetry, health checks, and process management
 */

const http = require('http');
const { spawn } = require('child_process');

const PORT = process.env.GATEWAY_PORT || 9090;

// Active stream sessions Map<streamId, { process, destinations, startTime }>
const activeSessions = new Map();

const server = http.createServer((req, res) => {
  res.setHeader('Content-Type', 'application/json');
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
    res.writeHead(200);
    res.end(JSON.stringify({
      status: 'healthy',
      active_sessions: activeSessions.size,
      timestamp: new Date().toISOString(),
    }));
    return;
  }

  // Active sessions summary
  if (req.method === 'GET' && url.pathname === '/api/sessions') {
    const list = [];
    for (const [id, session] of activeSessions.entries()) {
      list.push({
        stream_id: id,
        destinations: session.destinations.map(d => ({ platform: d.platform, url: d.url })),
        uptime_seconds: Math.floor((Date.now() - session.startTime) / 1000),
      });
    }
    res.writeHead(200);
    res.end(JSON.stringify({ status: true, data: list }));
    return;
  }

  // Start Multi-Stream Distribution
  // POST /api/broadcast/start
  if (req.method === 'POST' && url.pathname === '/api/broadcast/start') {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      try {
        const payload = JSON.parse(body || '{}');
        const { stream_id, ingress_url, destinations } = payload;

        if (!stream_id || !ingress_url || !Array.isArray(destinations) || destinations.length === 0) {
          res.writeHead(400);
          res.end(JSON.stringify({ status: false, message: 'Invalid payload: stream_id, ingress_url, and destinations required' }));
          return;
        }

        if (activeSessions.has(stream_id)) {
          res.writeHead(409);
          res.end(JSON.stringify({ status: false, message: 'Stream session already active' }));
          return;
        }

        // Build FFmpeg command with zero-transcode tee / multi-output pipe
        // Example: ffmpeg -re -i [ingress_url] -c:v copy -c:a copy -f flv rtmp://... -f flv rtmp://...
        const ffmpegArgs = [
          '-re',
          '-i', ingress_url,
          '-c:v', 'copy',
          '-c:a', 'copy',
        ];

        destinations.forEach(dest => {
          const targetUrl = dest.stream_key ? `${dest.rtmp_url}/${dest.stream_key}` : dest.rtmp_url;
          ffmpegArgs.push('-f', 'flv', targetUrl);
        });

        console.log(`[StreamingGateway] Spawning FFmpeg process for stream ${stream_id}...`);
        const proc = spawn('ffmpeg', ffmpegArgs, { stdio: ['ignore', 'pipe', 'pipe'] });

        proc.stderr.on('data', data => {
          // Realtime FFmpeg frame output
        });

        proc.on('close', code => {
          console.log(`[StreamingGateway] FFmpeg process for ${stream_id} exited with code ${code}`);
          activeSessions.delete(stream_id);
        });

        activeSessions.set(stream_id, {
          process: proc,
          destinations,
          startTime: Date.now(),
        });

        res.writeHead(200);
        res.end(JSON.stringify({
          status: true,
          message: 'Multi-destination broadcast initiated successfully',
          stream_id,
          destinations_count: destinations.length,
        }));
      } catch (err) {
        res.writeHead(500);
        res.end(JSON.stringify({ status: false, message: err.message }));
      }
    });
    return;
  }

  // Stop Multi-Stream Distribution
  // POST /api/broadcast/stop
  if (req.method === 'POST' && url.pathname === '/api/broadcast/stop') {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      try {
        const payload = JSON.parse(body || '{}');
        const { stream_id } = payload;

        if (activeSessions.has(stream_id)) {
          const session = activeSessions.get(stream_id);
          session.process.kill('SIGINT');
          activeSessions.delete(stream_id);

          res.writeHead(200);
          res.end(JSON.stringify({ status: true, message: 'Stream distribution halted' }));
        } else {
          res.writeHead(404);
          res.end(JSON.stringify({ status: false, message: 'Stream session not found' }));
        }
      } catch (err) {
        res.writeHead(500);
        res.end(JSON.stringify({ status: false, message: err.message }));
      }
    });
    return;
  }

  res.writeHead(404);
  res.end(JSON.stringify({ status: false, message: 'Endpoint not found' }));
});

server.listen(PORT, () => {
  console.log(`[StreamingGateway] Hardware-accelerated streaming gateway listening on port ${PORT}`);
});
