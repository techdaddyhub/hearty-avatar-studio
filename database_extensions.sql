-- =============================================================================
-- AVATAR STUDIO & SOCIAL STREAMING EXTENSION SCHEMA
-- Project: AI Avatar Studio + Social Media Streaming Platform
-- Target Database: MySQL 8.x / MariaDB
-- Linked to existing 'users' table
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------------------------
-- 1. Table: avatars
-- Stores 2D, 3D (GLTF/GLB/VRM), AI Photo Puppeteer, and custom user avatars.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `avatars` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `type` ENUM('2d', '3d', 'ai_photo', 'vrm', 'preset') NOT NULL DEFAULT '2d',
  `thumbnail_url` TEXT NULL,
  `model_url` TEXT NULL COMMENT 'File path or URL to GLB, VRM, sprite sheet, or AI base image',
  `config_json` LONGTEXT NULL COMMENT 'Blend shape mappings, viseme tuning, physics elasticity, bone rigs',
  `is_default` TINYINT(1) NOT NULL DEFAULT '0',
  `is_active` TINYINT(1) NOT NULL DEFAULT '1',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_avatars_user_id` (`user_id`),
  INDEX `idx_avatars_type` (`type`),
  CONSTRAINT `fk_avatars_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 2. Table: avatar_assets
-- Binary asset attachments (textures, viseme audio maps, animations, materials)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `avatar_assets` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `avatar_id` INT NOT NULL,
  `asset_type` VARCHAR(50) NOT NULL COMMENT 'mesh, texture, viseme_map, animation, material, landmark_weights',
  `file_path` TEXT NOT NULL,
  `file_size` BIGINT UNSIGNED NOT NULL DEFAULT '0',
  `mime_type` VARCHAR(100) NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_avatar_assets_avatar_id` (`avatar_id`),
  CONSTRAINT `fk_avatar_assets_avatar_id` FOREIGN KEY (`avatar_id`) REFERENCES `avatars` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 3. Table: rooms
-- WebRTC SFU / LiveKit room identifiers & management
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `rooms` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `room_name` VARCHAR(128) NOT NULL UNIQUE,
  `title` VARCHAR(255) NULL,
  `created_by` INT NOT NULL,
  `provider` VARCHAR(50) NOT NULL DEFAULT 'livekit',
  `max_participants` INT NOT NULL DEFAULT '50',
  `is_active` TINYINT(1) NOT NULL DEFAULT '1',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_rooms_created_by` (`created_by`),
  CONSTRAINT `fk_rooms_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 4. Table: calls
-- 1-to-1 and Group video calling sessions
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `calls` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `call_uuid` VARCHAR(64) NOT NULL UNIQUE,
  `caller_id` INT NOT NULL,
  `call_type` ENUM('one_to_one', 'group') NOT NULL DEFAULT 'one_to_one',
  `room_id` VARCHAR(128) NOT NULL,
  `status` ENUM('ringing', 'accepted', 'rejected', 'missed', 'active', 'ended', 'failed') NOT NULL DEFAULT 'ringing',
  `started_at` TIMESTAMP NULL DEFAULT NULL,
  `ended_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_calls_caller_id` (`caller_id`),
  INDEX `idx_calls_room_id` (`room_id`),
  INDEX `idx_calls_status` (`status`),
  CONSTRAINT `fk_calls_caller_id` FOREIGN KEY (`caller_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 5. Table: call_participants
-- Participants in a video call with avatar mode telemetry
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `call_participants` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `call_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `role` ENUM('host', 'guest') NOT NULL DEFAULT 'guest',
  `status` ENUM('ringing', 'accepted', 'rejected', 'active', 'left') NOT NULL DEFAULT 'ringing',
  `avatar_mode` TINYINT(1) NOT NULL DEFAULT '1',
  `avatar_id` INT NULL,
  `joined_at` TIMESTAMP NULL DEFAULT NULL,
  `left_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_cp_call_id` (`call_id`),
  INDEX `idx_cp_user_id` (`user_id`),
  CONSTRAINT `fk_cp_call_id` FOREIGN KEY (`call_id`) REFERENCES `calls` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cp_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cp_avatar_id` FOREIGN KEY (`avatar_id`) REFERENCES `avatars` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 6. Table: streams
