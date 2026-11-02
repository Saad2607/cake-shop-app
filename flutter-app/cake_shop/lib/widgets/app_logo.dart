import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Sweet Delights brand mark — tiered artisan cake with ruby cherry & gold sparkle,
/// featuring optional Liquid Glass frosted circular badge with specular highlight.
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

  const AppLogo.splash({super.key})
      : size = 104,
        showCircleBackground = true,
        lightOnDark = true;

  const AppLogo.header({super.key})
      : size = 40,
        showCircleBackground = true,
        lightOnDark = true;

  const AppLogo.auth({super.key})
      : size = 68,
        showCircleBackground = true,
        lightOnDark = false;

  const AppLogo.home({super.key})
      : size = 64,
        showCircleBackground = true,
        lightOnDark = false;

  @override
  Widget build(BuildContext context) {
    final logo = CustomPaint(
      size: Size.square(size * 0.70),
      painter: _SweetDelightsLogoPainter(lightOnDark: lightOnDark),
    );

    if (!showCircleBackground) return logo;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: lightOnDark
                ? Colors.black.withValues(alpha: 0.22)
                : AppTheme.primary.withValues(alpha: 0.18),
            blurRadius: size * 0.26,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: lightOnDark
                    ? [
                        Colors.white.withValues(alpha: 0.32),
                        Colors.white.withValues(alpha: 0.10),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.90),
                        AppTheme.creamDark.withValues(alpha: 0.70),
                      ],
              ),
              border: Border.all(
                color: lightOnDark
                    ? Colors.white.withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.95),
                width: 1.6,
              ),
            ),
            child: Center(child: logo),
          ),
        ),
      ),
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
      ..color = lightOnDark ? Colors.white : const Color(0xFFFFF9FA)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color(0xFF2B1D19).withValues(alpha: 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    final frostingPaint = Paint()
      ..color = lightOnDark ? const Color(0xFFF8C8D4) : const Color(0xFFE88E9E)
      ..style = PaintingStyle.fill;

    final cherryPaint = Paint()..color = AppTheme.primary;
    final cherryHighlightPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);

    final stemPaint = Paint()
      ..color = const Color(0xFF439A52)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;

    final goldPaint = Paint()..color = AppTheme.gold;

    // Bottom tier
    final bottom = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.58, w * 0.76, h * 0.22),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(bottom.shift(const Offset(0, 2)), shadowPaint);
    canvas.drawRRect(bottom, tierPaint);

    // Middle tier
    final middle = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.2, h * 0.42, w * 0.6, h * 0.18),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(middle.shift(const Offset(0, 1.5)), shadowPaint);
    canvas.drawRRect(middle, tierPaint);

    // Top tier
    final top = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.28, w * 0.44, h * 0.16),
      Radius.circular(w * 0.045),
    );
    canvas.drawRRect(top, tierPaint);

    // Frosting drips on middle tier
    final frostingPath = Path()
      ..moveTo(w * 0.2, h * 0.42)
      ..cubicTo(w * 0.28, h * 0.48, w * 0.34, h * 0.40, w * 0.4, h * 0.44)
      ..cubicTo(w * 0.46, h * 0.48, w * 0.52, h * 0.40, w * 0.58, h * 0.44)
      ..cubicTo(w * 0.64, h * 0.48, w * 0.7, h * 0.40, w * 0.8, h * 0.42)
      ..lineTo(w * 0.8, h * 0.46)
      ..lineTo(w * 0.2, h * 0.46)
      ..close();
    canvas.drawPath(frostingPath, frostingPaint);

    // Cherry
    canvas.drawCircle(Offset(cx, h * 0.2), w * 0.075, cherryPaint);
    canvas.drawCircle(Offset(cx - w * 0.025, h * 0.175), w * 0.02, cherryHighlightPaint);

    // Stem
    canvas.drawLine(
      Offset(cx, h * 0.13),
      Offset(cx - w * 0.08, h * 0.06),
      stemPaint,
    );

    // Leaf
    final leafPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - w * 0.1, h * 0.055), w * 0.026, leafPaint);

    // Gold sparkle star
    _drawStar(canvas, Offset(w * 0.78, h * 0.22), w * 0.058, goldPaint);
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
