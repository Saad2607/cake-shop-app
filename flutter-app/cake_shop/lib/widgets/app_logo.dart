import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Sweet Delights brand mark — tiered cake with cherry & gold accent.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showCircleBackground;
  final bool lightOnDark;

  const AppLogo({
    super.key,
    this.size = 64,
    this.showCircleBackground = false,
    this.lightOnDark = false,
  });

  const AppLogo.splash({super.key}) : size = 100, showCircleBackground = true, lightOnDark = true;

  const AppLogo.header({super.key}) : size = 36, showCircleBackground = false, lightOnDark = true;

  const AppLogo.auth({super.key}) : size = 64, showCircleBackground = true, lightOnDark = true;

  @override
  Widget build(BuildContext context) {
    final logo = CustomPaint(
      size: Size.square(size * 0.72),
      painter: _SweetDelightsLogoPainter(lightOnDark: lightOnDark),
    );

    if (!showCircleBackground) return logo;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: lightOnDark
              ? [
                  Colors.white.withValues(alpha: 0.28),
                  Colors.white.withValues(alpha: 0.08),
                ]
              : [
                  AppTheme.primaryLight.withValues(alpha: 0.55),
                  Colors.white,
                ],
        ),
        border: Border.all(
          color: lightOnDark
              ? Colors.white.withValues(alpha: 0.35)
              : AppTheme.primary.withValues(alpha: 0.15),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.18),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Center(child: logo),
    );
  }
}

class _SweetDelightsLogoPainter extends CustomPainter {
  final bool lightOnDark;

  const _SweetDelightsLogoPainter({required this.lightOnDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final tierPaint = Paint()
      ..color = lightOnDark ? Colors.white : const Color(0xFFFFF8FA)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = AppTheme.primaryDark.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final frostingPaint = Paint()
      ..color = lightOnDark ? const Color(0xFFF8BBD0) : AppTheme.primaryLight
      ..style = PaintingStyle.fill;

    final cherryPaint = Paint()..color = AppTheme.primary;
    final stemPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;

    final goldPaint = Paint()..color = AppTheme.gold;

    final bottom = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.58, w * 0.76, h * 0.22),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(bottom.shift(const Offset(0, 2)), shadowPaint);
    canvas.drawRRect(bottom, tierPaint);

    final middle = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.2, h * 0.42, w * 0.6, h * 0.18),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(middle, tierPaint);

    final top = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.28, w * 0.44, h * 0.16),
      Radius.circular(w * 0.045),
    );
    canvas.drawRRect(top, tierPaint);

    final frostingPath = Path()
      ..moveTo(w * 0.2, h * 0.42)
      ..cubicTo(w * 0.28, h * 0.48, w * 0.34, h * 0.4, w * 0.4, h * 0.44)
      ..cubicTo(w * 0.46, h * 0.48, w * 0.52, h * 0.4, w * 0.58, h * 0.44)
      ..cubicTo(w * 0.64, h * 0.48, w * 0.7, h * 0.4, w * 0.8, h * 0.42)
      ..lineTo(w * 0.8, h * 0.46)
      ..lineTo(w * 0.2, h * 0.46)
      ..close();
    canvas.drawPath(frostingPath, frostingPaint);

    canvas.drawCircle(Offset(cx, h * 0.2), w * 0.07, cherryPaint);
    canvas.drawLine(
      Offset(cx, h * 0.13),
      Offset(cx - w * 0.08, h * 0.06),
      stemPaint,
    );
    final leafPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - w * 0.1, h * 0.055), w * 0.025, leafPaint);

    _drawStar(canvas, Offset(w * 0.78, h * 0.22), w * 0.055, goldPaint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    const points = 4;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * 0.42;
      final angle = (i * math.pi / points) - math.pi / 2;
      final point = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SweetDelightsLogoPainter oldDelegate) =>
      oldDelegate.lightOnDark != lightOnDark;
}
