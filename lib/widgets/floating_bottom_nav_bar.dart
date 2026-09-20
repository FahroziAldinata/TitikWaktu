import 'package:flutter/material.dart';
import 'package:titik_waktu/theme/app_colors.dart';

class NavItemData {
  final IconData icon;
  final String label;

  const NavItemData({
    required this.icon,
    required this.label,
  });
}

class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<NavItemData> items = [
    NavItemData(
      icon: Icons.grid_view_rounded,
      label: 'Kategori',
    ),
    NavItemData(
      icon: Icons.home_rounded,
      label: 'Home',
    ),
    NavItemData(
      icon: Icons.settings_rounded,
      label: 'Pengaturan',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Background pill container: surface gelap #1C1C1A / dark surface
    final containerBg = isDark ? const Color(0xFF1E1D1A) : const Color(0xFF1C1C1A);
    // Indikator amber di atas container gelap: kontras tinggi & premium
    final activeIndicatorColor = isDark ? AppColors.amberDarkIndicator : const Color(0xFFFAC775);
    final activeContentColor = const Color(0xFF1C1C1A);
    const inactiveIconColor = Color(0xFF8A8985);
    final borderColor = isDark ? AppColors.darkBorder : const Color(0x3333322D);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: containerBg,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: borderColor,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.22),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const horizontalPadding = 6.0;
              const verticalPadding = 6.0;
              final usableWidth = constraints.maxWidth - (horizontalPadding * 2);
              final tabWidth = usableWidth / items.length;

              return Stack(
                children: [
                  // 1. Sliding Amber Indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack,
                    left: horizontalPadding + (currentIndex * tabWidth) + 2,
                    top: verticalPadding,
                    bottom: verticalPadding,
                    width: tabWidth - 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: activeIndicatorColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: activeIndicatorColor.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Tab Items Row (Touch targets & Icons/Labels)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      child: Row(
                        children: List.generate(items.length, (index) {
                          final item = items[index];
                          final isSelected = currentIndex == index;

                          return Expanded(
                            child: GestureDetector(
                              key: ValueKey('nav_item_$index'),
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onTap(index),
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  switchInCurve: Curves.easeOut,
                                  switchOutCurve: Curves.easeIn,
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  child: isSelected
                                      ? Row(
                                          key: ValueKey('active_$index'),
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              item.icon,
                                              size: 19,
                                              color: activeContentColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                item.label,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: activeContentColor,
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: -0.2,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Icon(
                                          key: ValueKey('inactive_$index'),
                                          item.icon,
                                          size: 22,
                                          color: inactiveIconColor,
                                        ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
