<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PromoClaim;
use App\Models\UserVoucher;
use App\Models\Voucher;
use App\Models\VoucherPack;
use App\Services\VoucherService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/** Voucher, paket voucher, dan promo (VoucherStore). */
class VoucherController extends Controller
{
    public function __construct(private VoucherService $vouchers) {}

    /** GET /api/vouchers — voucher milik pengguna. */
    public function index(Request $request): JsonResponse
    {
        $vouchers = $request->user()->userVouchers()
            ->with('voucher')
            ->orderByDesc('id')
            ->get()
            ->map(fn (UserVoucher $v) => $v->toApi());

        return response()->json(['data' => $vouchers]);
    }

    /** GET /api/vouchers/catalog — voucher contoh yang bisa langsung dipakai. */
    public function catalog(): JsonResponse
    {
        $vouchers = Voucher::where('is_active', true)
            ->where('code', 'not like', 'pack-%')
            ->get()
            ->map(fn (Voucher $v) => $v->toApi());

        return response()->json(['data' => $vouchers]);
    }

    /** POST /api/vouchers/validate */
    public function validateCode(Request $request): JsonResponse
    {
        $data = $request->validate([
            'code' => ['required', 'string', 'max:40'],
            'subtotal' => ['sometimes', 'integer', 'min:0'],
        ]);

        try {
            $result = $this->vouchers->resolve(
                $request->user(),
                $data['code'],
                (int) ($data['subtotal'] ?? 0),
            );
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'message' => 'Voucher bisa dipakai.',
            'data' => $result['voucher']->toApi() + [
                'discount' => $result['discount'],
                'is_applicable' => $result['voucher']->isApplicable((int) ($data['subtotal'] ?? 0)),
            ],
        ]);
    }

    /** GET /api/voucher-packs */
    public function packs(): JsonResponse
    {
        $packs = VoucherPack::where('is_active', true)
            ->orderBy('sort_order')
            ->get()
            ->map(fn (VoucherPack $p) => $p->toApi());

        return response()->json(['data' => $packs]);
    }

    /**
     * POST /api/voucher-packs/{voucherPack}/buy
     *
     * Membeli paket: seluruh voucher di dalamnya langsung masuk ke akun.
     */
    public function buyPack(Request $request, string $voucherPack): JsonResponse
    {
        $pack = VoucherPack::with('vouchers')->findOrFail($voucherPack);

        $created = [];

        foreach ($pack->vouchers as $voucher) {
            $quantity = max(1, (int) $voucher->pivot->quantity);

            for ($i = 0; $i < $quantity; $i++) {
                $created[] = UserVoucher::create([
                    'user_id' => $request->user()->id,
                    'voucher_id' => $voucher->id,
                    'code' => $voucher->code,
                    'status' => 'available',
                    'claimed_at' => now(),
                ])->load('voucher')->toApi();
            }
        }

        return response()->json([
            'message' => "Paket {$pack->title} berhasil dibeli.",
            'data' => [
                'pack' => $pack->toApi(),
                'vouchers' => $created,
            ],
        ]);
    }

    /** GET /api/promos — label promo yang sudah diklaim. */
    public function promos(Request $request): JsonResponse
    {
        if ($request->user() === null) {
            return response()->json(['data' => ['claimed' => []]]);
        }

        $claimed = $request->user()->promoClaims()->pluck('label')->all();

        return response()->json(['data' => ['claimed' => $claimed]]);
    }

    /** POST /api/promos/claim */
    public function claimPromo(Request $request): JsonResponse
    {
        $data = $request->validate([
            'label' => ['required', 'string', 'max:80'],
        ]);

        $claim = PromoClaim::firstOrCreate(
            ['user_id' => $request->user()->id, 'label' => $data['label']],
            ['claimed_at' => now()],
        );

        return response()->json([
            'message' => 'Promo berhasil diklaim.',
            'data' => ['label' => $claim->label, 'claimed_at' => $claim->claimed_at?->toIso8601String()],
        ]);
    }
}
