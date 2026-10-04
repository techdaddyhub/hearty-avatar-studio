-- ==============================================================
-- Hearty & AI Avatar Studio: Default Admin & User Seed Accounts
-- ==============================================================

-- 1. Ensure Admin User Exists
INSERT INTO `admin_user` (`id`, `user_name`, `user_password`, `user_type`, `created_at`, `updated_at`)
VALUES (1, 'admin', 'admin@123!@#', 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE 
    `user_password` = 'admin@123!@#',
    `user_type` = 1,
    `updated_at` = NOW();

-- 2. Ensure Test User Exists
INSERT INTO `users` (
    `id`,
    `identity`,
    `username`,
    `fullname`,
    `gender`,
    `wallet`,
    `total_collected`,
    `can_go_live`,
    `is_verified`,
    `is_video_call`,
    `show_on_map`,
    `is_notification`,
    `is_block`,
    `is_fake`,
    `password`,
    `bio`,
    `created_at`,
    `updated_at`
)
VALUES (
    1,
    'hearty_tester@example.com',
    'hearty_demo',
    'Hearty Demo User',
    1,
    5000,
    5000,
    2,
    2,
    1,
    1,
    1,
    0,
    0,
    'password123',
    'Official Hearty Demo & Avatar Studio Tester',
    NOW(),
    NOW()
)
ON DUPLICATE KEY UPDATE
    `username` = 'hearty_demo',
    `fullname` = 'Hearty Demo User',
    `wallet` = 5000,
    `can_go_live` = 2,
    `is_verified` = 2,
    `password` = 'password123',
    `updated_at` = NOW();

-- 3. Ensure Default System Avatar is Assigned to Test User
INSERT INTO `avatars` (
    `id`,
    `user_id`,
    `name`,
    `type`,
    `gender`,
    `style`,
    `is_default`,
    `is_active`,
    `created_at`,
    `updated_at`
)
VALUES (
    1,
    1,
    'Cyber Idol Luna',
    '3d',
    'female',
    'anime',
    1,
    1,
    NOW(),
    NOW()
)
ON DUPLICATE KEY UPDATE
    `name` = 'Cyber Idol Luna',
    `is_default` = 1,
    `is_active` = 1,
    `updated_at` = NOW();
