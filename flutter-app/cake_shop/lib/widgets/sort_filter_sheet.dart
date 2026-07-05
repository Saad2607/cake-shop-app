import 'package:flutter/material.dart';
import '../providers/cake_provider.dart';
import '../theme/app_theme.dart';

Future<void> showSortFilterSheet(BuildContext context, CakeProvider provider) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Sort by', style: AppTheme.titleLarge),
          const SizedBox(height: 12),
          ...CakeSortOption.values.map((option) {
            final selected = provider.sortOption == option;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppTheme.primary : AppTheme.textMuted,
              ),
              title: Text(option.label),
              onTap: () {
                provider.setSort(option);
                Navigator.pop(ctx);
              },
            );
          }),
        ],
      ),
    ),
  );
}
