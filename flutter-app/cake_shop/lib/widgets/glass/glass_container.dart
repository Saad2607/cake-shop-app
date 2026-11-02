import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Reusable Apple Liquid Glass Container with background blur,
/// translucent gradient surface, specular highlight borders, and soft shadows.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? tintColor;
  final Color? borderColor;
  final BoxBorder? border;
  final double borderWidth;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Gradient? gradient;

  const GlassContainer({
    super.key,
    required this.child,
    double? blur,
    double? blurSigma,
    this.opacity = 0.72,
    this.borderRadius,
    this.padding,
    this.margin,
    Color? tintColor,
    Color? color,
    this.borderColor,
    this.border,
    this.borderWidth = 1.0,
    List<BoxShadow>? shadows,
    List<BoxShadow>? boxShadow,
    this.onTap,
    this.width,
    this.height,
    this.alignment,
    this.gradient,
  })  : blur = blur ?? blurSigma ?? 16.0,
        tintColor = tintColor ?? color,
        shadows = shadows ?? boxShadow;

  /// Dense variant for inputs and high-contrast surfaces
  const GlassContainer.dense({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.onTap,
    this.width,
    this.height,
    this.alignment,
  })  : blur = 20.0,
        opacity = 0.88,
        tintColor = null,
        borderColor = null,
        border = null,
        borderWidth = 1.2,
        shadows = null,
        gradient = null;

  /// Frosted blush accent variant for primary callouts and active states
  const GlassContainer.accent({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.onTap,
    this.width,
    this.height,
    this.alignment,
  })  : blur = 18.0,
        opacity = 0.18,
        tintColor = AppTheme.primary,
        borderColor = const Color(0x66C7516B),
        border = null,
        borderWidth = 1.2,
        shadows = null,
        gradient = null;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppTheme.radiusMd;
    final effectiveShadows = shadows ?? [AppTheme.glassShadow];

    Widget content = Container(
      width: width,
      height: height,
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: tintColor != null
                  ? [
                      tintColor!.withValues(alpha: opacity),
                      tintColor!.withValues(alpha: (opacity * 0.7).clamp(0.0, 1.0)),
                    ]
                  : [
                      Colors.white.withValues(alpha: opacity),
                      Colors.white.withValues(alpha: (opacity * 0.75).clamp(0.0, 1.0)),
                    ],
            ),
        border: border ??
            Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.85),
              width: borderWidth,
            ),
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: content,
        ),
      );
    }

    Widget glassBody = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: content,
      ),
    );

    if (effectiveShadows.isNotEmpty) {
      glassBody = Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: effectiveShadows,
        ),
        child: glassBody,
      );
    } else if (margin != null) {
      glassBody = Padding(padding: margin!, child: glassBody);
    }

    return glassBody;
  }
}
