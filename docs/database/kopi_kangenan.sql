-- =============================================================================
--  KOPI KANGENAN — Skema & Seed Database MySQL
-- =============================================================================
--  File ini adalah SUMBER KEBENARAN struktur database untuk REST API
--  `kopi-kangenan-api` (Laravel). Skema diturunkan 1:1 dari model Dart aplikasi
--  Flutter di `lib/models/` + logika store di `lib/providers/`.
--
--  Isi file:
--    1. Pembuatan database
--    2. 29 tabel aplikasi (DDL + index + foreign key)
--    3. Seed data yang SAMA dengan yang ada di aplikasi sekarang:
--       outlet, kategori, 20 produk/merch, relasi kategori, opsi kustomisasi,
--       4 metode pembayaran, 9 voucher, 2 paket voucher, 6 hadiah check-in,
--       6 halaman statis, user demo, alamat, kotak masuk, dan pesanan #1001.
--
--  Cara pakai (Laragon: MySQL 8.4, user root tanpa password):
--      D:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe -u root < kopi_kangenan.sql
--
--  Sifat: IDEMPOTEN — menjalankan ulang akan MENGHAPUS lalu membuat ulang semua
--  tabel aplikasi beserta seed-nya. Cocok dipakai untuk reset.
--
--  Catatan penting:
--    * Nominal uang disimpan sebagai INTEGER rupiah (tanpa desimal), sama
--      seperti model Dart.
--    * Tabel `order_items` dan `cart_items` menyimpan SNAPSHOT nama + harga,
--      karena `CartItem` di Flutter tidak menyimpan product_id.
--    * `toppings` dan `syrups` disimpan sebagai kolom JSON (di Dart hanya
--      List<String>, harga sudah masuk ke `unit_price`).
--    * Level membership TIDAK disimpan; dihitung dari `memberships.total_spent`.
--    * Tabel Laravel bawaan (cache/jobs/sessions/password_reset_tokens) sengaja
--      tidak dibuat karena tidak dipakai. Jalankan `php artisan migrate` HANYA
--      bila Anda memang ingin menambah tabel `migrations` bawaan framework.
-- =============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS `kopi_kangenan`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `kopi_kangenan`;

-- -----------------------------------------------------------------------------
--  Reset: hapus tabel lama (urutan dibalik mengikuti ketergantungan FK)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS `personal_access_tokens`;
DROP TABLE IF EXISTS `static_pages`;
DROP TABLE IF EXISTS `bulk_order_requests`;
DROP TABLE IF EXISTS `inbox_messages`;
DROP TABLE IF EXISTS `order_items`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `cart_items`;
DROP TABLE IF EXISTS `carts`;
DROP TABLE IF EXISTS `checkin_rewards`;
DROP TABLE IF EXISTS `daily_checkins`;
DROP TABLE IF EXISTS `point_entries`;
DROP TABLE IF EXISTS `memberships`;
DROP TABLE IF EXISTS `promo_claims`;
DROP TABLE IF EXISTS `user_vouchers`;
DROP TABLE IF EXISTS `pack_vouchers`;
DROP TABLE IF EXISTS `voucher_packs`;
DROP TABLE IF EXISTS `vouchers`;
DROP TABLE IF EXISTS `user_payment_methods`;
DROP TABLE IF EXISTS `payment_methods`;
DROP TABLE IF EXISTS `product_option_group`;
DROP TABLE IF EXISTS `options`;
DROP TABLE IF EXISTS `option_groups`;
DROP TABLE IF EXISTS `product_categories`;
DROP TABLE IF EXISTS `products`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `outlets`;
DROP TABLE IF EXISTS `addresses`;
DROP TABLE IF EXISTS `user_settings`;
DROP TABLE IF EXISTS `users`;

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
--  BAGIAN 1 — TABEL
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. users — akun pengguna (AuthUser / AuthService._Account)
--    `identifier` = apa pun yang diketik saat login (email ATAU nomor HP).
-- -----------------------------------------------------------------------------
CREATE TABLE `users` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`            VARCHAR(100)    NOT NULL,
  `identifier`      VARCHAR(150)    NOT NULL,
  `identifier_type` ENUM('email','phone') NOT NULL DEFAULT 'email',
  `password`        VARCHAR(255)    NOT NULL,
  `provider`        ENUM('local','google') NOT NULL DEFAULT 'local',
  `created_at`      TIMESTAMP       NULL DEFAULT NULL,
  `updated_at`      TIMESTAMP       NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_identifier_unique` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 2. user_settings — preferensi (SettingsStore)
-- -----------------------------------------------------------------------------
CREATE TABLE `user_settings` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`       BIGINT UNSIGNED NOT NULL,
  `language`      ENUM('indonesia','english') NOT NULL DEFAULT 'indonesia',
  `notif_promo`   TINYINT(1) NOT NULL DEFAULT 1,
  `notif_pesanan` TINYINT(1) NOT NULL DEFAULT 1,
  `biometric`     TINYINT(1) NOT NULL DEFAULT 0,
  `created_at`    TIMESTAMP NULL DEFAULT NULL,
  `updated_at`    TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_settings_user_id_unique` (`user_id`),
  CONSTRAINT `user_settings_user_id_foreign`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 3. addresses — alamat pengiriman (AddressStore / Address)
