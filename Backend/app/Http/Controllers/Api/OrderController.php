<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Services\OrderService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/** Pesanan: riwayat, pembuatan, dan perubahan status (OrderStore). */
class OrderController extends Controller
{
    public function __construct(private OrderService $orders) {}

    /** GET /api/orders */
    public function index(Request $request): JsonResponse
    {
        $orders = $request->user()->orders()
            ->with('items')
            ->orderByDesc('id')
            ->get()
            ->map(fn (Order $o) => $o->toApi());

        return response()->json(['data' => $orders]);
    }

    /** POST /api/orders */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'items' => ['required', 'array', 'min:1'],
            'items.*.name' => ['required', 'string', 'max:150'],
            'items.*.image' => ['sometimes', 'nullable', 'string', 'max:255'],
            'items.*.product_id' => ['sometimes', 'nullable', 'integer', 'exists:products,id'],
            'items.*.base_price' => ['required', 'integer', 'min:0'],
            'items.*.unit_price' => ['required', 'integer', 'min:0'],
            'items.*.quantity' => ['required', 'integer', 'min:1'],
            'items.*.size' => ['sometimes', 'nullable', 'string', 'max:40'],
            'items.*.milk' => ['sometimes', 'nullable', 'string', 'max:40'],
            'items.*.sugar' => ['sometimes', 'nullable', 'string', 'max:40'],
            'items.*.ice' => ['sometimes', 'nullable', 'string', 'max:40'],
            'items.*.toppings' => ['sometimes', 'array'],
            'items.*.syrups' => ['sometimes', 'array'],
            'items.*.note' => ['sometimes', 'nullable', 'string', 'max:255'],
            'outlet_id' => ['sometimes', 'nullable', 'integer', 'exists:outlets,id'],
            'bag_fee' => ['sometimes', 'integer', 'min:0'],
            'voucher_code' => ['sometimes', 'nullable', 'string', 'max:40'],
            'points_used' => ['sometimes', 'integer', 'min:0'],
            'payment_method_id' => ['sometimes', 'string', 'exists:payment_methods,id'],
            'fulfilment' => ['sometimes', 'in:Pickup,Delivery'],
            'scheduled_at' => ['sometimes', 'nullable', 'date'],
        ]);

        try {
            $order = $this->orders->create($request->user(), $data);
        } catch (\RuntimeException|\InvalidArgumentException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'message' => 'Pesanan berhasil dibuat.',
            'data' => $order->toApi(),
        ], 201);
    }

    /** GET /api/orders/{order} */
    public function show(Request $request, Order $order): JsonResponse
    {
        $this->authorizeOwner($request, $order);

        return response()->json(['data' => $order->load('items')->toApi()]);
    }

    /** PUT /api/orders/{order}/advance */
    public function advance(Request $request, Order $order): JsonResponse
    {
        $this->authorizeOwner($request, $order);

        $order = $this->orders->advance($order);

        return response()->json([
            'message' => 'Status pesanan diperbarui.',
            'data' => $order->load('items')->toApi(),
        ]);
    }

    /** PUT /api/orders/{order}/cancel */
    public function cancel(Request $request, Order $order): JsonResponse
    {
        $this->authorizeOwner($request, $order);

        try {
            $order = $this->orders->cancel($order);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'message' => 'Pesanan dibatalkan.',
            'data' => $order->load('items')->toApi(),
        ]);
    }

    private function authorizeOwner(Request $request, Order $order): void
    {
        abort_unless($order->user_id === $request->user()->id, 404);
    }
}
