import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? bottom;
  final bool showBack;

  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.bottom,
    this.showBack = false,
  });

  @override
  Size get preferredSize {
    var height = kToolbarHeight + 20.0;
    if (subtitle != null) height += 22;
    if (bottom != null) height += 56;
    return Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 12, 16),
              child: Row(
                children: [
                  if (showBack)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTheme.displayMedium.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                      ],
                    ),
                  ),
                  ...?actions,
                ],
              ),
            ),
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }
}
