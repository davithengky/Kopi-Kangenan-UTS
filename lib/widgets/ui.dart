import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Header halaman dalam: tinggi 56, tombol kembali di kiri, judul di tengah.
class AppPageHeader extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  /// Kalau false, tombol kembali disembunyikan (mis. untuk tab).
  final bool showBack;

  const AppPageHeader({
    super.key,
    required this.title,
    this.actions = const <Widget>[],
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back, size: 24),
              tooltip: 'Kembali',
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (actions.isEmpty)
            const SizedBox(width: 48)
          else
            Row(mainAxisSize: MainAxisSize.min, children: actions),
        ],
      ),
    );
  }
}

/// Halaman standar dalam aplikasi: latar abu, dibatasi 390 px, dengan header
/// dan (opsional) bilah tombol tetap di bawah.
class AppPage extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final List<Widget> actions;
  final Widget? bottomBar;
  final EdgeInsets padding;
  final bool showBack;

  /// Kalau true, isi halaman dibungkus `SingleChildScrollView`.
  final bool scrollable;

  const AppPage({
    super.key,
    required this.title,
    required this.children,
    this.actions = const <Widget>[],
    this.bottomBar,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 24),
    this.showBack = true,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.surfaceProfile,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Column(
              children: [
                AppPageHeader(
                  title: title,
                  actions: actions,
                  showBack: showBack,
                ),
                Expanded(
                  child: scrollable
                      ? SingleChildScrollView(child: content)
                      : content,
                ),
                ?bottomBar,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu putih standar: radius 16, border tipis, tanpa bayangan berat.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      // `ListTile` (dan turunannya seperti `CheckboxListTile` dan
      // `SwitchListTile`) melukis latar serta ripple-nya di `Material`
      // terdekat. Karena kartu ini adalah `DecoratedBox` berwarna, tile-nya
      // wajib punya `Material` sendiri supaya ripple tetap terlihat dan
      // asersi debug Flutter tidak terpicu.
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}

/// Tombol utama halaman: lebar penuh, tinggi 48, radius 12.
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color background;
  final IconData? icon;

  /// Radius sudut: **12** untuk form/checkout, **8** untuk tombol di dalam
  /// konten (`docs/design.md` §6).
  final double radius;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.background = AppColors.action,
    this.icon,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Tombol sekunder bergaris.
class AppOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icon;

  const AppOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.maroon,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// Keadaan kosong yang ramah: ikon, judul, keterangan, dan satu tombol aksi.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70, color: AppColors.borderSoft),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              AppPrimaryButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

/// Baris "label — nilai" yang dipakai di halaman ringkasan/checkout.
class AppLabelValue extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const AppLabelValue({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 15 : 13,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: bold ? AppColors.textPrimary : AppColors.textSecondary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bilah tombol tetap di bagian bawah halaman, dengan garis pemisah di atas.
class AppBottomBar extends StatelessWidget {
  final Widget child;

  const AppBottomBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.borderSoft)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Judul kecil abu-abu di atas sekelompok isi.
class AppSectionLabel extends StatelessWidget {
  final String text;

  const AppSectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Menampilkan SnackBar lewat cara yang seragam di seluruh aplikasi.
void showAppMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}
