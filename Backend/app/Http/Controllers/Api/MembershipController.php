<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\MemberService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/** Membership: level, poin, dan Daily Check-In (MemberStore). */
class MembershipController extends Controller
{
    public function __construct(private MemberService $members) {}

    /** GET /api/membership */
    public function show(Request $request): JsonResponse
    {
        return response()->json([
            'data' => $this->members->membershipFor($request->user())->toApi(),
        ]);
    }

    /** GET /api/points/history */
    public function history(Request $request): JsonResponse
    {
        $entries = $request->user()->pointEntries()
            ->orderByDesc('id')
            ->limit(100)
            ->get()
            ->map(fn ($e) => $e->toApi());

        return response()->json(['data' => $entries]);
    }

    /** GET /api/checkin/rewards — hadiah 6 hari (publik). */
    public function rewards(): JsonResponse
    {
        return response()->json([
            'data' => collect($this->members->allRewards())
                ->map(fn ($r) => $r->toApi())
                ->all(),
        ]);
    }

    /** GET /api/checkin — status check-in bulan ini. */
    public function status(Request $request): JsonResponse
    {
        $user = $request->user();
        $checked = $this->members->checkedDays($user);

        return response()->json([
            'data' => [
                'period' => $this->members->currentPeriod(),
                'checked_days' => $checked,
                'max_days' => MemberService::MAX_CHECK_IN_DAYS,
                'can_check_in' => count($checked) < MemberService::MAX_CHECK_IN_DAYS,
                'points' => $this->members->membershipFor($user)->points,
            ],
        ]);
    }

    /** POST /api/checkin */
    public function checkIn(Request $request): JsonResponse
    {
        try {
            $result = $this->members->checkIn($request->user());
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'message' => "Check-in hari ke-{$result['day']} berhasil: {$result['reward']}.",
            'data' => $result + [
                'membership' => $this->members->membershipFor($request->user())->fresh()->toApi(),
            ],
        ]);
    }
}
