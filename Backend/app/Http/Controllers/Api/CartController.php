<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\CartItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/** Keranjang belanja pengguna (CartStore). */
class CartController extends Controller
{
    /** GET /api/cart */
    public function show(Request $request): JsonResponse
    {
        $cart = $this->cartFor($request)->load('items');

        return response()->json(['data' => $cart->toApi()]);
    }

    /** POST /api/cart/items */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate($this->rules());

        $cart = $this->cartFor($request);

        // Perilaku CartStore.add: item selalu ditambahkan sebagai baris baru.
        $item = $cart->items()->create($this->attributes($data));

        return response()->json([
            'message' => 'Masuk ke keranjang.',
            'data' => $item->toApi(),
        ], 201);
    }

    /** PUT /api/cart/items/{cartItem} */
    public function update(Request $request, CartItem $cartItem): JsonResponse
    {
        $this->authorizeOwner($request, $cartItem);

        $data = $request->validate([
            'quantity' => ['required', 'integer', 'min:0'],
            'note' => ['sometimes', 'nullable', 'string', 'max:255'],
        ]);

        // Perilaku CartStore.updateQuantity: jumlah 0 menghapus item.
        if ($data['quantity'] <= 0) {
            $cartItem->delete();

            return response()->json(['message' => 'Item dihapus dari keranjang.']);
        }

        $cartItem->quantity = $data['quantity'];

        if (array_key_exists('note', $data)) {
            $cartItem->note = $data['note'] ?? '';
        }

        $cartItem->save();

        return response()->json([
            'message' => 'Jumlah diperbarui.',
            'data' => $cartItem->toApi(),
        ]);
    }

    /** DELETE /api/cart/items/{cartItem} */
    public function destroy(Request $request, CartItem $cartItem): JsonResponse
    {
        $this->authorizeOwner($request, $cartItem);
        $cartItem->delete();

        return response()->json(['message' => 'Item dihapus dari keranjang.']);
    }

    /** DELETE /api/cart */
    public function clear(Request $request): JsonResponse
    {
        $this->cartFor($request)->items()->delete();

        return response()->json(['message' => 'Keranjang dikosongkan.']);
    }

    // --- Pembantu ---------------------------------------------------------

    private function cartFor(Request $request): Cart
    {
        return Cart::firstOrCreate(['user_id' => $request->user()->id]);
    }

    private function rules(): array
    {
        return [
            'product_id' => ['sometimes', 'nullable', 'integer', 'exists:products,id'],
            'name' => ['required', 'string', 'max:150'],
            'image' => ['sometimes', 'nullable', 'string', 'max:255'],
            'base_price' => ['required', 'integer', 'min:0'],
            'unit_price' => ['required', 'integer', 'min:0'],
            'quantity' => ['required', 'integer', 'min:1'],
            'size' => ['sometimes', 'nullable', 'string', 'max:40'],
            'milk' => ['sometimes', 'nullable', 'string', 'max:40'],
            'sugar' => ['sometimes', 'nullable', 'string', 'max:40'],
            'ice' => ['sometimes', 'nullable', 'string', 'max:40'],
            'toppings' => ['sometimes', 'array'],
            'toppings.*' => ['string', 'max:80'],
            'syrups' => ['sometimes', 'array'],
            'syrups.*' => ['string', 'max:80'],
            'note' => ['sometimes', 'nullable', 'string', 'max:255'],
        ];
    }

    private function attributes(array $data): array
    {
        return [
            'product_id' => $data['product_id'] ?? null,
            'name' => $data['name'],
            'image_path' => $data['image'] ?? '',
            'base_price' => $data['base_price'],
            'unit_price' => $data['unit_price'],
            'quantity' => $data['quantity'],
            'size' => $data['size'] ?? 'Regular',
            'milk' => $data['milk'] ?? 'Milk',
            'sugar' => $data['sugar'] ?? 'Normal Sugar',
            'ice' => $data['ice'] ?? 'Normal Ice',
            'toppings' => $data['toppings'] ?? [],
            'syrups' => $data['syrups'] ?? [],
            'note' => $data['note'] ?? '',
        ];
    }

    private function authorizeOwner(Request $request, CartItem $cartItem): void
    {
        abort_unless(
            $cartItem->cart()->where('user_id', $request->user()->id)->exists(),
            404,
        );
    }
}
