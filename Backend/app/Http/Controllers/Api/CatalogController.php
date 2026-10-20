<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Outlet;
use App\Models\Product;
use App\Models\StaticPage;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/** Data katalog: outlet, kategori, produk, merchandise, halaman statis. */
class CatalogController extends Controller
{
    /** GET /api/outlets */
    public function outlets(): JsonResponse
    {
        $outlets = Outlet::where('is_active', true)
            ->orderBy('sort_order')
            ->get()
            ->map(fn (Outlet $o) => $o->toApi());

        return response()->json(['data' => $outlets]);
    }

    /** GET /api/categories */
    public function categories(): JsonResponse
    {
        $categories = Category::where('is_active', true)
            ->orderBy('sort_order')
            ->get()
            ->map(fn (Category $c) => $c->toApi());

        return response()->json(['data' => $categories]);
    }

    /**
     * GET /api/products
     *
     * Filter opsional:
     * - `category` : slug atau nama kategori, mis. `promo-combo`
     * - `type`     : `menu` (bawaan) atau `merch`
     * - `new`      : `1` untuk hanya produk baru
     */
    public function products(Request $request): JsonResponse
    {
        $type = $request->query('type', 'menu');

        $query = Product::query()
            ->where('is_available', true)
            ->with('categories')
            ->orderBy('sort_order');

        if ($type !== 'all') {
            $query->where('type', $type);
        }

        if ($request->filled('category')) {
            $category = $request->query('category');
            $query->whereHas('categories', function (Builder $q) use ($category) {
                $q->where('slug', $category)->orWhere('name', $category);
            });
        }

        if ($request->boolean('new')) {
            $query->where('is_new', true);
        }

        return response()->json([
            'data' => $query->get()->map(fn (Product $p) => $p->toApi())->all(),
        ]);
    }

    /** GET /api/products/{product} */
    public function product(Product $product): JsonResponse
    {
        $product->load(['categories', 'optionGroups.options']);

        return response()->json([
            'data' => $product->toApi() + [
                'option_groups' => $product->optionGroups
                    ->map(fn ($g) => $g->toApi())
                    ->all(),
            ],
        ]);
    }

    /** GET /api/merch */
    public function merch(): JsonResponse
    {
        $products = Product::merch()
            ->where('is_available', true)
            ->orderBy('sort_order')
            ->get()
            ->map(fn (Product $p) => $p->toApi(false));

        return response()->json(['data' => $products]);
    }

    /** GET /api/static-pages/{slug} */
    public function staticPage(string $slug): JsonResponse
    {
        $page = StaticPage::where('slug', $slug)->where('is_active', true)->firstOrFail();

        return response()->json(['data' => $page->toApi()]);
    }
}
