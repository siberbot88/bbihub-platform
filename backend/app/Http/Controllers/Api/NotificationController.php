<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    /**
     * Get list of notifications
     * 
     * GET /api/v1/notifications
     */
    public function index(Request $request)
    {
        $user = Auth::user();

        $notifications = $user->notifications()
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $notifications,
        ]);
    }

    /**
     * Get count of unread notifications
     * 
     * GET /api/v1/notifications/unread-count
     */
    public function unreadCount(Request $request)
    {
        $user = Auth::user();

        $count = $user->unreadNotifications()->count();

        return response()->json([
            'success' => true,
            'data' => [
                'count' => $count
            ]
        ]);
    }

    /**
     * Mark notification(s) as read
     * 
     * POST /api/v1/notifications/mark-read
     * Body: { "id": "uuid" } or { "id": "all" }
     */
    public function markRead(Request $request)
    {
        $request->validate([
            'id' => 'required' // 'all' or UUID
        ]);

        $user = Auth::user();
        $id = $request->input('id');

        if ($id === 'all') {
            $user->unreadNotifications->markAsRead();
            $message = 'All notifications marked as read';
        } else {
            $notification = $user->notifications()->find($id);
            if ($notification) {
                $notification->markAsRead();
                $message = 'Notification marked as read';
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Notification not found'
                ], 404);
            }
        }

        return response()->json([
            'success' => true,
            'message' => $message,
            'unread_count' => $user->unreadNotifications()->count()
        ]);
    }
}
