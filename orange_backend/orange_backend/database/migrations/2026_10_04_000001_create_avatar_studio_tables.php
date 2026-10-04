<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateAvatarStudioTables extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        // 1. avatars
        if (!Schema::hasTable('avatars')) {
            Schema::create('avatars', function (Blueprint $table) {
                $table->id();
                $table->integer('user_id');
                $table->string('name');
                $table->enum('type', ['2d', '3d', 'ai_photo', 'vrm', 'preset'])->default('2d');
                $table->text('thumbnail_url')->nullable();
                $table->text('model_url')->nullable();
                $table->longText('config_json')->nullable();
                $table->boolean('is_default')->default(false);
                $table->boolean('is_active')->default(true);
                $table->timestamps();

                $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            });
        }

        // 2. avatar_assets
        if (!Schema::hasTable('avatar_assets')) {
            Schema::create('avatar_assets', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('avatar_id');
                $table->string('asset_type', 50);
                $table->text('file_path');
                $table->unsignedBigInteger('file_size')->default(0);
                $table->string('mime_type', 100)->nullable();
                $table->timestamps();

                $table->foreign('avatar_id')->references('id')->on('avatars')->onDelete('cascade');
            });
        }

        // 3. rooms
        if (!Schema::hasTable('rooms')) {
            Schema::create('rooms', function (Blueprint $table) {
                $table->id();
                $table->string('room_name', 128)->unique();
                $table->string('title')->nullable();
                $table->integer('created_by');
                $table->string('provider', 50)->default('livekit');
                $table->integer('max_participants')->default(50);
                $table->boolean('is_active')->default(true);
                $table->timestamps();

                $table->foreign('created_by')->references('id')->on('users')->onDelete('cascade');
            });
        }

        // 4. calls
        if (!Schema::hasTable('calls')) {
            Schema::create('calls', function (Blueprint $table) {
                $table->id();
                $table->string('call_uuid', 64)->unique();
                $table->integer('caller_id');
                $table->enum('call_type', ['one_to_one', 'group'])->default('one_to_one');
                $table->string('room_id', 128);
                $table->enum('status', ['ringing', 'accepted', 'rejected', 'missed', 'active', 'ended', 'failed'])->default('ringing');
                $table->timestamp('started_at')->nullable();
                $table->timestamp('ended_at')->nullable();
                $table->timestamps();

                $table->foreign('caller_id')->references('id')->on('users')->onDelete('cascade');
            });
        }

        // 5. call_participants
        if (!Schema::hasTable('call_participants')) {
            Schema::create('call_participants', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('call_id');
                $table->integer('user_id');
                $table->enum('role', ['host', 'guest'])->default('guest');
                $table->enum('status', ['ringing', 'accepted', 'rejected', 'active', 'left'])->default('ringing');
                $table->boolean('avatar_mode')->default(true);
                $table->unsignedBigInteger('avatar_id')->nullable();
                $table->timestamp('joined_at')->nullable();
                $table->timestamp('left_at')->nullable();
                $table->timestamps();

                $table->foreign('call_id')->references('id')->on('calls')->onDelete('cascade');
                $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
                $table->foreign('avatar_id')->references('id')->on('avatars')->onDelete('set null');
            });
        }

        // 6. streams
        if (!Schema::hasTable('streams')) {
            Schema::create('streams', function (Blueprint $table) {
                $table->id();
                $table->string('stream_uuid', 64)->unique();
                $table->integer('user_id');
                $table->string('title');
                $table->text('description')->nullable();
                $table->unsignedBigInteger('avatar_id')->nullable();
                $table->enum('status', ['idle', 'live', 'ended'])->default('idle');
                $table->string('ingress_url')->nullable();
                $table->string('stream_key')->nullable();
                $table->integer('viewer_count')->default(0);
                $table->integer('peak_viewers')->default(0);
                $table->timestamp('started_at')->nullable();
                $table->timestamp('ended_at')->nullable();
                $table->timestamps();

                $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
                $table->foreign('avatar_id')->references('id')->on('avatars')->onDelete('set null');
            });
        }

        // 7. stream_destinations
        if (!Schema::hasTable('stream_destinations')) {
            Schema::create('stream_destinations', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('stream_id');
                $table->integer('user_id');
                $table->enum('platform', ['youtube', 'facebook', 'tiktok', 'custom_rtmp']);
                $table->string('destination_name', 100);
                $table->text('rtmp_url');
                $table->text('stream_key_encrypted');
                $table->boolean('is_enabled')->default(true);
                $table->enum('status', ['idle', 'connecting', 'broadcasting', 'error'])->default('idle');
                $table->text('error_message')->nullable();
                $table->timestamps();

                $table->foreign('stream_id')->references('id')->on('streams')->onDelete('cascade');
                $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            });
        }

        // 8. social_accounts
        if (!Schema::hasTable('social_accounts')) {
            Schema::create('social_accounts', function (Blueprint $table) {
                $table->id();
                $table->integer('user_id');
                $table->enum('platform', ['youtube', 'facebook', 'tiktok', 'instagram']);
                $table->string('account_name');
                $table->string('account_id')->nullable();
                $table->string('channel_title')->nullable();
                $table->text('access_token_encrypted')->nullable();
                $table->text('refresh_token_encrypted')->nullable();
                $table->timestamp('token_expires_at')->nullable();
                $table->boolean('is_connected')->default(true);
                $table->timestamps();

                $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            });
        }

        // 9. recordings
        if (!Schema::hasTable('recordings')) {
            Schema::create('recordings', function (Blueprint $table) {
                $table->id();
                $table->integer('user_id');
                $table->enum('session_type', ['call', 'stream', 'studio'])->default('studio');
                $table->string('session_id', 128)->nullable();
                $table->string('title');
                $table->text('file_path');
                $table->unsignedBigInteger('file_size')->default(0);
                $table->integer('duration_seconds')->default(0);
                $table->string('resolution', 50)->default('1080p');
                $table->timestamps();

                $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            });
        }

        // 10. user_devices
        if (!Schema::hasTable('user_devices')) {
            Schema::create('user_devices', function (Blueprint $table) {
                $table->id();
                $table->integer('user_id');
                $table->enum('device_platform', ['windows', 'macos', 'linux', 'android', 'ios']);
                $table->string('device_name')->nullable();
                $table->text('fcm_token')->nullable();
                $table->timestamp('last_active_at')->nullable();
                $table->boolean('is_active')->default(true);
                $table->timestamps();

                $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            });
        }

        // 11. usage_metrics
        if (!Schema::hasTable('usage_metrics')) {
            Schema::create('usage_metrics', function (Blueprint $table) {
                $table->id();
                $table->integer('user_id');
                $table->string('device_platform', 30);
                $table->float('cpu_usage')->default(0);
                $table->float('gpu_usage')->default(0);
                $table->float('fps')->default(0);
                $table->float('latency_ms')->default(0);
                $table->float('packet_loss')->default(0);
                $table->timestamps();

                $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            });
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('usage_metrics');
        Schema::dropIfExists('user_devices');
        Schema::dropIfExists('recordings');
        Schema::dropIfExists('social_accounts');
        Schema::dropIfExists('stream_destinations');
        Schema::dropIfExists('streams');
        Schema::dropIfExists('call_participants');
        Schema::dropIfExists('calls');
        Schema::dropIfExists('rooms');
        Schema::dropIfExists('avatar_assets');
        Schema::dropIfExists('avatars');
    }
}
