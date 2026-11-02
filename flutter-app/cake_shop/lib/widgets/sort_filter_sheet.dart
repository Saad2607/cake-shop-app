import 'dart:ui';
import 'package:flutter/material.dart';
import '../providers/cake_provider.dart';
import '../theme/app_theme.dart';

Future<void> showSortFilterSheet(BuildContext context, CakeProvider provider) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2B1D19).withValues(alpha: 0.12),
                blurRadius: 30,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sort Creations', style: AppTheme.titleLarge),
                  if (provider.sortOption != CakeSortOption.recommended)
                    GestureDetector(
                      onTap: () {
                        provider.setSort(CakeSortOption.recommended);
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Reset',
                        style: AppTheme.labelBold.copyWith(
                          color: AppTheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ...CakeSortOption.values.map((option) {
                final selected = provider.sortOption == option;
                return GestureDetector(
                  onTap: () {
                    provider.setSort(option);
                    Navigator.pop(ctx);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primaryLight.withValues(alpha: 0.45)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primary.withValues(alpha: 0.4)
                            : AppTheme.cardBorder,
                        width: 1.2,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [AppTheme.softShadow],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: selected ? AppTheme.primary : AppTheme.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          option.label,
                          style: AppTheme.titleMedium.copyWith(
                            fontSize: 14,
                            color: selected ? AppTheme.primary : AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    ),
  );
}
