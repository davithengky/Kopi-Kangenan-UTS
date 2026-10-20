<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\InboxMessage;
use App\Models\Membership;
use App\Models\User;
use App\Models\UserPaymentMethod;
use App\Models\UserSetting;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

/** Login, daftar, masuk dengan Google, dan keluar. */
class AuthController extends Controller
{
    /** POST /api/auth/register */
    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'identifier' => ['required', 'string', 'max:150', 'unique:users,identifier'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
        ]);

        $user = User::create([
            'name' => $data['name'],
            'identifier' => $data['identifier'],
            'identifier_type' => $this->identifierType($data['identifier']),
            'password' => $data['password'],
            'provider' => 'local',
        ]);

        $this->bootstrapNewUser($user);

        return $this->tokenResponse($user, 'Registrasi berhasil.', 201);
    }

    /** POST /api/auth/login */
    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'identifier' => ['required', 'string'],
            'password' => ['required', 'string'],
        ]);

        $user = User::where('identifier', $data['identifier'])->first();

        if ($user === null || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'identifier' => 'Email/nomor HP atau password salah.',
            ]);
        }

        return $this->tokenResponse($user, 'Berhasil masuk.');
    }

    /**
     * POST /api/auth/login/google
     *
     * Simulasi masuk dengan Google seperti di aplikasi: akun dibuat otomatis
     * bila belum ada.
     */
    public function google(Request $request): JsonResponse
    {
        $data = $request->validate([
            'identifier' => ['required', 'string', 'max:150'],
            'name' => ['sometimes', 'nullable', 'string', 'max:100'],
        ]);

        $user = User::where('identifier', $data['identifier'])->first();

        if ($user === null) {
            $user = User::create([
                'name' => $data['name'] ?? 'Pengguna Google',
                'identifier' => $data['identifier'],
                'identifier_type' => $this->identifierType($data['identifier']),
                'password' => Hash::make(str()->random(32)),
                'provider' => 'google',
            ]);

            $this->bootstrapNewUser($user);
        }

        return $this->tokenResponse($user, 'Berhasil masuk dengan Google.');
    }

    /** GET /api/auth/me */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();
        $this->bootstrapNewUser($user);

        return response()->json([
            'data' => [
                'user' => $user->toApi(),
                'membership' => $user->membership()->first()->toApi(),
                'settings' => $user->settings()->first()->toApi(),
            ],
        ]);
    }

    /** POST /api/auth/logout */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Berhasil keluar.']);
    }

    /** POST /api/auth/logout-all */
    public function logoutAll(Request $request): JsonResponse
    {
        $request->user()->tokens()->delete();

        return response()->json(['message' => 'Semua sesi diakhiri.']);
    }

    // --- Pembantu ---------------------------------------------------------

    /** Membuat data awal yang dibutuhkan setiap akun baru. */
    public function bootstrapNewUser(User $user): void
    {
        UserSetting::firstOrCreate(['user_id' => $user->id], [
            'language' => 'indonesia',
            'notif_promo' => true,
            'notif_pesanan' => true,
            'biometric' => false,
        ]);

        Membership::firstOrCreate(['user_id' => $user->id], [
            'points' => 0,
            'total_spent' => 0,
        ]);

        Cart::firstOrCreate(['user_id' => $user->id]);

        UserPaymentMethod::firstOrCreate(
            ['user_id' => $user->id, 'payment_method_id' => 'qris'],
            ['is_connected' => true, 'is_selected' => true],
        );

        if ($user->inboxMessages()->count() === 0) {
            InboxMessage::create([
                'user_id' => $user->id,
                'title' => 'Selamat datang di Kopi Kangenan!',
                'body' => 'Terima kasih sudah mengunduh aplikasi kami. Cek promo terbaru di Beranda, ya!',
                'kind' => 'Akun',
            ]);

            InboxMessage::create([
                'user_id' => $user->id,
                'title' => 'Voucher Buy 1 Get 1',
                'body' => 'Klaim voucher Buy 1 Get 1 sepuasnya sebelum 31 Okt 2026. Berlaku di semua outlet.',
                'kind' => 'Promo',
            ]);

            InboxMessage::create([
                'user_id' => $user->id,
                'title' => 'Pesananmu sudah siap',
                'body' => 'Pesanan #1002 sudah siap diambil di counter Tunjungan Plaza 3.',
                'kind' => 'Pesanan',
                'read_at' => now()->subDays(2),
            ]);
        }
    }

    private function identifierType(string $identifier): string
    {
        return filter_var($identifier, FILTER_VALIDATE_EMAIL) ? 'email' : 'phone';
    }

    private function tokenResponse(User $user, string $message, int $status = 200): JsonResponse
    {
        $this->bootstrapNewUser($user);

        return response()->json([
            'message' => $message,
            'data' => [
                'token' => $user->createToken('api')->plainTextToken,
                'user' => $user->toApi(),
                'membership' => $user->membership()->first()->toApi(),
                'settings' => $user->settings()->first()->toApi(),
            ],
        ], $status);
    }
}
