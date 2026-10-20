<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

/** Preferensi aplikasi (SettingsStore). */
class SettingsController extends Controller
{
    /** GET /api/settings */
    public function show(Request $request): JsonResponse
    {
        return response()->json(['data' => $request->user()->settings()->first()?->toApi()]);
    }

    /** PUT /api/settings */
    public function update(Request $request): JsonResponse
    {
        $data = $request->validate([
            'language' => ['sometimes', Rule::in(['indonesia', 'english'])],
            'notif_promo' => ['sometimes', 'boolean'],
            'notif_pesanan' => ['sometimes', 'boolean'],
            'biometric' => ['sometimes', 'boolean'],
        ]);

        $settings = $request->user()->settings()->firstOrFail();
        $settings->fill($data)->save();

        return response()->json([
            'message' => 'Pengaturan disimpan.',
            'data' => $settings->fresh()->toApi(),
        ]);
    }
}
