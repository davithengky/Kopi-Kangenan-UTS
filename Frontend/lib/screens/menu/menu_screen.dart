import 'package:flutter/material.dart';

import '../../models/outlet.dart';
import '../../models/product.dart';
import '../../providers/catalog_store.dart';
import '../../providers/outlet_store.dart';
import '../../providers/voucher_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/category_tabs.dart';
import '../../widgets/diskon_cashback_section.dart';
import '../../widgets/outlet_card.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';
import '../outlet/outlet_picker_screen.dart';
import '../product/product_detail_screen.dart';

/// Halaman Menu.
///
/// Struktur mengikuti aplikasi referensi:
/// kartu outlet di atas (tetap, tidak ikut scroll) → tab kategori → daftar
/// section yang bertumpuk. Tab di atas berfungsi sebagai anchor: tab aktif
/// otomatis mengikuti posisi scroll, dan mengetuk tab akan meluncur ke
/// section yang bersangkutan.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  /// Hanya kategori yang punya produk di [kProductCatalog] yang ditampilkan.
  static const List<String> categories = [
    'Promo & Combo',
    'Baru!',
    'Coffee',
    'Non Coffee',
    'Makanan',
  ];

  /// Kategori yang produknya ditampilkan sebagai carousel horizontal.
  static const String carouselCategory = 'Promo & Combo';

  int selectedCategory = 0;

  final ScrollController _controller = ScrollController();
  final GlobalKey _viewportKey = GlobalKey();
  final Map<String, GlobalKey> _sectionKeys = {
    for (final category in categories) category: GlobalKey(),
  };

  /// Mencegah listener scroll menimpa tab yang baru saja diketuk saat
  /// animasi `ensureVisible` masih berjalan.
  bool _jumpLock = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateActiveCategory);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateActiveCategory);
    _controller.dispose();
    super.dispose();
  }

  /// Menentukan tab aktif dari section terakhir yang header-nya sudah
  /// menyentuh bagian atas area scroll.
  void _updateActiveCategory() {
    if (_jumpLock) return;

    final viewportBox = _viewportKey.currentContext?.findRenderObject();
    if (viewportBox is! RenderBox || !viewportBox.hasSize) return;

    final viewportTop = viewportBox.localToGlobal(Offset.zero).dy;
    int found = 0;

    for (int i = 0; i < categories.length; i++) {
      final sectionContext = _sectionKeys[categories[i]]!.currentContext;
      if (sectionContext == null) continue;

      final box = sectionContext.findRenderObject();
      if (box is! RenderBox || !box.hasSize) continue;

      if (box.localToGlobal(Offset.zero).dy <= viewportTop + 8) {
        found = i;
      }
    }

    if (found != selectedCategory) {
      setState(() => selectedCategory = found);
    }
  }

  void _scrollToCategory(int index) {
    setState(() => selectedCategory = index);

    final sectionContext = _sectionKeys[categories[index]]!.currentContext;
    if (sectionContext == null) return;

    _jumpLock = true;
    Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0,
    ).then((_) {
      if (mounted) _jumpLock = false;
    });
  }

  void _openDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product.toProductMap()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                ValueListenableBuilder<Outlet>(
                  valueListenable: OutletStore.selected,
                  builder: (context, outlet, _) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OutletPickerScreen(),
                        ),
                      ),
                      child: OutletCard(
                        outlet: outlet,
                        trailing: const OutletLogoTile(),
                      ),
                    ),
                  ),
                ),
                CategoryTabs(
                  categories: categories,
                  activeIndex: selectedCategory,
                  onTap: _scrollToCategory,
                ),
                const Divider(height: 1, thickness: 1, color: AppColors.border),
                Expanded(
                  child: SingleChildScrollView(
                    key: _viewportKey,
                    controller: _controller,
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        DiskonCashbackSection(
                          onKlaim: (label) {
                            VoucherStore.claimPromo(label);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Promo $label berhasil diklaim!',
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        for (final category in categories) ..._section(category),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _section(String category) {
    final items = CatalogStore.menuByCategory(category);
    if (items.isEmpty) return const [];

    final isCarousel = category == carouselCategory;

    return <Widget>[
      SectionHeader(key: _sectionKeys[category], title: category),
      if (isCarousel)
        SizedBox(
          height: 216,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final product = items[index];
              return ProductCardHorizontal(
                product: product,
                onTap: () => _openDetail(product),
              );
            },
          ),
        )
      else
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _grid(items),
        ),
      const SizedBox(height: 28),
    ];
  }

  Widget _grid(List<Product> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: 24,
          children: items
              .map(
                (product) => SizedBox(
                  width: itemWidth,
                  child: ProductCardGrid(
                    product: product,
                    onTap: () => _openDetail(product),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
