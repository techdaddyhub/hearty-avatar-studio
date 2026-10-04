<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\Admin;
use App\Models\Users;
use App\Models\Avatar;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database with default Admin and User accounts.
     *
     * @return void
     */
    public function run()
    {
        // 1. Seed Admin Account
        Admin::updateOrCreate(
            ['id' => 1],
            [
                'user_name' => 'admin',
                'user_password' => 'admin@123!@#',
                'user_type' => 1,
            ]
        );

        // 2. Seed Test User Account
        Users::updateOrCreate(
            ['id' => 1],
            [
                'identity' => 'hearty_tester@example.com',
                'username' => 'hearty_demo',
                'fullname' => 'Hearty Demo User',
                'gender' => 1,
                'wallet' => 5000,
                'total_collected' => 5000,
                'can_go_live' => 2,
                'is_verified' => 2,
                'is_video_call' => 1,
                'show_on_map' => 1,
                'is_notification' => 1,
                'is_block' => 0,
                'is_fake' => 0,
                'password' => 'password123',
                'bio' => 'Official Hearty Demo & Avatar Studio Tester',
            ]
        );

        // 3. Seed Default System Avatar
        Avatar::updateOrCreate(
            ['id' => 1],
            [
                'user_id' => 1,
                'name' => 'Cyber Idol Luna',
                'type' => '3d',
                'gender' => 'female',
                'style' => 'anime',
                'is_default' => true,
                'is_active' => true,
            ]
        );
    }
}
