<?php

namespace App\Http\Controllers;

use App\Models\Contact;
use App\Models\ContactRequest;
use App\Models\Users;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ContactsController extends Controller
{
    public function getContacts(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|integer',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => false, 'message' => $validator->errors()->first()]);
        }

        $userId = (int) $request->user_id;

        $contacts = Contact::where('user_id', $userId)
            ->where('is_blocked', 0)
            ->with(['contactUser'])
            ->get()
            ->map(function ($c) {
                $user = $c->contactUser;
                return [
                    'id' => $c->id,
                    'contact_user_id' => $c->contact_user_id,
                    'remark' => $c->remark,
                    'display_name' => !empty($c->remark) ? $c->remark : ($user->fullname ?? $user->username ?? 'User'),
                    'username' => $user->username ?? '',
                    'identity' => $user->identity ?? '',
                    'avatar' => $user->images->first()->image ?? 'uploads/user_tester.png',
                    'is_starred' => (int) $c->is_starred,
                    'is_muted' => (int) $c->is_muted,
                    'source' => $c->source,
                ];
            });

        return response()->json([
            'status' => true,
            'message' => 'Contacts retrieved successfully',
            'count' => $contacts->count(),
            'data' => $contacts,
        ]);
    }

    public function searchUser(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'query' => 'required|string|min:1',
            'current_user_id' => 'required|integer',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => false, 'message' => $validator->errors()->first()]);
        }

        $query = trim($request->input('query'));
        $currentUserId = (int) $request->current_user_id;

        $users = Users::where('id', '!=', $currentUserId)
            ->where('is_block', 0)
            ->where(function ($q) use ($query) {
                $q->where('username', 'LIKE', "%{$query}%")
                    ->orWhere('identity', 'LIKE', "%{$query}%")
                    ->orWhere('fullname', 'LIKE', "%{$query}%")
                    ->orWhere('id', $query);
            })
            ->with('images')
            ->limit(20)
            ->get()
            ->map(function ($user) use ($currentUserId) {
                $isContact = Contact::where('user_id', $currentUserId)->where('contact_user_id', $user->id)->exists();
                $pendingRequest = ContactRequest::where('sender_id', $currentUserId)->where('recipient_id', $user->id)->where('status', 'pending')->exists();

                return [
                    'id' => $user->id,
                    'username' => $user->username,
                    'fullname' => $user->fullname,
                    'avatar' => $user->images->first()->image ?? 'uploads/user_tester.png',
                    'bio' => $user->bio,
                    'is_contact' => $isContact,
                    'has_pending_request' => $pendingRequest,
                ];
            });

        return response()->json([
            'status' => true,
            'message' => 'Users found',
            'data' => $users,
        ]);
    }

    public function sendContactRequest(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'sender_id' => 'required|integer',
            'recipient_id' => 'required|integer|different:sender_id',
            'greeting_message' => 'nullable|string|max:255',
            'source' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => false, 'message' => $validator->errors()->first()]);
        }

        $senderId = (int) $request->sender_id;
        $recipientId = (int) $request->recipient_id;

        // Check if already contacts
        $alreadyContacts = Contact::where('user_id', $senderId)->where('contact_user_id', $recipientId)->exists();
        if ($alreadyContacts) {
            return response()->json(['status' => true, 'message' => 'Already in your contacts list']);
        }

        $req = ContactRequest::updateOrCreate(
            ['sender_id' => $senderId, 'recipient_id' => $recipientId],
            [
                'greeting_message' => $request->greeting_message ?? "Hi! Let's connect on Hearty.",
                'status' => 'pending',
            ]
        );

        return response()->json([
            'status' => true,
            'message' => 'Contact request sent successfully',
            'data' => $req,
        ]);
    }

    public function getContactRequests(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|integer',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => false, 'message' => $validator->errors()->first()]);
        }

        $userId = (int) $request->user_id;

        $requests = ContactRequest::where('recipient_id', $userId)
            ->where('status', 'pending')
            ->with(['sender'])
            ->orderBy('id', 'desc')
            ->get()
            ->map(function ($r) {
                return [
                    'request_id' => $r->id,
                    'sender_id' => $r->sender_id,
                    'fullname' => $r->sender->fullname ?? $r->sender->username ?? 'User',
                    'username' => $r->sender->username ?? '',
                    'avatar' => $r->sender->images->first()->image ?? 'uploads/user_tester.png',
                    'greeting_message' => $r->greeting_message,
                    'created_at' => $r->created_at->toIso8601String(),
                ];
            });

        return response()->json([
            'status' => true,
            'message' => 'Contact requests retrieved',
            'data' => $requests,
        ]);
    }

    public function respondContactRequest(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'request_id' => 'required|integer',
            'action' => 'required|in:accept,reject',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => false, 'message' => $validator->errors()->first()]);
        }

        $req = ContactRequest::find($request->request_id);
        if (!$req) {
            return response()->json(['status' => false, 'message' => 'Request not found'], 404);
        }

        if ($request->action === 'accept') {
            DB::beginTransaction();
            try {
                $req->status = 'accepted';
                $req->save();

                // Create bilateral mutual contact entries
                Contact::firstOrCreate([
                    'user_id' => $req->sender_id,
                    'contact_user_id' => $req->recipient_id,
                ]);

                Contact::firstOrCreate([
                    'user_id' => $req->recipient_id,
                    'contact_user_id' => $req->sender_id,
                ]);

                DB::commit();

                return response()->json([
                    'status' => true,
                    'message' => 'Contact request accepted. You are now connected!',
                ]);
            } catch (\Exception $e) {
                DB::rollBack();
                return response()->json(['status' => false, 'message' => 'Error: ' . $e->getMessage()]);
            }
        } else {
            $req->status = 'rejected';
            $req->save();

            return response()->json(['status' => true, 'message' => 'Contact request declined']);
        }
    }

    public function updateRemark(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|integer',
            'contact_user_id' => 'required|integer',
            'remark' => 'nullable|string|max:191',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => false, 'message' => $validator->errors()->first()]);
        }

        Contact::where('user_id', (int) $request->user_id)
            ->where('contact_user_id', (int) $request->contact_user_id)
            ->update(['remark' => $request->remark]);

        return response()->json(['status' => true, 'message' => 'Contact remark updated']);
    }

    public function deleteContact(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|integer',
            'contact_user_id' => 'required|integer',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => false, 'message' => $validator->errors()->first()]);
        }

        Contact::where('user_id', (int) $request->user_id)
            ->where('contact_user_id', (int) $request->contact_user_id)
            ->delete();

        return response()->json(['status' => true, 'message' => 'Contact removed']);
    }
}
