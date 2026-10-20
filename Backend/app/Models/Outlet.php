<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/** Outlet tempat pesanan dibuat (Outlet / kOutlets). */
class Outlet extends Model
{
    protected $fillable = [
        'name',
        'address',
        'latitude',
        'longitude',
        'distance_label',
        'is_default',
        'is_active',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'latitude' => 'float',
            'longitude' => 'float',
            'is_default' => 'boolean',
            'is_active' => 'boolean',
        ];
    }

    public function toApi(): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'address' => $this->address,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'distance' => $this->distance_label,
            'is_default' => $this->is_default,
        ];
    }
}
