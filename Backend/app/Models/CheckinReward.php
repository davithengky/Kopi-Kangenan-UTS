<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/** Hadiah Daily Check-In untuk tiap hari (MemberStore.dailyRewards). */
class CheckinReward extends Model
{
    protected $table = 'checkin_rewards';

    public $timestamps = false;

    protected $fillable = ['day_number', 'reward_label', 'reward_type', 'reward_value'];

    protected function casts(): array
    {
        return [
            'day_number' => 'integer',
            'reward_value' => 'integer',
        ];
    }

    public function toApi(): array
    {
        return [
            'day' => $this->day_number,
            'reward' => $this->reward_label,
            'type' => $this->reward_type,
            'value' => $this->reward_value,
        ];
    }
}