-- Multi-platform live streaming broadcast sessions
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `streams` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `stream_uuid` VARCHAR(64) NOT NULL UNIQUE,
  `user_id` INT NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT NULL,
  `avatar_id` INT NULL,
  `status` ENUM('idle', 'live', 'ended') NOT NULL DEFAULT 'idle',
  `ingress_url` VARCHAR(255) NULL,
  `stream_key` VARCHAR(255) NULL,
  `viewer_count` INT NOT NULL DEFAULT '0',
  `peak_viewers` INT NOT NULL DEFAULT '0',
  `started_at` TIMESTAMP NULL DEFAULT NULL,
  `ended_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_streams_user_id` (`user_id`),
  INDEX `idx_streams_status` (`status`),
  CONSTRAINT `fk_streams_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_streams_avatar_id` FOREIGN KEY (`avatar_id`) REFERENCES `avatars` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 7. Table: stream_destinations
-- Simultaneous RTMP distribution targets (YouTube, Facebook, TikTok, Custom RTMP)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `stream_destinations` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `stream_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `platform` ENUM('youtube', 'facebook', 'tiktok', 'custom_rtmp') NOT NULL,
  `destination_name` VARCHAR(100) NOT NULL,
  `rtmp_url` TEXT NOT NULL,
  `stream_key_encrypted` TEXT NOT NULL COMMENT 'AES-256 encrypted stream key',
  `is_enabled` TINYINT(1) NOT NULL DEFAULT '1',
  `status` ENUM('idle', 'connecting', 'broadcasting', 'error') NOT NULL DEFAULT 'idle',
  `error_message` TEXT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_sd_stream_id` (`stream_id`),
  INDEX `idx_sd_user_id` (`user_id`),
  CONSTRAINT `fk_sd_stream_id` FOREIGN KEY (`stream_id`) REFERENCES `streams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sd_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 8. Table: social_accounts
-- Linked OAuth2 accounts with securely encrypted credentials
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `social_accounts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `platform` ENUM('youtube', 'facebook', 'tiktok', 'instagram') NOT NULL,
  `account_name` VARCHAR(255) NOT NULL,
  `account_id` VARCHAR(255) NULL,
  `channel_title` VARCHAR(255) NULL,
  `access_token_encrypted` TEXT NULL,
  `refresh_token_encrypted` TEXT NULL,
  `token_expires_at` TIMESTAMP NULL DEFAULT NULL,
  `is_connected` TINYINT(1) NOT NULL DEFAULT '1',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_platform` (`user_id`, `platform`, `account_id`),
  CONSTRAINT `fk_sa_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 9. Table: recordings
-- Recorded video calls and live studio sessions
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `recordings` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `session_type` ENUM('call', 'stream', 'studio') NOT NULL DEFAULT 'studio',
  `session_id` VARCHAR(128) NULL,
  `title` VARCHAR(255) NOT NULL,
  `file_path` TEXT NOT NULL,
  `file_size` BIGINT UNSIGNED NOT NULL DEFAULT '0',
  `duration_seconds` INT NOT NULL DEFAULT '0',
  `resolution` VARCHAR(50) NOT NULL DEFAULT '1080p',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_recordings_user_id` (`user_id`),
  CONSTRAINT `fk_recordings_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 10. Table: user_devices
-- Desktop (Windows, macOS, Linux) and mobile devices for VoIP pushes & syncing
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `user_devices` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `device_platform` ENUM('windows', 'macos', 'linux', 'android', 'ios') NOT NULL,
  `device_name` VARCHAR(255) NULL,
  `fcm_token` TEXT NULL,
  `last_active_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `is_active` TINYINT(1) NOT NULL DEFAULT '1',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_user_devices_user_id` (`user_id`),
  CONSTRAINT `fk_user_devices_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 11. Table: usage_metrics
-- Performance and telemetry logging (CPU, GPU, FPS, latency, packet loss)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `usage_metrics` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `device_platform` VARCHAR(30) NOT NULL,
  `cpu_usage` FLOAT NOT NULL DEFAULT '0',
  `gpu_usage` FLOAT NOT NULL DEFAULT '0',
  `fps` FLOAT NOT NULL DEFAULT '0',
  `latency_ms` FLOAT NOT NULL DEFAULT '0',
  `packet_loss` FLOAT NOT NULL DEFAULT '0',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_um_user_id` (`user_id`),
  CONSTRAINT `fk_um_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
