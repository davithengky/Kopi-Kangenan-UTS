<?php

use App\Http\Controllers\Api\AddressController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BulkOrderController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\CatalogController;
use App\Http\Controllers\Api\InboxController;
use App\Http\Controllers\Api\MembershipController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\SettingsController;
use App\Http\Controllers\Api\VoucherController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Kopi Kangenan
|--------------------------------------------------------------------------
| Semua endpoint memakai prefix /api (lihat bootstrap/app.php).
| Autentikasi memakai Laravel Sanctum (Bearer token).
*/

// --- Endpoint publik ------------------------------------------------------
Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
    Route::post('login/google', [AuthController::class, 'google']);
});

Route::get('outlets', [CatalogController::class, 'outlets']);
Route::get('categories', [CatalogController::class, 'categories']);
Route::get('products', [CatalogController::class, 'products']);
Route::get('products/{product}', [CatalogController::class, 'product']);
Route::get('merch', [CatalogController::class, 'merch']);
Route::get('voucher-packs', [VoucherController::class, 'packs']);
Route::get('vouchers/catalog', [VoucherController::class, 'catalog']);
Route::get('checkin/rewards', [MembershipController::class, 'rewards']);
Route::get('static-pages/{slug}', [CatalogController::class, 'staticPage']);
Route::post('bulk-orders', [BulkOrderController::class, 'store']);

// --- Endpoint yang butuh login -------------------------------------------
Route::middleware('auth:sanctum')->group(function () {
    Route::get('auth/me', [AuthController::class, 'me']);
    Route::post('auth/logout', [AuthController::class, 'logout']);
    Route::post('auth/logout-all', [AuthController::class, 'logoutAll']);

    Route::get('profile', [ProfileController::class, 'show']);
    Route::put('profile', [ProfileController::class, 'update']);
    Route::put('profile/password', [ProfileController::class, 'updatePassword']);

    Route::apiResource('addresses', AddressController::class)->except(['show']);
    Route::put('addresses/{address}/default', [AddressController::class, 'setDefault']);

    Route::get('cart', [CartController::class, 'show']);
    Route::post('cart/items', [CartController::class, 'store']);
    Route::put('cart/items/{cartItem}', [CartController::class, 'update']);
    Route::delete('cart/items/{cartItem}', [CartController::class, 'destroy']);
    Route::delete('cart', [CartController::class, 'clear']);

    Route::get('vouchers', [VoucherController::class, 'index']);
    Route::post('vouchers/validate', [VoucherController::class, 'validateCode']);
    Route::post('voucher-packs/{voucherPack}/buy', [VoucherController::class, 'buyPack']);
    Route::post('promos/claim', [VoucherController::class, 'claimPromo']);
    Route::get('promos', [VoucherController::class, 'promos']);

    Route::get('orders', [OrderController::class, 'index']);
    Route::post('orders', [OrderController::class, 'store']);
    Route::get('orders/{order}', [OrderController::class, 'show']);
    Route::put('orders/{order}/advance', [OrderController::class, 'advance']);
    Route::put('orders/{order}/cancel', [OrderController::class, 'cancel']);

    Route::get('membership', [MembershipController::class, 'show']);
    Route::get('points/history', [MembershipController::class, 'history']);
    Route::get('checkin', [MembershipController::class, 'status']);
    Route::post('checkin', [MembershipController::class, 'checkIn']);

    Route::get('payment-methods', [PaymentController::class, 'index']);
    Route::put('payment-methods/select', [PaymentController::class, 'select']);
    Route::post('payment-methods/{paymentMethod}/connect', [PaymentController::class, 'connect']);

    Route::get('inbox', [InboxController::class, 'index']);
    Route::put('inbox/{inboxMessage}/read', [InboxController::class, 'read']);
    Route::put('inbox/read-all', [InboxController::class, 'readAll']);

    Route::get('settings', [SettingsController::class, 'show']);
    Route::put('settings', [SettingsController::class, 'update']);

    Route::get('bulk-orders', [BulkOrderController::class, 'index']);
});