-- -----------------------------------------------------------------------------
CREATE TABLE `addresses` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`    BIGINT UNSIGNED NOT NULL,
  `label`      VARCHAR(40)  NOT NULL,
  `recipient`  VARCHAR(100) NOT NULL,
  `phone`      VARCHAR(30)  NOT NULL,
  `detail`     VARCHAR(255) NOT NULL,
  `note`       VARCHAR(255) NOT NULL DEFAULT '',
  `is_default` TINYINT(1)   NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `addresses_user_id_index` (`user_id`),
  CONSTRAINT `addresses_user_id_foreign`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 4. outlets — outlet (kOutlets / Outlet)
-- -----------------------------------------------------------------------------
CREATE TABLE `outlets` (
  `id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`           VARCHAR(120)   NOT NULL,
  `address`        VARCHAR(255)   NOT NULL,
  `latitude`       DECIMAL(10,7)  NOT NULL DEFAULT 0,
  `longitude`      DECIMAL(10,7)  NOT NULL DEFAULT 0,
  `distance_label` VARCHAR(20)    NOT NULL DEFAULT '',
  `is_default`     TINYINT(1)     NOT NULL DEFAULT 0,
  `is_active`      TINYINT(1)     NOT NULL DEFAULT 1,
  `sort_order`     INT            NOT NULL DEFAULT 0,
  `created_at`     TIMESTAMP NULL DEFAULT NULL,
  `updated_at`     TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `outlets_name_unique` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 5. categories — kategori menu (MenuScreen.categories)
-- -----------------------------------------------------------------------------
CREATE TABLE `categories` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`       VARCHAR(60)  NOT NULL,
  `slug`       VARCHAR(60)  NOT NULL,
  `sort_order` INT          NOT NULL DEFAULT 0,
  `is_active`  TINYINT(1)   NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories_name_unique` (`name`),
  UNIQUE KEY `categories_slug_unique` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 6. products — menu (kProductCatalog) + merchandise (kMerchCatalog)
--    `type` memisahkan minuman/makanan ('menu') dari merchandise ('merch').
-- -----------------------------------------------------------------------------
CREATE TABLE `products` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`         VARCHAR(150)   NOT NULL,
  `slug`         VARCHAR(160)   NOT NULL,
  `description`  TEXT           NULL,
  `price`        INT UNSIGNED   NOT NULL DEFAULT 0,
  `image_path`   VARCHAR(255)   NOT NULL DEFAULT '',
  `type`         ENUM('menu','merch') NOT NULL DEFAULT 'menu',
  `is_new`       TINYINT(1)     NOT NULL DEFAULT 0,
  `promo_label`  VARCHAR(60)    NOT NULL DEFAULT '',
  `is_available` TINYINT(1)     NOT NULL DEFAULT 1,
  `sort_order`   INT            NOT NULL DEFAULT 0,
  `created_at`   TIMESTAMP NULL DEFAULT NULL,
  `updated_at`   TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `products_name_unique` (`name`),
  UNIQUE KEY `products_slug_unique` (`slug`),
  KEY `products_type_index` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 7. product_categories — pivot: satu produk boleh ada di banyak kategori
