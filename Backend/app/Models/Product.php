<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

/**
 * Produk menu (`type = 'menu'`) atau merchandise (`type = 'merch'`).
 *
 * Satu produk boleh berada di banyak kategori, mis. "Taro Cloud Latte" ada di
 * kategori "Baru!" dan "Coffee" — lihat pivot `product_categories`.
 */
class Product extends Model
{
    protected $fillable = [
        'name',
        'slug',
        'description',
        'price',
        'image_path',
        'type',
        'is_new',
        'promo_label',
        'is_available',
        'sort_order',
    ];

    protected $appends = ['price_label'];

    protected function casts(): array
    {
        return [
            'price' => 'integer',
            'is_new' => 'boolean',
            'is_available' => 'boolean',
        ];
    }

    public function categories(): BelongsToMany
    {
        return $this->belongsToMany(Category::class, 'product_categories');
    }

    public function optionGroups(): BelongsToMany
    {
        return $this->belongsToMany(OptionGroup::class, 'product_option_group');
    }

    /** Filter hanya produk menu (minuman & makanan). */
    public function scopeMenu(Builder $query): Builder
    {
        return $query->where('type', 'menu');
    }

    /** Filter hanya merchandise. */
    public function scopeMerch(Builder $query): Builder
    {
        return $query->where('type', 'merch');
    }

    /** `28000` → `"Rp28.000"` — sama seperti `Product.priceLabel`. */
    public function getPriceLabelAttribute(): string
    {
        return 'Rp'.number_format($this->price, 0, ',', '.');
    }

    public function toApi(bool $withCategories = true): array
    {
        $data = [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'description' => $this->description,
            'price' => $this->price,
            'price_label' => $this->price_label,
            'image' => $this->image_path,
            'type' => $this->type,
            'is_new' => $this->is_new,
            'promo_label' => $this->promo_label,
        ];

        if ($withCategories) {
            $data['categories'] = $this->relationLoaded('categories')
                ? $this->categories->pluck('name')->values()->all()
                : $this->categories()->pluck('name')->all();
        }

        return $data;
    }
}
