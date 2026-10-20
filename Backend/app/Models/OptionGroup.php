<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * Grup opsi kustomisasi produk (Temperature, Size, Milk Option, Sugar Level,
 * Ice Level, Topping, Syrup) — dari `product_detail_screen.dart`.
 */
class OptionGroup extends Model
{
    protected $table = 'option_groups';

    public $timestamps = false;

    protected $fillable = ['name', 'slug', 'type', 'is_required', 'max_select', 'sort_order'];

    protected function casts(): array
    {
        return [
            'is_required' => 'boolean',
            'max_select' => 'integer',
        ];
    }

    public function options(): HasMany
    {
        return $this->hasMany(Option::class)->orderBy('sort_order');
    }

    public function products(): BelongsToMany
    {
        return $this->belongsToMany(Product::class, 'product_option_group');
    }

    public function toApi(): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'type' => $this->type,
            'is_required' => $this->is_required,
            'max_select' => $this->max_select,
            'options' => $this->options->map(fn (Option $o) => $o->toApi())->all(),
        ];
    }
}
