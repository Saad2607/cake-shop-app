import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Luxury Glass Card surface with subtle blur, white specular borders,
/// and gentle warm-shadow elevation.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final BoxBorder? border;
  final double blur;
  final bool elevated;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius,
    this.onTap,
    Color? backgroundColor,
    Color? color,
    this.borderColor,
    this.border,
    this.blur = 16.0,
    this.elevated = true,
  }) : backgroundColor = backgroundColor ?? color;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppTheme.radiusLg;

    Widget body = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor?.withValues(alpha: 0.9) ?? Colors.white.withValues(alpha: 0.82),
            backgroundColor?.withValues(alpha: 0.7) ?? Colors.white.withValues(alpha: 0.65),
          ],
        ),
        border: border ??
            Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.85),
              width: 1.2,
            ),
      ),
      child: child,
    );

    if (onTap != null) {
      body = Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: body,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: elevated ? [AppTheme.softShadow] : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: body,
        ),
      ),
    );
  }
}