--    (mis. "Taro Cloud Latte" ada di "Baru!" DAN "Coffee").
-- -----------------------------------------------------------------------------
CREATE TABLE `product_categories` (
  `product_id`  BIGINT UNSIGNED NOT NULL,
  `category_id` BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (`product_id`, `category_id`),
  KEY `product_categories_category_id_index` (`category_id`),
  CONSTRAINT `product_categories_product_id_foreign`
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `product_categories_category_id_foreign`
    FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 8-10. Opsi kustomisasi produk (ProductDetailScreen)
--   OPSIONAL: di aplikasi Flutter daftar ini masih di-hardcode di layar, bukan
--   per-produk. Tabel disiapkan supaya API bisa menyajikannya nanti.
-- -----------------------------------------------------------------------------
CREATE TABLE `option_groups` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(60)  NOT NULL,
  `slug`        VARCHAR(60)  NOT NULL,
  `type`        ENUM('single','multi') NOT NULL DEFAULT 'single',
  `is_required` TINYINT(1)   NOT NULL DEFAULT 1,
  `max_select`  INT          NULL,
  `sort_order`  INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `option_groups_slug_unique` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `options` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `option_group_id` BIGINT UNSIGNED NOT NULL,
  `name`            VARCHAR(80) NOT NULL,
  `extra_price`     INT UNSIGNED NOT NULL DEFAULT 0,
  `is_available`    TINYINT(1)  NOT NULL DEFAULT 1,
  `sort_order`      INT         NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `options_option_group_id_index` (`option_group_id`),
  CONSTRAINT `options_option_group_id_foreign`
    FOREIGN KEY (`option_group_id`) REFERENCES `option_groups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `product_option_group` (
  `product_id`      BIGINT UNSIGNED NOT NULL,
  `option_group_id` BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (`product_id`, `option_group_id`),
  KEY `product_option_group_option_group_id_index` (`option_group_id`),
  CONSTRAINT `product_option_group_product_id_foreign`
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `product_option_group_option_group_id_foreign`
    FOREIGN KEY (`option_group_id`) REFERENCES `option_groups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 11. payment_methods — metode pembayaran (kPaymentMethods)
-- -----------------------------------------------------------------------------
CREATE TABLE `payment_methods` (
  `id`               VARCHAR(20)  NOT NULL,
  `name`             VARCHAR(80)  NOT NULL,
  `subtitle`         VARCHAR(120) NOT NULL DEFAULT '',
  `icon_key`         VARCHAR(60)  NOT NULL DEFAULT '',
  `brand_color`      CHAR(7)      NULL,
  `needs_connection` TINYINT(1)   NOT NULL DEFAULT 0,
  `is_active`        TINYINT(1)   NOT NULL DEFAULT 1,
  `sort_order`       INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 12. user_payment_methods — metode yang dipilih / dihubungkan (PaymentStore)
-- -----------------------------------------------------------------------------
CREATE TABLE `user_payment_methods` (
  `id`                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`           BIGINT UNSIGNED NOT NULL,
  `payment_method_id` VARCHAR(20)  NOT NULL,
  `is_connected`      TINYINT(1)   NOT NULL DEFAULT 0,
  `is_selected`       TINYINT(1)   NOT NULL DEFAULT 0,
  `created_at`        TIMESTAMP NULL DEFAULT NULL,
  `updated_at`        TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_payment_methods_unique` (`user_id`, `payment_method_id`),
  CONSTRAINT `user_payment_methods_user_id_foreign`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_payment_methods_method_id_foreign`
    FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 13. vouchers — katalog voucher + template voucher milik paket (Voucher)
-- -----------------------------------------------------------------------------
CREATE TABLE `vouchers` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code`          VARCHAR(40)  NOT NULL,
  `title`         VARCHAR(120) NOT NULL,
  `description`   VARCHAR(255) NOT NULL DEFAULT '',
  `kind`          ENUM('diskon','cashback','delivery','gratis') NOT NULL DEFAULT 'diskon',
  `percent`       TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `amount`        INT UNSIGNED NOT NULL DEFAULT 0,
  `min_purchase`  INT UNSIGNED NOT NULL DEFAULT 0,
  `validity`      VARCHAR(60)  NOT NULL DEFAULT 'Berlaku s/d 31 Des 2026',
  `is_active`     TINYINT(1)   NOT NULL DEFAULT 1,
  `created_at`    TIMESTAMP NULL DEFAULT NULL,
  `updated_at`    TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `vouchers_code_unique` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 14. voucher_packs — paket voucher yang bisa dibeli (kVoucherPacks)
-- -----------------------------------------------------------------------------
CREATE TABLE `voucher_packs` (
  `id`          VARCHAR(20)  NOT NULL,
  `title`       VARCHAR(120) NOT NULL,
  `description` VARCHAR(255) NOT NULL DEFAULT '',
  `old_price`   INT UNSIGNED NOT NULL DEFAULT 0,
  `price`       INT UNSIGNED NOT NULL DEFAULT 0,
  `saving`      VARCHAR(40)  NOT NULL DEFAULT '',
  `count_label` VARCHAR(20)  NOT NULL DEFAULT '',
  `is_active`   TINYINT(1)   NOT NULL DEFAULT 1,
  `sort_order`  INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 15. pack_vouchers — isi tiap paket (vouchersFromPack)
-- -----------------------------------------------------------------------------
CREATE TABLE `pack_vouchers` (
  `pack_id`    VARCHAR(20)  NOT NULL,
  `voucher_id` BIGINT UNSIGNED NOT NULL,
  `quantity`   INT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`pack_id`, `voucher_id`),
  KEY `pack_vouchers_voucher_id_index` (`voucher_id`),
  CONSTRAINT `pack_vouchers_pack_id_foreign`
    FOREIGN KEY (`pack_id`) REFERENCES `voucher_packs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pack_vouchers_voucher_id_foreign`
    FOREIGN KEY (`voucher_id`) REFERENCES `vouchers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 16. user_vouchers — voucher milik pengguna (VoucherStore.userVouchers)
-- -----------------------------------------------------------------------------
CREATE TABLE `user_vouchers` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`    BIGINT UNSIGNED NOT NULL,
  `voucher_id` BIGINT UNSIGNED NULL,
  `code`       VARCHAR(40)  NOT NULL,
  `status`     ENUM('available','used','expired') NOT NULL DEFAULT 'available',
  `claimed_at` TIMESTAMP NULL DEFAULT NULL,
  `used_at`    TIMESTAMP NULL DEFAULT NULL,
  `order_id`   BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_vouchers_user_id_index` (`user_id`),
  KEY `user_vouchers_voucher_id_index` (`voucher_id`),
  CONSTRAINT `user_vouchers_user_id_foreign`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_vouchers_voucher_id_foreign`
    FOREIGN KEY (`voucher_id`) REFERENCES `vouchers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 17. promo_claims — promo yang sudah diklaim (VoucherStore.claimedPromos)
-- -----------------------------------------------------------------------------
CREATE TABLE `promo_claims` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`    BIGINT UNSIGNED NOT NULL,
  `label`      VARCHAR(80)  NOT NULL,
  `claimed_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `promo_claims_user_label_unique` (`user_id`, `label`),
  CONSTRAINT `promo_claims_user_id_foreign`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 18. memberships — poin & total belanja (MemberStore)
--     Level (Silver/Gold/Black) DIHITUNG dari total_spent, tidak disimpan.
-- -----------------------------------------------------------------------------
CREATE TABLE `memberships` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`     BIGINT UNSIGNED NOT NULL,
  `points`      INT NOT NULL DEFAULT 0,
  `total_spent` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `created_at`  TIMESTAMP NULL DEFAULT NULL,
  `updated_at`  TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `memberships_user_id_unique` (`user_id`),
  CONSTRAINT `memberships_user_id_foreign`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 19. point_entries — riwayat poin (MemberStore.history / PointEntry)
-- -----------------------------------------------------------------------------
CREATE TABLE `point_entries` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`    BIGINT UNSIGNED NOT NULL,
  `title`      VARCHAR(150) NOT NULL,
  `delta`      INT          NOT NULL DEFAULT 0,
  `order_id`   BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `point_entries_user_id_index` (`user_id`),
  KEY `point_entries_order_id_index` (`order_id`),
  CONSTRAINT `point_entries_user_id_foreign`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
  -- Catatan: `order_id` sengaja tanpa foreign key karena tabel `orders`
  -- dibuat setelah tabel ini (menghindari ketergantungan melingkar).
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 20. checkin_rewards — hadiah 6 hari Daily Check-In (MemberStore.dailyRewards)
-- -----------------------------------------------------------------------------
CREATE TABLE `checkin_rewards` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `day_number`   TINYINT UNSIGNED NOT NULL,
  `reward_label` VARCHAR(40) NOT NULL,
  `reward_type`  ENUM('points','voucher') NOT NULL DEFAULT 'points',
  `reward_value` INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `checkin_rewards_day_unique` (`day_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 21. daily_checkins — check-in yang sudah dilakukan (MemberStore.checkedDays)
-- -----------------------------------------------------------------------------
CREATE TABLE `daily_checkins` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`      BIGINT UNSIGNED NOT NULL,
  `day_number`   TINYINT UNSIGNED NOT NULL,
  `period`       CHAR(7)      NOT NULL COMMENT 'Format YYYY-MM, mis. 2026-10',
  `reward_label` VARCHAR(40)  NOT NULL DEFAULT '',
  `claimed_at`   TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `daily_checkins_unique` (`user_id`, `period`, `day_number`),
  CONSTRAINT `daily_checkins_user_id_foreign`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 22. carts / 23. cart_items — keranjang (CartStore / CartItem)
--     SNAPSHOT: name + harga disimpan apa adanya.
-- -----------------------------------------------------------------------------
CREATE TABLE `carts` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`    BIGINT UNSIGNED NULL COMMENT 'NULL = keranjang tamu',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `carts_user_id_index` (`user_id`),
  CONSTRAINT `carts_user_id_foreign`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `cart_items` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `cart_id`    BIGINT UNSIGNED NOT NULL,
  `product_id` BIGINT UNSIGNED NULL,
  `name`       VARCHAR(150) NOT NULL,
  `image_path` VARCHAR(255) NOT NULL DEFAULT '',
  `base_price` INT UNSIGNED NOT NULL DEFAULT 0,
  `unit_price` INT UNSIGNED NOT NULL DEFAULT 0,
  `quantity`   INT UNSIGNED NOT NULL DEFAULT 1,
  `size`       VARCHAR(40)  NOT NULL DEFAULT 'Regular',
  `milk`       VARCHAR(40)  NOT NULL DEFAULT 'Milk',
  `sugar`      VARCHAR(40)  NOT NULL DEFAULT 'Normal Sugar',
  `ice`        VARCHAR(40)  NOT NULL DEFAULT 'Normal Ice',
  `toppings`   JSON NULL,
  `syrups`     JSON NULL,
  `note`       VARCHAR(255) NOT NULL DEFAULT '',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cart_items_cart_id_index` (`cart_id`),
  KEY `cart_items_product_id_index` (`product_id`),
  CONSTRAINT `cart_items_cart_id_foreign`
    FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cart_items_product_id_foreign`
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 24. orders — pesanan (Order). Kode berformat '#1001'.
-- -----------------------------------------------------------------------------
CREATE TABLE `orders` (
  `id`                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code`              VARCHAR(12)  NOT NULL,
  `user_id`           BIGINT UNSIGNED NULL,
  `outlet_id`         BIGINT UNSIGNED NULL,
  `subtotal`          INT UNSIGNED NOT NULL DEFAULT 0,
  `bag_fee`           INT UNSIGNED NOT NULL DEFAULT 0,
  `voucher_discount`  INT UNSIGNED NOT NULL DEFAULT 0,
  `points_used`       INT UNSIGNED NOT NULL DEFAULT 0,
  `total`             INT UNSIGNED NOT NULL DEFAULT 0,
  `payment_method_id` VARCHAR(20)  NOT NULL DEFAULT 'qris',
  `payment_method`    VARCHAR(40)  NOT NULL DEFAULT 'QRIS',
  `fulfilment`        ENUM('Pickup','Delivery') NOT NULL DEFAULT 'Pickup',
  `status`            ENUM('Pending','Processing','Ready','Completed','Cancelled') NOT NULL DEFAULT 'Pending',
  `scheduled_at`      DATETIME NULL DEFAULT NULL,
  `created_at`        TIMESTAMP NULL DEFAULT NULL,
  `updated_at`        TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `orders_code_unique` (`code`),
  KEY `orders_user_id_index` (`user_id`),
  KEY `orders_outlet_id_index` (`outlet_id`),
  CONSTRAINT `orders_user_id_foreign`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `orders_outlet_id_foreign`
    FOREIGN KEY (`outlet_id`) REFERENCES `outlets` (`id`) ON DELETE SET NULL,
  CONSTRAINT `orders_payment_method_id_foreign`
    FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 25. order_items — isi pesanan (snapshot CartItem)
-- -----------------------------------------------------------------------------
CREATE TABLE `order_items` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id`   BIGINT UNSIGNED NOT NULL,
  `product_id` BIGINT UNSIGNED NULL,
  `name`       VARCHAR(150) NOT NULL,
  `image_path` VARCHAR(255) NOT NULL DEFAULT '',
  `base_price` INT UNSIGNED NOT NULL DEFAULT 0,
  `unit_price` INT UNSIGNED NOT NULL DEFAULT 0,
  `quantity`   INT UNSIGNED NOT NULL DEFAULT 1,
  `size`       VARCHAR(40)  NOT NULL DEFAULT 'Regular',
  `milk`       VARCHAR(40)  NOT NULL DEFAULT 'Milk',
  `sugar`      VARCHAR(40)  NOT NULL DEFAULT 'Normal Sugar',
  `ice`        VARCHAR(40)  NOT NULL DEFAULT 'Normal Ice',
  `toppings`   JSON NULL,
  `syrups`     JSON NULL,
  `note`       VARCHAR(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `order_items_order_id_index` (`order_id`),
  KEY `order_items_product_id_index` (`product_id`),
  CONSTRAINT `order_items_order_id_foreign`
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `order_items_product_id_foreign`
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 26. inbox_messages — Kotak Masuk (InboxStore / InboxMessage)
-- -----------------------------------------------------------------------------
CREATE TABLE `inbox_messages` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`    BIGINT UNSIGNED NOT NULL,
  `title`      VARCHAR(150) NOT NULL,
  `body`       TEXT NOT NULL,
  `kind`       ENUM('Promo','Pesanan','Akun') NOT NULL DEFAULT 'Promo',
  `read_at`    TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `inbox_messages_user_id_index` (`user_id`),
  CONSTRAINT `inbox_messages_user_id_foreign`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 27. bulk_order_requests — form pesanan jumlah besar (BulkOrderScreen)
-- -----------------------------------------------------------------------------
CREATE TABLE `bulk_order_requests` (
  `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`         BIGINT UNSIGNED NULL,
  `name`            VARCHAR(100) NOT NULL,
  `contact`         VARCHAR(60)  NOT NULL,
  `purpose`         VARCHAR(120) NOT NULL DEFAULT '',
  `estimated_cups`  INT UNSIGNED NOT NULL DEFAULT 0,
  `event_date`      DATE NULL DEFAULT NULL,
  `note`            VARCHAR(255) NOT NULL DEFAULT '',
  `status`          ENUM('Baru','Diproses','Selesai') NOT NULL DEFAULT 'Baru',
  `created_at`      TIMESTAMP NULL DEFAULT NULL,
  `updated_at`      TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `bulk_order_requests_user_id_index` (`user_id`),
  CONSTRAINT `bulk_order_requests_user_id_foreign`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 28. static_pages — halaman statis (StaticPageScreen)
--     `sections` = array JSON [{heading, body}, ...]
-- -----------------------------------------------------------------------------
CREATE TABLE `static_pages` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `slug`        VARCHAR(60)  NOT NULL,
  `title`       VARCHAR(120) NOT NULL,
  `icon_key`    VARCHAR(60)  NOT NULL DEFAULT '',
  `intro`       TEXT NOT NULL,
  `sections`    JSON NOT NULL,
  `cta_label`   VARCHAR(60)  NULL,
  `cta_message` VARCHAR(255) NULL,
  `is_active`   TINYINT(1)   NOT NULL DEFAULT 1,
  `sort_order`  INT          NOT NULL DEFAULT 0,
  `created_at`  TIMESTAMP NULL DEFAULT NULL,
  `updated_at`  TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `static_pages_slug_unique` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 29. personal_access_tokens — token API (Laravel Sanctum)
-- -----------------------------------------------------------------------------
CREATE TABLE `personal_access_tokens` (
  `id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `tokenable_type` VARCHAR(255) NOT NULL,
  `tokenable_id`   BIGINT UNSIGNED NOT NULL,
  `name`           TEXT NOT NULL,
  `token`          VARCHAR(64)  NOT NULL,
  `abilities`      TEXT NULL,
  `last_used_at`   TIMESTAMP NULL DEFAULT NULL,
  `expires_at`     TIMESTAMP NULL DEFAULT NULL,
  `created_at`     TIMESTAMP NULL DEFAULT NULL,
  `updated_at`     TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_index` (`tokenable_type`, `tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
--  BAGIAN 2 — SEED DATA (sama dengan data yang ada di aplikasi sekarang)
-- =============================================================================

-- --- 2.1 Users -------------------------------------------------------------
-- Password kedua akun: `123456` (bcrypt). Akun demo untuk login aplikasi.
INSERT INTO `users` (`id`, `name`, `identifier`, `identifier_type`, `password`, `provider`, `created_at`, `updated_at`) VALUES
(1, 'Pengguna Demo',   'demo@kangenan.com',          'email', '$2y$10$aXe8EKEqnKUCkAH5/3uB8OcdKRWKBqf1Z12LQcWpOKK.U6frv8euK', 'local',  NOW(), NOW()),
(2, 'Pengguna Google', 'pengguna.google@gmail.com',  'email', '$2y$10$aXe8EKEqnKUCkAH5/3uB8OcdKRWKBqf1Z12LQcWpOKK.U6frv8euK', 'google', NOW(), NOW());

-- --- 2.2 User settings (SettingsStore default) ------------------------------
INSERT INTO `user_settings` (`user_id`, `language`, `notif_promo`, `notif_pesanan`, `biometric`, `created_at`, `updated_at`) VALUES
(1, 'indonesia', 1, 1, 0, NOW(), NOW()),
(2, 'indonesia', 1, 1, 0, NOW(), NOW());

-- --- 2.3 Addresses (AddressStore seed: label "Rumah") ----------------------
INSERT INTO `addresses` (`id`, `user_id`, `label`, `recipient`, `phone`, `detail`, `note`, `is_default`, `created_at`, `updated_at`) VALUES
(1, 1, 'Rumah', 'Jibi', '0812-3456-7890', 'Jl. Ketintang Baru No. 21, Gayungan, Surabaya', 'Pagar hitam, sebelah warung Bu Sri', 1, NOW(), NOW());

-- --- 2.4 Outlets (kOutlets) ------------------------------------------------
INSERT INTO `outlets` (`id`, `name`, `address`, `latitude`, `longitude`, `distance_label`, `is_default`, `is_active`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 'Tunjungan Plaza 3', 'Tunjungan Plaza 3, Lantai 5, Surabaya',      -7.2626000, 112.7382000, '1,2 km', 1, 1, 1, NOW(), NOW()),
(2, 'Ketintang UNESA',   'Jl. Ketintang No. 12, Surabaya',             -7.3117000, 112.7276000, '3,4 km', 0, 1, 2, NOW(), NOW()),
(3, 'Darmo Trade Center','Darmo Trade Center, Lantai UG, Surabaya',    -7.2899000, 112.7364000, '4,1 km', 0, 1, 3, NOW(), NOW());

-- --- 2.5 Categories (MenuScreen.categories) --------------------------------
INSERT INTO `categories` (`id`, `name`, `slug`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Promo & Combo', 'promo-combo', 1, 1, NOW(), NOW()),
(2, 'Baru!',         'baru',        2, 1, NOW(), NOW()),
(3, 'Coffee',        'coffee',      3, 1, NOW(), NOW()),
(4, 'Non Coffee',    'non-coffee',  4, 1, NOW(), NOW()),
(5, 'Makanan',       'makanan',     5, 1, NOW(), NOW());

-- --- 2.6 Products (kProductCatalog, 10 menu + kMerchCatalog, 10 merch) -----
INSERT INTO `products` (`id`, `name`, `slug`, `description`, `price`, `image_path`, `type`, `is_new`, `promo_label`, `is_available`, `sort_order`, `created_at`, `updated_at`) VALUES
-- Menu (kProductCatalog)
(1,  'PaHe 1',                          'pahe-1',                          'Kopi Susu Gula Aren ukuran regular plus air mineral. Pilihan paling ramah kantong untuk ngopi tiap hari.', 19000,  'assets/pahe1.png',                                'menu',  0, '',                1, 1,  NOW(), NOW()),
(2,  'PaHe 2',                          'pahe-2',                          'Kopi Susu Gula Aren plus croissant butter panggang. Kenyang, hemat, dan pas untuk sarapan.', 27000,  'assets/pahe2.png',                                'menu',  0, 'Promo Delivery',  1, 2,  NOW(), NOW()),
(3,  'PaHe 3',                          'pahe-3',                          'Dua Kopi Susu Gula Aren untuk ngopi berdua. Jauh lebih hemat daripada membeli satuan.', 29000,  'assets/pahe3.png',                                'menu',  0, '',                1, 3,  NOW(), NOW()),
(4,  'Taro Cloud Matcha',               'taro-cloud-matcha',               'Matcha Jepang dengan busa taro lembut di atasnya. Manisnya pas dan pahitnya halus.', 28000,  'assets/Taro cloud matcha.png',                    'menu',  1, '',                1, 4,  NOW(), NOW()),
(5,  'Taro Milk',                       'taro-milk',                       'Susu segar dengan pasta taro asli. Lembut, creamy, dan tidak terlalu manis.', 25000,  'assets/taro milk.png',                            'menu',  1, '',                1, 5,  NOW(), NOW()),
(6,  'Taro Cloud Latte',                'taro-cloud-latte',                'Espresso, susu segar, dan busa taro. Perpaduan kopi dan taro dalam satu gelas.', 28000,  'assets/taro cloud latte.png',                     'menu',  1, '',                1, 6,  NOW(), NOW()),
(7,  'Taro Cloud Milk Tea',             'taro-cloud-milk-tea',             'Teh susu dengan rasa taro dan busa lembut sebagai penutup. Segar dinikmati dingin.', 25000,  'assets/taro cloud milktea.png',                   'menu',  1, '',                1, 7,  NOW(), NOW()),
(8,  'Triple Cheese Bagel',             'triple-cheese-bagel',             'Roti bagel bercita rasa keju dari keju parmesan dengan topping keju mozzarella dan lelehan keju cheddar.', 22000,  'assets/triple cheeze bagel.png',                  'menu',  0, '',                1, 8,  NOW(), NOW()),
(9,  'Beef and Cheese Jalapeno Bagel',  'beef-and-cheese-jalapeno-bagel',  'Bagel isi daging sapi cincang dan keju, dengan irisan jalapeno yang memberi rasa pedas segar.', 28000,  'assets/beef and cheese jalapeno bagel.png',       'menu',  0, '',                1, 9,  NOW(), NOW()),
(10, 'Double Choco Bagel',              'double-choco-bagel',              'Bagel dengan lelehan cokelat ganda: dark chocolate di dalam dan choco glaze di atasnya.', 22000,  'assets/double choco bagel.png',                   'menu',  0, '',                1, 10, NOW(), NOW()),
-- Merchandise (kMerchCatalog)
(11, 'ColorPop Cup',                    'colorpop-cup',                    'Cangkir keramik dengan semburat warna ceria. Tahan panas, cocok untuk kopi pagi di rumah.', 109650, 'assets/merch/ColorPop Cup.png',                   'merch', 0, '', 1, 11, NOW(), NOW()),
(12, 'ColorPop Sip Tumbler',            'colorpop-sip-tumbler',            'Tumbler sedotan 600 ml dengan lapisan kaca dalam. Bebas bocor dan mudah dibawa jalan.',     177650, 'assets/merch/ColorPop Sip Tumbler.png',           'merch', 0, '', 1, 12, NOW(), NOW()),
(13, 'Capybara',                        'capybara',                        'Boneka maskot capybara Kopi Kangenan. Lembut, tinggi 18 cm, teman duduk paling tenang.',    49000,  'assets/merch/Capybara.png',                        'merch', 0, '', 1, 13, NOW(), NOW()),
(14, 'Playsonality Bottle',             'playsonality-bottle',             'Botol minum stainless 750 ml dengan tutup ulir. Menjaga suhu dingin hingga 12 jam.',        199000, 'assets/merch/Playsonality Bottle.png',            'merch', 0, '', 1, 14, NOW(), NOW()),
(15, 'Playsonality Classic Cup',        'playsonality-classic-cup',        'Cangkir keramik klasik 350 ml dengan garis emas. Elegan untuk momen santai.',              169000, 'assets/merch/Playsonality  Classic Cup.png',      'merch', 0, '', 1, 15, NOW(), NOW()),
(16, 'Playsonality Press Tumbler',      'playsonality-press-tumbler',      'Tumbler tekan 500 ml dengan tombol sekali sentuh. Praktis diminum sambil berkendara.',      159000, 'assets/merch/Playsonality Press Tumbler.png',     'merch', 0, '', 1, 16, NOW(), NOW()),
(17, 'Golden Sling Tumbler',            'golden-sling-tumbler',            'Tumbler edisi emas 600 ml lengkap dengan tali bahu. Bisa diukir nama.',                    219000, 'assets/merch/Golden Sling Tumbler.png',           'merch', 0, '', 1, 17, NOW(), NOW()),
(18, 'ColorPop Bubble Tumbler',         'colorpop-bubble-tumbler',         'Tumbler gelembung warna pastel 550 ml. Ringan dan anti pecah.',                            169150, 'assets/merch/ColorPop Bubble Tumbler.png',        'merch', 0, '', 1, 18, NOW(), NOW()),
(19, 'Sigma Slim Bottle',               'sigma-slim-bottle',               'Botol ramping 500 ml yang muat di kantong tas. Tahan suhu panas maupun dingin.',           209000, 'assets/merch/Sigma Slim Bottle.png',              'merch', 0, '', 1, 19, NOW(), NOW()),
(20, 'Sigma Sip Cup',                   'sigma-sip-cup',                   'Gelas sipping double wall 400 ml untuk kopi susu favoritmu.',                               169000, 'assets/merch/Sigma Sip Cup.png',                  'merch', 0, '', 1, 20, NOW(), NOW());

-- --- 2.7 Product categories (pivot, 14 baris) ------------------------------
INSERT INTO `product_categories` (`product_id`, `category_id`) VALUES
-- Promo & Combo
(1, 1), (2, 1), (3, 1),
-- Baru!
(4, 2), (5, 2), (6, 2), (7, 2),
-- Coffee
(6, 3),
-- Non Coffee
(4, 4), (5, 4), (7, 4),
-- Makanan
(8, 5), (9, 5), (10, 5);

-- --- 2.8 Option groups & options (ProductDetailScreen) --------------------
INSERT INTO `option_groups` (`id`, `name`, `slug`, `type`, `is_required`, `max_select`, `sort_order`) VALUES
(1, 'Temperature',  'temperature', 'single', 1, 1,    1),
(2, 'Size',         'size',        'single', 1, 1,    2),
(3, 'Milk Option',  'milk-option', 'single', 1, 1,    3),
(4, 'Sugar Level',  'sugar-level', 'single', 1, 1,    4),
(5, 'Ice Level',    'ice-level',   'single', 1, 1,    5),
(6, 'Topping',      'topping',     'multi',  0, NULL, 6),
(7, 'Syrup',        'syrup',       'multi',  0, NULL, 7);

INSERT INTO `options` (`option_group_id`, `name`, `extra_price`, `is_available`, `sort_order`) VALUES
-- Temperature
(1, 'Ice', 0, 1, 1),
-- Size
(2, 'Regular', 0,    1, 1),
(2, 'Large',   4000, 1, 2),
(2, 'Jumbo',   8000, 1, 3),
-- Milk Option
(3, 'Milk',    0, 1, 1),
(3, 'Oatside', 0, 1, 2),
-- Sugar Level
(4, 'Normal Sugar', 0, 1, 1),
(4, 'Less Sugar',   0, 1, 2),
(4, 'No Sugar',     0, 1, 3),
-- Ice Level
(5, 'Normal Ice', 0, 1, 1),
(5, 'Less Ice',   0, 1, 2),
(5, 'No Ice',     0, 1, 3),
-- Topping
(6, 'Espresso Shot Kenangan Blend', 6000, 1, 1),
(6, 'Espresso Shot Juwara Beans',   6000, 1, 2),
(6, 'Golden boba',                  0,    0, 3),
(6, 'Grass Jelly',                  6000, 1, 4),
(6, 'Oreo',                         6000, 1, 5),
(6, 'Whipped Cream Chocolate',      6000, 1, 6),
(6, 'Whipped Cream Vanilla',        6000, 1, 7),
(6, 'Caramel Crumble',              6000, 1, 8),
(6, 'Gula Aren',                    6000, 1, 9),
-- Syrup
(7, 'Vanilla Syrup',         6000, 1, 1),
(7, 'Hazelnut Syrup',        6000, 1, 2),
(7, 'Caramel Syrup',         6000, 1, 3),
(7, 'Salted Caramel Sauce',  6000, 1, 4),
(7, 'Choco Sauce',           6000, 1, 5),
(7, 'Butterscotch Sauce',    6000, 1, 6);

-- Semua opsi berlaku untuk seluruh produk `menu` (perilaku aplikasi sekarang).
INSERT INTO `product_option_group` (`product_id`, `option_group_id`)
SELECT p.`id`, g.`id` FROM `products` p CROSS JOIN `option_groups` g WHERE p.`type` = 'menu';

-- --- 2.9 Payment methods (kPaymentMethods) --------------------------------
INSERT INTO `payment_methods` (`id`, `name`, `subtitle`, `icon_key`, `brand_color`, `needs_connection`, `is_active`, `sort_order`) VALUES
('qris',  'QRIS',                'Simpan QR dan bayar',        'qr_code_2',                NULL,      0, 1, 1),
('blu',   'blu by BCA Digital',  'Cashback 40% max. 25RB*',    'account_balance_wallet',   '#00A3C8', 0, 1, 2),
('gopay', 'GoPay',               'Hubungkan akun',             'account_balance_wallet',   '#00AED6', 1, 1, 3),
('kartu', 'Kartu Debit/Kredit',  'Visa, Mastercard, JCB',      'credit_card',              NULL,      0, 1, 4);

-- Default metode terpilih di aplikasi: QRIS.
INSERT INTO `user_payment_methods` (`user_id`, `payment_method_id`, `is_connected`, `is_selected`, `created_at`, `updated_at`) VALUES
(1, 'qris', 1, 1, NOW(), NOW()),
(2, 'qris', 1, 1, NOW(), NOW());

-- --- 2.10 Vouchers (VoucherStore.catalog + template paket) ----------------
INSERT INTO `vouchers` (`id`, `code`, `title`, `description`, `kind`, `percent`, `amount`, `min_purchase`, `validity`, `is_active`, `created_at`, `updated_at`) VALUES
-- Katalog contoh yang selalu bisa dipakai (VoucherStore.catalog)
(1, 'KANGENAN10',  'Voucher Diskon 10%',        'Diskon 10% untuk semua minuman, min. belanja Rp30.000.', 'diskon',   10, 0,     30000, 'Berlaku s/d 31 Des 2026', 1, NOW(), NOW()),
(2, 'GRATISKOPI',  'Voucher Gratis 1 Minuman',  'Potongan Rp25.000 tanpa minimum pembelian.',             'gratis',   0,  25000, 0,     'Berlaku s/d 31 Des 2026', 1, NOW(), NOW()),
(3, 'ONGKIRHEMAT', 'Voucher Delivery Rp5.000',  'Potongan Rp5.000 untuk pesanan Delivery.',               'delivery', 0,  5000,  50000, 'Berlaku s/d 31 Des 2026', 1, NOW(), NOW()),
-- Template voucher paket Rp9.000 (dari vouchersFromPack)
(4, 'pack-9000-10',     'Voucher Diskon 10%',        'Diskon 10% untuk pembelian minuman pilihan.',        'diskon', 10, 0,     30000, 'Berlaku s/d 31 Des 2026', 1, NOW(), NOW()),
(5, 'pack-9000-2k',     'Voucher Potongan Rp2.000',  'Potongan langsung Rp2.000 tanpa minimum pembelian.',  'diskon', 0,  2000,  0,     'Berlaku s/d 31 Des 2026', 1, NOW(), NOW()),
(6, 'pack-9000-gratis', 'Voucher Gratis 1 Minuman',  'Nikmati 1 minuman pilihan sesuai syarat voucher.',    'gratis', 0,  25000, 25000, 'Berlaku s/d 31 Des 2026', 1, NOW(), NOW()),
-- Template voucher paket Rp24.000
(7, 'pack-24000-10',     'Voucher Diskon 10%',       'Diskon 10% untuk pembelian minuman pilihan.',        'diskon', 10, 0,     30000, 'Berlaku s/d 31 Des 2026', 1, NOW(), NOW()),
(8, 'pack-24000-2k',     'Voucher Potongan Rp2.000', 'Potongan langsung Rp2.000 tanpa minimum pembelian.',  'diskon', 0,  2000,  0,     'Berlaku s/d 31 Des 2026', 1, NOW(), NOW()),
(9, 'pack-24000-gratis', 'Voucher Gratis 1 Minuman', 'Nikmati 1 minuman pilihan sesuai syarat voucher.',    'gratis', 0,  25000, 25000, 'Berlaku s/d 31 Des 2026', 1, NOW(), NOW());

-- --- 2.11 Voucher packs (kVoucherPacks) + isinya --------------------------
INSERT INTO `voucher_packs` (`id`, `title`, `description`, `old_price`, `price`, `saving`, `count_label`, `is_active`, `sort_order`) VALUES
('pack-9000',  'Langganan Voucher Rp9.000',  '1x Voucher B1G1, 2x Voucher B2G1, 30x Voucher Diskon 10%, 30x Voucher Diskon 15%.', 630000, 9000,  'Save 98%', '65x', 1, 1),
('pack-24000', 'Langganan Voucher Rp24.000', '1x Voucher Gratis 1 Minuman, 1x Voucher B1G1, 2x Voucher B2G1, 30x Voucher Diskon 10%, 30x Voucher Diskon 15%.', 680000, 24000, 'Save 96%', '66x', 1, 2);

INSERT INTO `pack_vouchers` (`pack_id`, `voucher_id`, `quantity`) VALUES
('pack-9000',  4, 1), ('pack-9000',  5, 1), ('pack-9000',  6, 1),
('pack-24000', 7, 1), ('pack-24000', 8, 1), ('pack-24000', 9, 1);

-- --- 2.12 Membership (MemberStore awal: poin 0, total belanja 0 = Silver) --
INSERT INTO `memberships` (`user_id`, `points`, `total_spent`, `created_at`, `updated_at`) VALUES
(1, 0, 0, NOW(), NOW()),
(2, 0, 0, NOW(), NOW());

-- --- 2.13 Check-in rewards (MemberStore.dailyRewards, 6 hari) -------------
INSERT INTO `checkin_rewards` (`day_number`, `reward_label`, `reward_type`, `reward_value`) VALUES
(1, '+25 poin', 'points',  25),
(2, '+25 poin', 'points',  25),
(3, 'Voucher',  'voucher', 0),
(4, '+25 poin', 'points',  25),
(5, '+25 poin', 'points',  25),
(6, 'Voucher',  'voucher', 0);

-- --- 2.14 Inbox messages (InboxStore seed: 3 pesan, 1 sudah dibaca) -------
INSERT INTO `inbox_messages` (`id`, `user_id`, `title`, `body`, `kind`, `read_at`, `created_at`, `updated_at`) VALUES
(1, 1, 'Selamat datang di Kopi Kangenan!', 'Terima kasih sudah mengunduh aplikasi kami. Cek promo terbaru di Beranda, ya!', 'Akun',    NULL,                                                       NOW(),                        NOW()),
(2, 1, 'Voucher Buy 1 Get 1',              'Klaim voucher Buy 1 Get 1 sepuasnya sebelum 31 Okt 2026. Berlaku di semua outlet.', 'Promo',   NULL,                                                       NOW() - INTERVAL 1 DAY,       NOW()),
(3, 1, 'Pesananmu sudah siap',             'Pesanan #1002 sudah siap diambil di counter Tunjungan Plaza 3.',                     'Pesanan', NOW() - INTERVAL 2 DAY,                                      NOW() - INTERVAL 2 DAY,       NOW());

-- --- 2.15 Pesanan contoh #1001 (OrderStore._seedOnce) --------------------
INSERT INTO `orders` (`id`, `code`, `user_id`, `outlet_id`, `subtotal`, `bag_fee`, `voucher_discount`, `points_used`, `total`, `payment_method_id`, `payment_method`, `fulfilment`, `status`, `scheduled_at`, `created_at`, `updated_at`) VALUES
(1, '#1001', 1, 1, 28000, 0, 0, 0, 28000, 'qris', 'QRIS', 'Pickup', 'Completed', NULL, NOW() - INTERVAL 3 DAY, NOW() - INTERVAL 3 DAY);

INSERT INTO `order_items` (`order_id`, `product_id`, `name`, `image_path`, `base_price`, `unit_price`, `quantity`, `size`, `milk`, `sugar`, `ice`, `toppings`, `syrups`, `note`) VALUES
(1, 6, 'Taro Cloud Latte', 'assets/taro cloud latte.png', 28000, 28000, 1, 'Regular', 'Milk', 'Normal Sugar', 'Normal Ice', JSON_ARRAY(), JSON_ARRAY(), '');

-- --- 2.16 Static pages (StaticPageScreen) --------------------------------
INSERT INTO `static_pages` (`id`, `slug`, `title`, `icon_key`, `intro`, `sections`, `cta_label`, `cta_message`, `is_active`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 'help', 'Bantuan', 'help_outline',
 'Butuh bantuan? Cek pertanyaan yang paling sering muncul di bawah, atau hubungi layanan pelanggan kami.',
 JSON_ARRAY(
   JSON_OBJECT('heading', 'Bagaimana cara memesan?', 'body', 'Pilih outlet di Beranda, buka tab Menu, pilih produk, atur kustomisasi, lalu tekan "+ Keranjang". Setelah itu selesaikan pesanan di halaman Keranjang dan Checkout.'),
   JSON_OBJECT('heading', 'Apakah bisa pesan untuk diantar?', 'body', 'Bisa. Di halaman Pilih Outlet, ubah mode dari Pickup menjadi Delivery, lalu pastikan alamat pengiriman sudah benar.'),
   JSON_OBJECT('heading', 'Bagaimana cara memakai voucher?', 'body', 'Masuk ke halaman Checkout, tekan "Pakai Kode Voucher", dan masukkan kode vouchermu. Voucher juga bisa dilihat di tab Voucher VIP.')
 ),
 'Hubungi Layanan Pelanggan', 'Layanan pelanggan Kopi Kangenan: 0812-3456-7890.', 1, 1, NOW(), NOW()),

(2, 'privacy', 'Kebijakan Privasi', 'menu_book_outlined',
 'Kami menjelaskan data apa saja yang dipakai aplikasi ini dan untuk apa.',
 JSON_ARRAY(
   JSON_OBJECT('heading', 'Data yang disimpan', 'body', 'Versi aplikasi ini hanya menyimpan data di perangkatmu: nama, email atau nomor HP, isi keranjang, alamat, dan riwayat pesanan. Tidak ada data yang dikirim ke server mana pun.'),
   JSON_OBJECT('heading', 'Pemakaian data', 'body', 'Data hanya dipakai untuk menampilkan sapaan, menghitung poin dan level membership, serta melanjutkan proses pemesanan.'),
   JSON_OBJECT('heading', 'Penghapusan data', 'body', 'Menutup aplikasi akan menghapus seluruh data karena semuanya disimpan di memori. Keluar dari akun juga mengembalikan aplikasi ke keadaan tamu.')
 ),
 NULL, NULL, 1, 2, NOW(), NOW()),

(3, 'terms', 'Ketentuan Layanan', 'info_outline',
 'Syarat pemakaian aplikasi Kopi Kangenan.',
 JSON_ARRAY(
   JSON_OBJECT('heading', 'Pemesanan', 'body', 'Pesanan dianggap sah setelah pembayaran berhasil. Nomor pesanan dipakai saat pengambilan di outlet.'),
   JSON_OBJECT('heading', 'Pembatalan', 'body', 'Pesanan bisa dibatalkan selama statusnya belum selesai. Setelah status "Ready", pesanan tidak bisa dibatalkan.'),
   JSON_OBJECT('heading', 'Poin & Voucher', 'body', 'Poin dan voucher bersifat non-tunai, tidak bisa diuangkan, dan hanya berlaku di outlet Kopi Kangenan.')
 ),
 NULL, NULL, 1, 3, NOW(), NOW()),

(4, 'report', 'Lapor Masalah', 'mail_outline',
 'Ada kendala saat memesan? Sampaikan ke kami supaya bisa segera diperbaiki.',
 JSON_ARRAY(
   JSON_OBJECT('heading', 'Email pengaduan', 'body', 'Kirim rincian masalahmu ke halo@kopikangenan.id beserta nomor pesanan kalau ada.'),
   JSON_OBJECT('heading', 'Waktu tanggapan', 'body', 'Laporan dibalas maksimal 1x24 jam pada hari kerja.'),
   JSON_OBJECT('heading', 'Nomor layanan konsumen', 'body', 'Direktorat Jenderal Perlindungan Konsumen dan Tertib Niaga: 0853-1111-1010.')
 ),
 'Kirim Laporan', 'Laporanmu terkirim. Tim kami akan menghubungimu segera.', 1, 4, NOW(), NOW()),

(5, 'whatsapp', 'Layanan WhatsApp', 'support_agent',
 'Chat langsung dengan tim Kopi Kangenan untuk pertanyaan cepat.',
 JSON_ARRAY(
   JSON_OBJECT('heading', 'Nomor layanan', 'body', '0812-3456-7890 (chat saja, tidak menerima panggilan).'),
   JSON_OBJECT('heading', 'Jam layanan', 'body', 'Setiap hari, 07.00 - 22.00 WIB.')
 ),
 'Chat Sekarang', 'Membuka chat WhatsApp Kopi Kangenan… (simulasi)', 1, 5, NOW(), NOW()),

(6, 'about', 'Tentang Kopi Kangenan', 'favorite_border',
 'Kopi kangenan: teman ngopi harian dengan harga bersahabat, dibuat segar setiap pesanan.',
 JSON_ARRAY(
   JSON_OBJECT('heading', 'Versi aplikasi', 'body', '1.0.0 (klon aplikasi, data masih di memori).'),
   JSON_OBJECT('heading', 'Visi', 'body', 'Menghadirkan kopi susu berkualitas dengan pengalaman memesan yang cepat dan menyenangkan.')
 ),
 NULL, NULL, 1, 6, NOW(), NOW());

-- =============================================================================
--  SELESAI — 29 tabel + seed data.
-- =============================================================================
