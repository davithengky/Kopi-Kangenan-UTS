<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

/** Profil pengguna: nama, identifier, dan password (DataDiriScreen). */
class ProfileController extends Controller
{
    /** GET /api/profile */
    public function show(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'data' => [
                'user' => $user->toApi(),
                'settings' => $user->settings()->first()?->toApi(),
                'membership' => $user->membership()->first()?->toApi(),
            ],
        ]);
    }

    /** PUT /api/profile */
    public function update(Request $request): JsonResponse
    {
        $user = $request->user();

        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'identifier' => [
                'required', 'string', 'max:150',
                Rule::unique('users', 'identifier')->ignore($user->id),
            ],
        ]);

        $user->name = $data['name'];
        $user->identifier = $data['identifier'];
        $user->identifier_type = filter_var($data['identifier'], FILTER_VALIDATE_EMAIL) ? 'email' : 'phone';
        $user->save();

        return response()->json([
            'message' => 'Data berhasil disimpan.',
            'data' => ['user' => $user->toApi()],
        ]);
    }

    /** PUT /api/profile/password */
    public function updatePassword(Request $request): JsonResponse
    {
        $user = $request->user();

        $data = $request->validate([
            'current_password' => ['required', 'string'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
        ]);

        if ($user->provider === 'local' && ! Hash::check($data['current_password'], $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => 'Password lama tidak sesuai.',
            ]);
        }

        $user->password = $data['password'];
        $user->save();

        return response()->json(['message' => 'Password berhasil diperbarui.']);
    }
}
