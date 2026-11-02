import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GlassNavItem {
  final IconData? icon;
  final IconData? activeIcon;
  final String label;
  final int? badgeCount;
  final Widget? customIcon;
  final Widget? activeCustomIcon;

  const GlassNavItem({
    this.icon,
    this.activeIcon,
    required this.label,
    this.badgeCount,
    this.customIcon,
    this.activeCustomIcon,
  });

  /// Creates an avatar nav item showing the user's initial
  factory GlassNavItem.avatar({
    required String initial,
    required String label,
  }) {
    final letter = initial.trim().isNotEmpty ? initial.trim()[0].toUpperCase() : 'U';
    return GlassNavItem(
      label: label,
      customIcon: _buildAvatarDisc(letter, false),
      activeCustomIcon: _buildAvatarDisc(letter, true),
    );
  }

  static Widget _buildAvatarDisc(String letter, bool active) {
    return Container(
      width: 23,
      height: 23,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: active ? AppTheme.ctaGradient : null,
        color: active ? null : AppTheme.primaryLight.withValues(alpha: 0.65),
        border: Border.all(
          color: active ? Colors.white : AppTheme.primary.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: active ? Colors.white : AppTheme.primary,
          height: 1.1,
        ),
      ),
    );
  }
}

/// Floating Liquid Glass Bottom Navigation Bar with Apple-inspired blur,
/// animated active indicator pill, specular highlights, and badge counters.
class GlassBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<GlassNavItem> items;

  const GlassBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2B1D19).withValues(alpha: 0.10),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.90),
                      Colors.white.withValues(alpha: 0.75),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.94),
                    width: 1.4,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isSelected = selectedIndex == index;
                    return Expanded(
                      child: _NavItemWidget(
                        item: item,
                        isSelected: isSelected,
                        onTap: () => onItemSelected(index),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemWidget extends StatelessWidget {
  final GlassNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeIcon = item.activeIcon ?? item.icon ?? Icons.circle;
    final iconData = isSelected ? activeIcon : (item.icon ?? Icons.circle);

    final Widget iconWidget = item.customIcon != null
        ? (isSelected ? (item.activeCustomIcon ?? item.customIcon!) : item.customIcon!)
        : Icon(
            iconData,
            size: 21,
            color: isSelected ? AppTheme.primary : AppTheme.textMuted,
          );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 8 : 4,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.15),
                    AppTheme.primaryLight.withValues(alpha: 0.40),
                  ],
                )
              : null,
          border: isSelected
              ? Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.25),
                  width: 1,
                )
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.06 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: iconWidget,
                ),
                if (item.badgeCount != null && item.badgeCount! > 0)
                  Positioned(
                    top: -5,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.ctaGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 15,
                        minHeight: 15,
                      ),
                      child: Text(
                        '${item.badgeCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                    fontFamily: AppTheme.titleMedium.fontFamily,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
