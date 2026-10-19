import 'package:flutter_test/flutter_test.dart';
import 'package:kopken_clone/models/inbox.dart';
import 'package:kopken_clone/models/order.dart';
import 'package:kopken_clone/models/outlet.dart';
import 'package:kopken_clone/models/payment_method.dart';
import 'package:kopken_clone/models/voucher.dart';
import 'package:kopken_clone/providers/address_store.dart';
import 'package:kopken_clone/providers/cart_store.dart';
import 'package:kopken_clone/providers/inbox_store.dart';
import 'package:kopken_clone/providers/member_store.dart';
import 'package:kopken_clone/providers/order_store.dart';
import 'package:kopken_clone/providers/outlet_store.dart';
import 'package:kopken_clone/providers/payment_store.dart';
import 'package:kopken_clone/providers/settings_store.dart';
import 'package:kopken_clone/providers/voucher_store.dart';
import 'package:kopken_clone/utils/strings.dart';

/// Tes untuk store yang baru dibuat: keranjang, outlet, pesanan, poin,
/// voucher, alamat, kotak masuk, metode pembayaran, dan preferensi bahasa.
///
/// Semuanya hanya hidup di memori, jadi setiap tes mengembalikannya ke keadaan
/// awal lebih dulu lewat `reset()` masing-masing store.

/// Membuat satu item keranjang dengan harga satuan [price].
CartItem item(String name, int price, {int quantity = 1}) {
  return CartItem(
    name: name,
    image: 'assets/tester.png',
    basePrice: price,
    quantity: quantity,
    size: 'Regular',
    milk: 'Milk',
    sugar: 'Normal Sugar',
    ice: 'Normal Ice',
    toppings: const <String>[],
    syrups: const <String>[],
    unitPrice: price,
  );
}

