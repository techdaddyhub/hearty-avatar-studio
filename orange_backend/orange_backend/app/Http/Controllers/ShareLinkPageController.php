<?php

namespace App\Http\Controllers;

use App\Models\AppData;
use App\Models\Post;
use App\Models\PostContent;
use App\Models\Users;
use Illuminate\Http\Request;

class ShareLinkPageController extends Controller
{
    public function shareLinkPage(Request $request)
    {
        $shareLinkPage = $request->shareLinkPage;
        $decoded = base64_decode($shareLinkPage);

        $result = null;
        $type = null;
        $imageUrl = asset('asset/img/favicon.png'); // default fallback
        $title = null;
        $contentType = null;
        if (preg_match('/^post_(\d+)$/', $decoded, $matches)) {
            $itemId = (int) $matches[1];
            $result = Post::find($itemId);

            if (!$result) {
                abort(404, "Post not found");
            }
            $postContent = PostContent::where('post_id', $itemId)->get();
            if ($postContent->isNotEmpty()) {
                foreach ($postContent as $content) {
                    if ($content->content_type == 0) {
                        $imageUrl = env('image') . $content->content;
                        $contentType = 'image';
                        break;
                    } elseif ($content->content_type == 1) {
                        $imageUrl = env('image') . $content->thumbnail ?? asset('asset/img/favicon.png');
                        $contentType = 'video';
                        break;
                    } elseif ($content->content_type == 2) {
                        $imageUrl = asset('asset/img/favicon.png'); // no preview
                        $contentType = 'Audio';
                        break;
                    }
                }
            } else {
                $imageUrl = asset('asset/img/favicon.png');
                $contentType = 'text';
            }

            $type = 'Post';
            $title = $result->desc ?? 'Post';
        } else if (preg_match('/^user_(\d+)$/', $decoded, $matches)) {
            $itemId = (int) $matches[1];
            $result = Users::find($itemId);

            $imageUrl =  env('image') .  $result->images->first()?->image ?? asset('asset/img/favicon.png');

            $title = $result->full_name;
        } else {
            abort(404, "Invalid ID format");
        }

        $setting = AppData::first();

        return view('shareLinkPage', [
            "shareLinkPage" => $shareLinkPage,
            "decoded"       => $decoded,
            "type"          => $type,
            "data"          => $result,
            "setting"       => $setting,
            "imageUrl"      => $imageUrl,
            "title"         => $title,
            "contentType"   => $contentType,
        ]);
    }
}
