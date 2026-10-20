<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/** Halaman informasi statis (StaticPageScreen). */
class StaticPage extends Model
{
    protected $table = 'static_pages';

    protected $fillable = [
        'slug',
        'title',
        'icon_key',
        'intro',
        'sections',
        'cta_label',
        'cta_message',
        'is_active',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'sections' => 'array',
            'is_active' => 'boolean',
        ];
    }

    public function toApi(): array
    {
        return [
            'slug' => $this->slug,
            'title' => $this->title,
            'icon_key' => $this->icon_key,
            'intro' => $this->intro,
            'sections' => $this->sections ?? [],
            'cta_label' => $this->cta_label,
            'cta_message' => $this->cta_message,
        ];
    }
}
