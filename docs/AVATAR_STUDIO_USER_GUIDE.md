# AI Avatar Studio & Social Media Streaming Platform
## Comprehensive Operator & Developer User Guide

---

## 1. Architecture Overview & Product Vision

**AI Avatar Studio** transforms the existing production Orange social platform into a unified cross-platform workstation (Windows, macOS, Linux) and mobile companion client (Android, iOS).

```
   ┌────────────────────────────────────────────────────────┐
   │                  DESKTOP WORKSTATION                   │
   │               (Avatar Studio Application)              │
   ├────────────────────────────┬───────────────────────────┤
   │    Flutter Desktop UI      │  Native GPU Engine Bridge │
   │  - Studio Controls         │  - 3D VRM / 2.5D Sprites  │
   │  - OBS Controller (WS 5.x) │  - Viseme Audio Analyzer  │
   │  - Multi-Platform Streams  │  - Zero-Copy Virtual Cam  │
   │  - LiveKit WebRTC Client   │  - Hardware Encoders      │
   └─────────────┬──────────────┴─────────────┬─────────────┘
                 │                            │
                 ▼                            ▼
   ┌───────────────────────────┐┌───────────────────────────┐
   │    LARAVEL API & ADMIN    ││   STREAMING & MEDIA SFU   │
   │  - /api/v1/avatars        ││  - LiveKit SFU (Port 7880)│
   │  - /api/v1/calls          ││  - Redis Room State (6379)│
   │  - /api/v1/streams        ││  - Node.js Streaming GW   │
   │  - Admin Portal Blade     ││  - Hardware FFmpeg Fanout │
   └───────────────────────────┘└───────────────────────────┘
                 ▲                            ▲
                 │                            │
   ┌─────────────┴────────────────────────────┴─────────────┐
   │                  MOBILE COMPANION                      │
   │               (iOS & Android Clients)                  │
   ├────────────────────────────────────────────────────────┤
   │  - Existing Dating Discovery, Chat, Stories, Reels     │
   │  - Live Streaming (Agora RTC + LiveKit SFU)            │
   │  - Avatar Sheet & Real-Time Lip-Sync Movement          │
   └────────────────────────────────────────────────────────┘
```

---

## 2. Desktop Quickstart

### System Requirements
* **Operating Systems**: 
  * Windows 10/11 (64-bit)
  * macOS 12 Monterey or newer (Apple Silicon M1/M2/M3 or Intel)
  * Linux (Ubuntu 20.04+, Debian 11+, Fedora 38+, Arch Linux)
* **GPU**: Dedicated NVIDIA (GeForce GTX 1060+), AMD Radeon (RX 580+), Intel Iris Xe / Arc, or Apple Silicon Metal.
* **RAM**: 8 GB minimum (16 GB recommended for 4K streaming).

### Launching the Desktop Workstation
```bash
cd Orange_flutter/Orange
# Build or launch desktop runner
flutter run -d linux      # On Linux
flutter run -d windows    # On Windows
flutter run -d macos      # On macOS
```
Upon startup on desktop, the application detects the host OS and automatically mounts the **AvatarStudioDesktopApp** workstation.

---

## 3. Virtual Camera Output ("Avatar Studio Camera")

The application outputs real-time GPU-rendered avatar video frames directly into OS video device drivers, making your avatar accessible to any video software (Zoom, Microsoft Teams, Google Meet, Discord, OBS).

### Linux (v4l2loopback)
1. Install and load kernel module:
   ```bash
   sudo ./scripts/setup_virtual_camera_linux.sh
   ```
2. Verify loopback device `/dev/video10`:
   ```bash
   v4l2-ctl --device=/dev/video10 --all
   ```
3. In **Avatar Studio Desktop**, click **Virtual Camera -> Start Virtual Camera**.
4. Open Zoom / Google Meet -> Select camera: **Avatar Studio Camera**.

### Windows (DirectShow & MediaFoundation)
1. Run driver installation script:
   ```cmd
   scripts\setup_virtual_camera_windows.bat
   ```
2. In **Avatar Studio Desktop**, click **Virtual Camera -> Start Virtual Camera**.
3. DirectShow compatible apps will immediately recognize **"Avatar Studio Camera"**.

### macOS (CoreMediaIO DAL Plugin)
1. Run installer script:
   ```bash
   ./scripts/setup_virtual_camera_macos.sh
   ```
2. Grant camera permissions in System Preferences -> Security & Privacy -> Camera.
3. Applications like FaceTime, Teams, and WebRTC browsers will list **Avatar Studio Camera**.

---

## 4. OBS Studio 28+ Integration

### Connection via OBS WebSocket 5.x
1. Open **OBS Studio**.
2. Navigate to **Tools -> WebSocket Server Settings**.
3. Check **Enable WebSocket server**.
   * Server Port: `4455` (default)
   * Set or note your server password.
4. In **Avatar Studio Desktop**, open the **OBS STUDIO** section:
   * Host: `localhost`
   * Port: `4455`
   * Password: `[your_obs_password]`
   * Click **Connect to OBS**.
5. Once connected, you can directly:
   * Switch Scenes
   * Trigger **Start / Stop Streaming**
   * Trigger **Start / Stop Recording**
   * View live stream bitrate, dropped frames, and stream duration directly from the Avatar Studio dashboard.

### Adding Avatar Studio as an OBS Video Source

