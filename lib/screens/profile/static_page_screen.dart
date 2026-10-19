import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/ui.dart';

/// Satu bagian teks pada halaman statis.
class StaticSection {
  final String heading;
  final String body;

  const StaticSection(this.heading, this.body);
}

/// Halaman informasi statis: Bantuan, Kebijakan Privasi, Ketentuan Layanan,
/// Lapor Masalah, Layanan WhatsApp, dan Tentang Kopi Kangenan (PRD F14).
class StaticPageScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String intro;
  final List<StaticSection> sections;
  final String? ctaLabel;
  final String? ctaMessage;

  const StaticPageScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.intro,
    required this.sections,
    this.ctaLabel,
    this.ctaMessage,
  });

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: title,
      children: [
        AppCard(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.pink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.maroon, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  intro,
                  style: const TextStyle(fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final section in sections) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.heading,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  section.body,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.65,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (ctaLabel != null)
          AppPrimaryButton(
            label: ctaLabel!,
            onPressed: () => showAppMessage(context, ctaMessage ?? ''),
          ),
      ],
    );
  }
}

// --- Halaman siap pakai untuk tiap menu di Profil --- //

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticPageScreen(
      title: 'Bantuan',
      icon: Icons.help_outline,
      intro:
          'Butuh bantuan? Cek pertanyaan yang paling sering muncul di bawah, '
          'atau hubungi layanan pelanggan kami.',
      sections: [
        StaticSection(
          'Bagaimana cara memesan?',
          'Pilih outlet di Beranda, buka tab Menu, pilih produk, atur '
              'kustomisasi, lalu tekan "+ Keranjang". Setelah itu selesaikan '
              'pesanan di halaman Keranjang dan Checkout.',
        ),
        StaticSection(
          'Apakah bisa pesan untuk diantar?',
          'Bisa. Di halaman Pilih Outlet, ubah mode dari Pickup menjadi '
              'Delivery, lalu pastikan alamat pengiriman sudah benar.',
        ),
        StaticSection(
          'Bagaimana cara memakai voucher?',
          'Masuk ke halaman Checkout, tekan "Pakai Kode Voucher", dan masukkan '
              'kode vouchermu. Voucher juga bisa dilihat di tab Voucher VIP.',
        ),
      ],
      ctaLabel: 'Hubungi Layanan Pelanggan',
      ctaMessage: 'Layanan pelanggan Kopi Kangenan: 0812-3456-7890.',
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticPageScreen(
      title: 'Kebijakan Privasi',
      icon: Icons.menu_book_outlined,
      intro:
          'Kami menjelaskan data apa saja yang dipakai aplikasi ini dan untuk '
          'apa.',
      sections: [
        StaticSection(
          'Data yang disimpan',
          'Versi aplikasi ini hanya menyimpan data di perangkatmu: nama, email '
              'atau nomor HP, isi keranjang, alamat, dan riwayat pesanan. Tidak '
              'ada data yang dikirim ke server mana pun.',
        ),
        StaticSection(
          'Pemakaian data',
          'Data hanya dipakai untuk menampilkan sapaan, menghitung poin dan '
              'level membership, serta melanjutkan proses pemesanan.',
        ),
        StaticSection(
          'Penghapusan data',
          'Menutup aplikasi akan menghapus seluruh data karena semuanya '
              'disimpan di memori. Keluar dari akun juga mengembalikan '
              'aplikasi ke keadaan tamu.',
        ),
      ],
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticPageScreen(
      title: 'Ketentuan Layanan',
      icon: Icons.info_outline,
      intro: 'Syarat pemakaian aplikasi Kopi Kangenan.',
      sections: [
        StaticSection(
          'Pemesanan',
          'Pesanan dianggap sah setelah pembayaran berhasil. Nomor pesanan '
              'dipakai saat pengambilan di outlet.',
        ),
        StaticSection(
          'Pembatalan',
          'Pesanan bisa dibatalkan selama statusnya belum selesai. Setelah '
              'status "Ready", pesanan tidak bisa dibatalkan.',
        ),
        StaticSection(
          'Poin & Voucher',
          'Poin dan voucher bersifat non-tunai, tidak bisa diuangkan, dan hanya '
              'berlaku di outlet Kopi Kangenan.',
        ),
      ],
    );
  }
}

class ReportProblemScreen extends StatelessWidget {
  const ReportProblemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticPageScreen(
      title: 'Lapor Masalah',
      icon: Icons.mail_outline,
      intro:
          'Ada kendala saat memesan? Sampaikan ke kami supaya bisa segera '
          'diperbaiki.',
      sections: [
        StaticSection(
          'Email pengaduan',
          'Kirim rincian masalahmu ke halo@kopikangenan.id beserta nomor '
              'pesanan kalau ada.',
        ),
        StaticSection(
          'Waktu tanggapan',
          'Laporan dibalas maksimal 1x24 jam pada hari kerja.',
        ),
        StaticSection(
          'Nomor layanan konsumen',
          'Direktorat Jenderal Perlindungan Konsumen dan Tertib Niaga: '
              '0853-1111-1010.',
        ),
      ],
      ctaLabel: 'Kirim Laporan',
      ctaMessage: 'Laporanmu terkirim. Tim kami akan menghubungimu segera.',
    );
  }
}

class WhatsappServiceScreen extends StatelessWidget {
  const WhatsappServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticPageScreen(
      title: 'Layanan WhatsApp',
      icon: Icons.support_agent,
      intro:
          'Chat langsung dengan tim Kopi Kangenan untuk pertanyaan cepat.',
      sections: [
        StaticSection(
          'Nomor layanan',
          '0812-3456-7890 (chat saja, tidak menerima panggilan).',
        ),
        StaticSection(
          'Jam layanan',
          'Setiap hari, 07.00 - 22.00 WIB.',
        ),
      ],
      ctaLabel: 'Chat Sekarang',
      ctaMessage: 'Membuka chat WhatsApp Kopi Kangenan… (simulasi)',
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticPageScreen(
      title: 'Tentang Kopi Kangenan',
      icon: Icons.favorite_border,
      intro:
          'Kopi kangenan: teman ngopi harian dengan harga bersahabat, dibuat '
          'segar setiap pesanan.',
      sections: [
        StaticSection(
          'Versi aplikasi',
          '1.0.0 (klon aplikasi, data masih di memori).',
        ),
        StaticSection(
          'Visi',
          'Menghadirkan kopi susu berkualitas dengan pengalaman memesan yang '
              'cepat dan menyenangkan.',
        ),
      ],
    );
  }
}
