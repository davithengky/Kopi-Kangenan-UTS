<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\InboxMessage;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/** Kotak Masuk (InboxStore). */
class InboxController extends Controller
{
    /** GET /api/inbox */
    public function index(Request $request): JsonResponse
    {
        $messages = $request->user()->inboxMessages()
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->get();

        return response()->json([
            'data' => [
                'messages' => $messages->map(fn (InboxMessage $m) => $m->toApi())->all(),
                'unread_count' => $messages->whereNull('read_at')->count(),
            ],
        ]);
    }

    /** PUT /api/inbox/{inboxMessage}/read */
    public function read(Request $request, InboxMessage $inboxMessage): JsonResponse
    {
        $this->authorizeOwner($request, $inboxMessage);

        if ($inboxMessage->read_at === null) {
            $inboxMessage->read_at = now();
            $inboxMessage->save();
        }

        return response()->json([
            'message' => 'Pesan ditandai sudah dibaca.',
            'data' => $inboxMessage->fresh()->toApi(),
        ]);
    }

    /** PUT /api/inbox/read-all */
    public function readAll(Request $request): JsonResponse
    {
        $request->user()->inboxMessages()
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json(['message' => 'Semua pesan ditandai sudah dibaca.']);
    }

    private function authorizeOwner(Request $request, InboxMessage $message): void
    {
        abort_unless($message->user_id === $request->user()->id, 404);
    }
}
