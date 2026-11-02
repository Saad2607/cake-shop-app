import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'glass_container.dart';
import 'glass_icon_button.dart';

/// Liquid Glass Search Bar with frosted glass styling,
/// active filter trigger button, and clear actions.
class GlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;
  final String hintText;
  final bool hasActiveFilter;

  const GlassSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onFilterTap,
    this.hintText = 'Search cakes, flavors, occasions…',
    this.hasActiveFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassContainer.dense(
            borderRadius: AppTheme.radiusPill,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: AppTheme.primary.withValues(alpha: 0.8),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    style: AppTheme.bodyMedium.copyWith(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textMuted.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      isDense: true,
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      controller.clear();
                      onClear?.call();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.textMuted.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (onFilterTap != null) ...[
          const SizedBox(width: 10),
          GlassIconButton(
            icon: Icons.tune_rounded,
            size: 46,
            iconSize: 20,
            active: hasActiveFilter,
            onTap: onFilterTap,
            tooltip: 'Filter & Sort',
          ),
        ],
      ],
    );
  }
}
