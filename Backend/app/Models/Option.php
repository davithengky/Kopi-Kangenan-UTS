<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/** Satu pilihan di dalam grup opsi, mis. `Large` dengan tambahan Rp4.000. */
class Option extends Model
{
    protected $table = 'options';

    public $timestamps = false;

    protected $fillable = ['option_group_id', 'name', 'extra_price', 'is_available', 'sort_order'];

    protected function casts(): array
    {
        return [
            'extra_price' => 'integer',
            'is_available' => 'boolean',
        ];
    }

    public function group(): BelongsTo
    {
        return $this->belongsTo(OptionGroup::class, 'option_group_id');
    }

    public function toApi(): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'extra_price' => $this->extra_price,
            'is_available' => $this->is_available,
        ];
    }
}