void main() {
  group('CartStore', () {
    setUp(CartStore.clear);

    test('menambah, menghitung, dan mengosongkan keranjang', () {
      expect(CartStore.isEmpty, isTrue);

      CartStore.add(item('Taro Cloud Latte', 28000));
      CartStore.add(item('Butterscotch', 25000, quantity: 2));

      expect(CartStore.items.value.length, 2);
      expect(CartStore.totalQuantity, 3);
      expect(CartStore.totalPrice, 78000);
    });

    test('updateQuantity mengubah jumlah dan menghapus saat nol', () {
      CartStore.add(item('Taro Cloud Latte', 28000));

      CartStore.updateQuantity(0, 3);
      expect(CartStore.items.value.first.quantity, 3);
      expect(CartStore.totalPrice, 84000);

      CartStore.updateQuantity(0, 0);
      expect(CartStore.isEmpty, isTrue);
    });

    test('replaceAt menukar item dan removeAt membuangnya', () {
      CartStore.add(item('Taro Cloud Latte', 28000));
      CartStore.add(item('Butterscotch', 25000));

      CartStore.replaceAt(0, item('Ganti Jadi Ini', 30000));
      expect(CartStore.items.value.first.name, 'Ganti Jadi Ini');

      CartStore.removeAt(1);
      expect(CartStore.items.value.length, 1);

      // Indeks di luar jangkauan diabaikan, bukan melempar error.
      CartStore.removeAt(9);
      CartStore.updateQuantity(-1, 5);
      expect(CartStore.items.value.length, 1);
    });

    test('catatan tambahan ikut tampil di ringkasan kustomisasi', () {
      final withNote = CartItem(
        name: 'Taro Cloud Latte',
        image: 'assets/tester.png',
        basePrice: 28000,
        quantity: 1,
        size: 'Regular',
        milk: 'Milk',
        sugar: 'Normal Sugar',
        ice: 'Normal Ice',
        toppings: const ['Boba'],
        syrups: const <String>[],
        unitPrice: 28000,
        note: 'Ga perlu baper',
      );

      expect(withNote.customizationLines, contains('Boba'));
      expect(withNote.customizationLines, contains('Ga perlu baper'));
    });
  });

  group('OutletStore', () {
    setUp(OutletStore.reset);

    test('default Tunjungan Plaza 3 mode pickup', () {
      expect(OutletStore.selected.value.name, 'Tunjungan Plaza 3');
      expect(OutletStore.mode.value, FulfilmentMode.pickup);
      expect(OutletStore.mode.value.label, 'Pickup');
    });

    test('bisa pindah outlet dan mode', () {
      OutletStore.select(kOutlets[1]);
      OutletStore.setMode(FulfilmentMode.delivery);

      expect(OutletStore.selected.value.name, 'Ketintang UNESA');
      expect(OutletStore.mode.value, FulfilmentMode.delivery);

      OutletStore.reset();
      expect(OutletStore.selected.value, kDefaultOutlet);
    });
  });

  group('MemberStore', () {
    setUp(MemberStore.reset);

    test('level naik seiring total belanja', () {
      expect(MemberStore.level, MemberLevel.silver);
      expect(MemberStore.remainingToNextLevel, 700000);
      expect(MemberStore.levelProgress, 0);

      MemberStore.registerSpend(350000, '#tes');
      expect(MemberStore.level, MemberLevel.silver);
      expect(MemberStore.levelProgress, closeTo(0.5, 0.001));

      MemberStore.registerSpend(350000, '#tes');
      expect(MemberStore.level, MemberLevel.gold);
      expect(MemberStore.remainingToNextLevel, 9999999 - 700000);

      MemberStore.registerSpend(9999999, '#tes');
      expect(MemberStore.level, MemberLevel.black);
      expect(MemberStore.level.isHighest, isTrue);
      expect(MemberStore.remainingToNextLevel, 0);
    });

    test('1 poin didapat tiap Rp1.000 belanja', () {
      final earned = MemberStore.registerSpend(28500, '#1002');
      expect(earned, 28);
      expect(MemberStore.points.value, 28);
      expect(MemberStore.history.value.first.title, contains('#1002'));
    });

    test('redeemPoints tidak bisa melebihi poin yang dimiliki', () {
      MemberStore.addPoints(100, 'tes');
      MemberStore.redeemPoints(150, 'redeem tes');

      expect(MemberStore.points.value, 0);
      expect(MemberStore.history.value.first.delta, -100);
    });

    test('Daily Check-In berjalan 6 hari lalu berhenti', () {
      for (int day = 1; day <= MemberStore.maxCheckInDays; day++) {
        final reward = MemberStore.checkIn();
        expect(reward, isNotEmpty);
      }

      expect(MemberStore.checkedDays.value.length, 6);
      expect(MemberStore.canCheckInToday, isFalse);

      // Poin: hari 1, 2, 4, 5 memberi +25; hari 3 & 6 memberi voucher.
      expect(MemberStore.points.value, 100);
      expect(MemberStore.checkIn(), contains('check-in 6 hari'));
      expect(MemberStore.checkedDays.value.length, 6);
    });
  });

  group('Voucher', () {
    test('discountFor menghormati minimum pembelian', () {
      expect(VoucherStore.demoVoucher.discountFor(20000), 0);
      expect(VoucherStore.demoVoucher.discountFor(50000), 5000);
      expect(VoucherStore.demoVoucher.isApplicable(20000), isFalse);

      const gratis = Voucher(
        code: 'X',
        title: 'Gratis',
        description: '-',
        amount: 25000,
      );
      // Potongan tidak boleh melebihi subtotal.
      expect(gratis.discountFor(10000), 10000);
    });

    group('VoucherStore', () {
      setUp(VoucherStore.reset);

      test('kode demo langsung masuk ke akun', () {
        final voucher = VoucherStore.validateCode(' kangenan10 ');

        expect(voucher.code, 'KANGENAN10');
        expect(VoucherStore.userVouchers.value.length, 1);
      });

      test('kode kosong dan kode asing ditolak', () {
        expect(
          () => VoucherStore.validateCode('   '),
          throwsA(isA<VoucherException>()),
        );
        expect(
          () => VoucherStore.validateCode('TIDAKADA'),
          throwsA(
            isA<VoucherException>().having(
              (error) => error.message,
              'message',
              contains('tidak dikenal'),
            ),
          ),
        );
      });

      test('Buy Pack menambah voucher ke akun', () {
        VoucherStore.buyPack(kVoucherPacks.first);

        expect(VoucherStore.ownedPacks.value.length, 1);
        expect(VoucherStore.userVouchers.value.length, 3);
        expect(
          VoucherStore.userVouchers.value.map((voucher) => voucher.code),
          contains('${kVoucherPacks.first.id}-10'),
        );
      });

      test('claimPromo tidak menggandakan label yang sama', () {
        VoucherStore.claimPromo('Buy 1 Get 1');
        VoucherStore.claimPromo('Buy 1 Get 1');

        expect(VoucherStore.hasClaimedBuyOneGetOne, isTrue);
        expect(VoucherStore.claimedPromos.value.length, 1);
      });
    });
  });

  group('OrderStore', () {
    setUp(() {
      OrderStore.clear();
      MemberStore.reset();
    });

    test('create menghitung total, poin, dan status awal', () {
      OrderStore.seed();
      MemberStore.addPoints(5000, 'tes');

      final order = OrderStore.create(
        items: [item('Taro Cloud Latte', 28000, quantity: 2)],
        subtotal: 56000,
        bagFee: 200,
        voucherDiscount: 5600,
        pointsUsed: 1000,
        paymentMethod: 'qris',
        fulfilment: 'Pickup',
      );

      expect(order.total, 56000 + 200 - 5600 - 1000);
      expect(order.status, OrderStatus.pending);
      expect(order.id, isNot('#1001'), reason: 'nomor tidak boleh kembar');

      // Poin dipakai lalu poin baru didapat dari total pesanan.
      final earned = order.total ~/ 1000;
      expect(MemberStore.points.value, 5000 - 1000 + earned);
      expect(OrderStore.orders.value.first.id, order.id);
      expect(OrderStore.findById(order.id), isNotNull);
    });

    test('advance memajukan status sampai Completed', () {
      final order = OrderStore.create(
        items: [item('Taro Cloud Latte', 28000)],
        subtotal: 28000,
        bagFee: 0,
        voucherDiscount: 0,
        pointsUsed: 0,
        paymentMethod: 'qris',
        fulfilment: 'Pickup',
      );

      OrderStore.advance(order.id);
      expect(OrderStore.findById(order.id)!.status, OrderStatus.processing);

      OrderStore.advance(order.id);
      expect(OrderStore.findById(order.id)!.status, OrderStatus.ready);

      OrderStore.advance(order.id);
      expect(OrderStore.findById(order.id)!.status, OrderStatus.completed);
      expect(OrderStore.findById(order.id)!.status.isFinal, isTrue);

      // Pesanan yang sudah selesai tidak berubah lagi.
      OrderStore.advance(order.id);
      expect(OrderStore.findById(order.id)!.status, OrderStatus.completed);
    });

    test('cancel hanya berlaku untuk pesanan yang belum final', () {
      OrderStore.seed();
      final seeded = OrderStore.findById('#1001')!;
      expect(seeded.status, OrderStatus.completed);

      OrderStore.cancel('#1001');
      expect(
        OrderStore.findById('#1001')!.status,
        OrderStatus.completed,
        reason: 'pesanan contoh sudah final',
      );

      final order = OrderStore.create(
        items: [item('Taro Cloud Latte', 28000)],
        subtotal: 28000,
        bagFee: 0,
        voucherDiscount: 0,
        pointsUsed: 0,
        paymentMethod: 'qris',
        fulfilment: 'Delivery',
      );

      OrderStore.cancel(order.id);
      expect(OrderStore.findById(order.id)!.status, OrderStatus.cancelled);
    });
  });

  group('AddressStore', () {
    setUp(AddressStore.reset);

    test('alamat contoh jadi alamat utama', () {
      expect(AddressStore.defaultAddress!.label, 'Rumah');
    });

    test('tambah, jadikan utama, lalu hapus', () {
      final kantor = AddressStore.add(
        label: 'Kantor',
        recipient: 'Jibi',
        phone: '0812-0000-1111',
        detail: 'Jl. Darmo No. 5',
      );

      expect(AddressStore.addresses.value.length, 2);
      expect(AddressStore.defaultAddress!.label, 'Rumah');

      AddressStore.setDefault(kantor.id);
      expect(AddressStore.defaultAddress!.label, 'Kantor');

      AddressStore.remove(kantor.id);
      expect(AddressStore.addresses.value.length, 1);
      expect(AddressStore.defaultAddress!.label, 'Rumah');
    });
  });

  group('InboxStore', () {
    setUp(InboxStore.reset);

    test('menghitung pesan belum dibaca lalu menandainya', () {
      expect(InboxStore.unreadCount, 2);

      InboxStore.markRead('msg-1');
      expect(InboxStore.unreadCount, 1);

      InboxStore.markAllRead();
      expect(InboxStore.unreadCount, 0);
    });

    test('pesan baru muncul di paling atas', () {
      InboxStore.add(
        const InboxMessage(
          id: 'msg-baru',
          title: 'Promo baru',
          body: 'Cek sekarang',
          date: 'Baru saja',
        ),
      );

      expect(InboxStore.messages.value.first.id, 'msg-baru');
      expect(InboxStore.unreadCount, 3);

      InboxStore.remove('msg-baru');
      expect(InboxStore.messages.value.first.id, 'msg-1');
    });
  });

  group('PaymentStore', () {
    setUp(PaymentStore.reset);

    test('default QRIS dan metode tanpa koneksi bisa langsung dipakai', () {
      expect(PaymentStore.selected.id, 'qris');

      PaymentStore.select(kPaymentMethods.firstWhere((m) => m.id == 'blu'));
      expect(PaymentStore.selected.id, 'blu');
    });

    test('GoPay harus dihubungkan dulu', () {
      final gopay = kPaymentMethods.firstWhere((m) => m.id == 'gopay');
      expect(PaymentStore.isConnected(gopay), isFalse);

      PaymentStore.select(gopay);
      expect(
        PaymentStore.selected.id,
        'qris',
        reason: 'belum terhubung, jadi pilihan tidak berubah',
      );

      PaymentStore.connect(gopay.id);
      PaymentStore.select(gopay);
      expect(PaymentStore.selected.id, 'gopay');
    });
  });

  group('SettingsStore', () {
    setUp(SettingsStore.reset);

    test('bahasa default Indonesia dan label bottom nav tetap sama', () {
      expect(SettingsStore.language.value, AppLanguage.indonesia);
      expect(Strings.beranda(AppLanguage.indonesia), 'Beranda');
      expect(Strings.menu(AppLanguage.indonesia), 'Menu');
      expect(Strings.vip(AppLanguage.indonesia), 'VIP');
      expect(Strings.merch(AppLanguage.indonesia), 'Merch');
      expect(Strings.saya(AppLanguage.indonesia), 'Saya');
      expect(Strings.beranda(AppLanguage.english), 'Home');
    });
  });
}
