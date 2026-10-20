<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Address;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/** Alamat pengiriman tersimpan (AddressStore). */
class AddressController extends Controller
{
    /** GET /api/addresses */
    public function index(Request $request): JsonResponse
    {
        $addresses = $request->user()->addresses()
            ->orderByDesc('is_default')
            ->orderBy('id')
            ->get()
            ->map(fn (Address $a) => $a->toApi());

        return response()->json(['data' => $addresses]);
    }

    /** POST /api/addresses */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        $data = $this->validated($request);

        $isDefault = $data['is_default'] ?? false;

        if ($user->addresses()->count() === 0) {
            $isDefault = true;
        }

        if ($isDefault) {
            $user->addresses()->update(['is_default' => false]);
        }

        $address = $user->addresses()->create([
            'label' => $data['label'],
            'recipient' => $data['recipient'],
            'phone' => $data['phone'],
            'detail' => $data['detail'],
            'note' => $data['note'] ?? '',
            'is_default' => $isDefault,
        ]);

        return response()->json([
            'message' => 'Alamat berhasil disimpan.',
            'data' => $address->toApi(),
        ], 201);
    }

    /** PUT /api/addresses/{address} */
    public function update(Request $request, Address $address): JsonResponse
    {
        $this->authorizeOwner($request, $address);

        $data = $this->validated($request);

        if (! empty($data['is_default'])) {
            $request->user()->addresses()->update(['is_default' => false]);
        }

        $address->fill([
            'label' => $data['label'],
            'recipient' => $data['recipient'],
            'phone' => $data['phone'],
            'detail' => $data['detail'],
            'note' => $data['note'] ?? '',
            'is_default' => $data['is_default'] ?? $address->is_default,
        ])->save();

        return response()->json([
            'message' => 'Alamat berhasil diperbarui.',
            'data' => $address->fresh()->toApi(),
        ]);
    }

    /** DELETE /api/addresses/{address} */
    public function destroy(Request $request, Address $address): JsonResponse
    {
        $this->authorizeOwner($request, $address);

        $wasDefault = $address->is_default;
        $address->delete();

        if ($wasDefault) {
            $next = $request->user()->addresses()->orderBy('id')->first();
            $next?->update(['is_default' => true]);
        }

        return response()->json(['message' => 'Alamat dihapus.']);
    }

    /** PUT /api/addresses/{address}/default */
    public function setDefault(Request $request, Address $address): JsonResponse
    {
        $this->authorizeOwner($request, $address);

        $request->user()->addresses()->update(['is_default' => false]);
        $address->update(['is_default' => true]);

        return response()->json([
            'message' => 'Alamat utama diperbarui.',
            'data' => $address->fresh()->toApi(),
        ]);
    }

    private function validated(Request $request): array
    {
        return $request->validate([
            'label' => ['required', 'string', 'max:40'],
            'recipient' => ['required', 'string', 'max:100'],
            'phone' => ['required', 'string', 'max:30'],
            'detail' => ['required', 'string', 'max:255'],
            'note' => ['sometimes', 'nullable', 'string', 'max:255'],
            'is_default' => ['sometimes', 'boolean'],
        ]);
    }

    private function authorizeOwner(Request $request, Address $address): void
    {
        abort_unless($address->user_id === $request->user()->id, 404);
    }
}
