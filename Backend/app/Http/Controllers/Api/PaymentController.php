<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PaymentMethod;
use App\Models\UserPaymentMethod;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/** Metode pembayaran (PaymentStore). */
class PaymentController extends Controller
{
    /** GET /api/payment-methods */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $methods = PaymentMethod::where('is_active', true)
            ->orderBy('sort_order')
            ->get()
            ->map(function (PaymentMethod $method) use ($user) {
                $owned = $user?->userPaymentMethods()
                    ->where('payment_method_id', $method->id)
                    ->first();

                return $method->toApi() + [
                    'is_connected' => ! $method->needs_connection || (bool) ($owned->is_connected ?? false),
                    'is_selected' => (bool) ($owned->is_selected ?? false),
                ];
            });

        return response()->json(['data' => $methods]);
    }

    /** PUT /api/payment-methods/select */
    public function select(Request $request): JsonResponse
    {
        $data = $request->validate([
            'payment_method_id' => ['required', 'string', 'exists:payment_methods,id'],
        ]);

        $user = $request->user();
        $method = PaymentMethod::findOrFail($data['payment_method_id']);

        $owned = UserPaymentMethod::firstOrCreate(
            ['user_id' => $user->id, 'payment_method_id' => $method->id],
            ['is_connected' => false, 'is_selected' => false],
        );

        if (! $method->needs_connection || $owned->is_connected) {
            $user->userPaymentMethods()->update(['is_selected' => false]);
            $owned->is_selected = true;
            $owned->save();
        }

        return response()->json([
            'message' => 'Metode pembayaran dipilih.',
            'data' => $method->toApi() + [
                'is_connected' => ! $method->needs_connection || $owned->is_connected,
                'is_selected' => $owned->is_selected,
            ],
        ]);
    }

    /** POST /api/payment-methods/{paymentMethod}/connect */
    public function connect(Request $request, PaymentMethod $paymentMethod): JsonResponse
    {
        $user = $request->user();

        $owned = UserPaymentMethod::updateOrCreate(
            ['user_id' => $user->id, 'payment_method_id' => $paymentMethod->id],
            ['is_connected' => true],
        );

        return response()->json([
            'message' => "{$paymentMethod->name} berhasil dihubungkan.",
            'data' => $paymentMethod->toApi() + [
                'is_connected' => true,
                'is_selected' => $owned->is_selected,
            ],
        ]);
    }
}