#### Option A: Direct Video Capture Device (Recommended - Zero Overhead)
1. In OBS Studio, under **Sources**, click `+` -> **Video Capture Device**.
2. Select **Avatar Studio Camera**.
3. Set Resolution/FPS Type: **Custom** -> Resolution: `1920x1080`, FPS: `60`.

#### Option B: Browser Source (Local WebGL Canvas)
1. In OBS Studio, under **Sources**, click `+` -> **Browser**.
2. URL: `http://localhost:3000/avatar`
3. Width: `1920`, Height: `1080`, FPS: `60`.
4. Check **Shutdown source when not visible**.

---

## 5. Multi-Platform Social Media Streaming

The platform provides multi-destination relay streaming without forcing your desktop PC to encode multiple independent video streams.

### Streaming Pipeline
```
[Avatar Studio GPU Render] 
          │ (Single Hardware Encoded RTMP/SRT Stream)
          ▼
[Streaming Gateway (Node.js + FFmpeg)]
          ├── Relay 1 ──► YouTube Live (RTMPS)
          ├── Relay 2 ──► Facebook Live (RTMPS)
          ├── Relay 3 ──► TikTok Live (RTMP)
          └── Relay 4 ──► Custom RTMP / CDN
```

### Adding Social Accounts & Destinations
1. Open **SOCIAL ACCOUNTS** section in Avatar Studio.
2. Connect accounts or enter RTMP stream credentials:
   * **YouTube**: `rtmp://a.rtmp.youtube.com/live2/[YOUR_STREAM_KEY]`
   * **Facebook Live**: `rtmps://live-api-s.facebook.com:443/rtmp/[YOUR_STREAM_KEY]`
   * **TikTok Live**: `rtmp://live-push.tiktok.com/live/[YOUR_STREAM_KEY]`
   * **Custom RTMP**: Any standard RTMP/RTMPS ingest URL.
3. Open **LIVE STREAM** section, click **Start Live Stream**.
4. The Streaming Gateway receives the master feed and broadcasts simultaneously to all enabled platforms with zero dropped frames.

---

## 6. Voice, Lip-Sync & Movement Synchronization

Avatar movement is driven by dual-stream analysis:

### 1. Voice Activity Detection (VAD) & Viseme Analysis
* The `VisemeAudioAnalyzer` samples audio input buffers every 50ms.
* Spectral energy bands are mapped into 6 key mouth visemes:
  * `sil`: Neutral / Silence
  * `aa`: Open vowel (Ah, Ha, Car)
  * `ee`: Spread vowel (See, Meet, Key)
  * `oo`: Rounded lip (Too, You, Go)
  * `ff`: Labiodental friction (For, Five)
  * `mm`: Bilabial closed (Me, My, Stop)
* Attack and decay smoothing filters eliminate jitter and artificial flapping.

### 2. Head & Kinematic Movement
* **Idle Breathing**: Continuous smooth sinusoidal chest and clavicle kinematics (`0.25 Hz`).
* **Eye Saccades & Blinking**: Natural micro-saccades (`1-3 Hz`) and probabilistic involuntary blinks every `2.5 - 4.5 seconds`.
* **Head Tracking / Manual Pose**: Pitch, Yaw, and Roll tracking driven by webcam input or manual cursor puppeteering.

---

## 7. Video Calling with Avatar Mode (LiveKit WebRTC SFU)

### 1-on-1 & Group Video Calling
1. User presses **Call** in Desktop or Mobile client.
2. The client invokes backend `POST /api/v1/calls/initiate`:
   * Generates a unique Room ID.
   * Creates LiveKit JWT credentials with Room Permissions (`canPublish: true`, `canSubscribe: true`).
   * Sends VoIP push notification to the recipient.
3. During call, toggle **Avatar Mode**:
   * The camera feed is replaced with the local GPU Avatar video track.
   * The remote participant receives the high-definition animated avatar in real-time.

---

## 8. Admin Portal Management

Administrators can manage avatars and monitor broadcast streams from the Laravel Admin Panel:

* **URL**: `http://localhost/admin/avatars`
  * View all system presets and user-created avatars.
  * Preview 3D VRM models, 2D sprites, and AI neural photographic assets.
  * Toggle active/inactive states.
  * Upload new global avatar presets.
* **URL**: `http://localhost/admin/streams`
  * Real-time table of all active live broadcasts.
  * Monitor host streamers, resolutions, bitrates, and active relay destinations.
  * Force-terminate malfunctioning or offending streams with one click.

---

## 9. Hardware Acceleration & Low CPU Optimization

| Component | Target Performance | Recommended Acceleration |
| :--- | :--- | :--- |
| **Idle Desktop App** | `< 5-8% CPU` | Native Flutter desktop event throttling |
| **Avatar 60 FPS Render** | `< 12-18% CPU` | OpenGL / Metal / DirectX hardware canvas painter |
| **Virtual Camera Push** | `< 2% CPU` | Zero-copy kernel memory mapping (`v4l2loopback` / DirectShow shared mem) |
| **Video Encoding** | `< 5% CPU` | NVIDIA NVENC / AMD AMF / Intel QSV / Apple VideoToolbox |

### Performance Verification Tool
Run the platform benchmark suite at any time:
```bash
./scripts/test_avatar_studio_platform.sh
```
All components will be checked for syntax, route registration, database integrity, and binary dependencies.
