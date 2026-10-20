<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BulkOrderRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/** Permintaan pesanan jumlah besar (BulkOrderScreen). */
class BulkOrderController extends Controller
{
    /** POST /api/bulk-orders */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'contact' => ['required', 'string', 'max:60'],
            'purpose' => ['required', 'string', 'max:120'],
            'estimated_cups' => ['required', 'integer', 'min:1'],
            'event_date' => ['sometimes', 'nullable', 'date'],
            'note' => ['sometimes', 'nullable', 'string', 'max:255'],
        ]);

        $bulk = BulkOrderRequest::create([
            'user_id' => $request->user()?->id,
            'name' => $data['name'],
            'contact' => $data['contact'],
            'purpose' => $data['purpose'],
            'estimated_cups' => $data['estimated_cups'],
            'event_date' => $data['event_date'] ?? null,
            'note' => $data['note'] ?? '',
            'status' => 'Baru',
        ]);

        return response()->json([
            'message' => 'Permintaan pesanan besar terkirim. Tim kami akan menghubungimu.',
            'data' => $bulk->toApi(),
        ], 201);
    }

    /** GET /api/bulk-orders */
    public function index(Request $request): JsonResponse
    {
        $items = BulkOrderRequest::where('user_id', $request->user()->id)
            ->orderByDesc('id')
            ->get()
            ->map(fn (BulkOrderRequest $b) => $b->toApi());

        return response()->json(['data' => $items]);
    }
}
