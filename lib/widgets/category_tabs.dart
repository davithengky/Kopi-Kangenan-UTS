import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tab kategori bergaya teks + garis bawah emas (menggantikan pill chip lama).
///
/// Dipakai di halaman Menu. Tab yang aktif ditandai teks tebal dan garis emas
/// selebar teksnya.
class CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final int activeIndex;
  final ValueChanged<int> onTap;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final active = index == activeIndex;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(index),
            child: Padding(
              padding: EdgeInsets.only(
                right: index == categories.length - 1 ? 0 : 24,
              ),
              // IntrinsicWidth membuat garis bawah otomatis selebar teksnya.
              child: IntrinsicWidth(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      categories[index],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        color: active
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 3,
                      decoration: BoxDecoration(
                        color: active ? AppColors.gold : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
