import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';

enum CakeShape { round, heart, square, multiTier }

enum FrostingFlavor {
  belgianChocolate,
  blushRose,
  vanillaBean,
  pistachioCream,
}

enum CakeTopping {
  macarons,
  goldLeaf,
  freshBerries,
  ferreroRocher,
}

class CakeCanvasPainter extends CustomPainter {
  final CakeShape shape;
  final FrostingFlavor flavor;
  final Set<CakeTopping> toppings;
  final String? customMessage;
  final File? photoFile;

  CakeCanvasPainter({
    required this.shape,
    required this.flavor,
    required this.toppings,
    this.customMessage,
    this.photoFile,
  });

  Color _getPrimaryColor() {
    switch (flavor) {
      case FrostingFlavor.belgianChocolate:
        return const Color(0xFF3E2723);
      case FrostingFlavor.blushRose:
        return const Color(0xFFE892A2);
      case FrostingFlavor.vanillaBean:
        return const Color(0xFFFFF6E5);
      case FrostingFlavor.pistachioCream:
        return const Color(0xFFA8C69F);
    }
  }

  Color _getDarkColor() {
    switch (flavor) {
      case FrostingFlavor.belgianChocolate:
        return const Color(0xFF261714);
      case FrostingFlavor.blushRose:
        return const Color(0xFFC7516B);
      case FrostingFlavor.vanillaBean:
        return const Color(0xFFEADBBE);
      case FrostingFlavor.pistachioCream:
        return const Color(0xFF75996B);
    }
  }

  Color _getHighlightColor() {
    switch (flavor) {
      case FrostingFlavor.belgianChocolate:
        return const Color(0xFF5D4037);
      case FrostingFlavor.blushRose:
        return const Color(0xFFFDE4E9);
      case FrostingFlavor.vanillaBean:
        return Colors.white;
      case FrostingFlavor.pistachioCream:
        return const Color(0xFFCDE2C6);
    }
  }

  Color _getMessageColor() {
    switch (flavor) {
      case FrostingFlavor.belgianChocolate:
        return const Color(0xFFFFF7F0);
      case FrostingFlavor.blushRose:
        return const Color(0xFF4A1521);
      case FrostingFlavor.vanillaBean:
        return const Color(0xFF4E2C22);
      case FrostingFlavor.pistachioCream:
        return const Color(0xFF233B1E);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.52;

    _drawPedestal(canvas, cx, cy + 85, size.width * 0.46);

    switch (shape) {
      case CakeShape.round:
        _drawRoundCake(canvas, cx, cy, 110, 68);
        break;
      case CakeShape.heart:
        _drawHeartCake(canvas, cx, cy, 110, 68);
        break;
      case CakeShape.square:
        _drawSquareCake(canvas, cx, cy, 100, 68);
        break;
      case CakeShape.multiTier:
        _drawMultiTierCake(canvas, cx, cy);
        break;
    }

    _drawToppings(canvas, cx, cy - 25);

    if (customMessage != null && customMessage!.trim().isNotEmpty) {
      _drawMessage(canvas, cx, cy - 24, customMessage!.trim());
    }
  }

  void _drawPedestal(Canvas canvas, double cx, double cy, double radius) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 8), width: radius * 2.1, height: 44),
      shadowPaint,
    );

    final standPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFEDE8E3), Color(0xFFFFFFFF), Color(0xFFDDD6CE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: radius * 2, height: 38),
      standPaint,
    );

    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: radius * 2, height: 38),
      rimPaint,
    );
  }

  void _drawRoundCake(Canvas canvas, double cx, double cy, double rx, double height) {
    final ry = rx * 0.42;
    final primary = _getPrimaryColor();
    final dark = _getDarkColor();
    final highlight = _getHighlightColor();

    final bodyRect = Rect.fromLTRB(cx - rx, cy - ry, cx + rx, cy + height);
    final sidePath = Path()
      ..moveTo(cx - rx, cy)
      ..arcToPoint(Offset(cx + rx, cy), radius: Radius.elliptical(rx, ry), clockwise: false)
      ..lineTo(cx + rx, cy + height)
      ..arcToPoint(Offset(cx - rx, cy + height), radius: Radius.elliptical(rx, ry), clockwise: true)
      ..close();

    final sideShader = LinearGradient(
      colors: [dark, primary, highlight, primary, dark],
      stops: const [0.0, 0.25, 0.55, 0.8, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(bodyRect);

    canvas.drawPath(sidePath, Paint()..shader = sideShader);

    _drawDrips(canvas, cx, cy, rx, ry, dark);

    final topRect = Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2);
    final topShader = RadialGradient(
      center: const Alignment(-0.2, -0.3),
      radius: 0.9,
      colors: [highlight, primary, dark],
      stops: const [0.0, 0.65, 1.0],
    ).createShader(topRect);

    canvas.drawOval(topRect, Paint()..shader = topShader);

    final rimBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: 0.45);
    canvas.drawOval(topRect, rimBorder);
  }

  void _drawHeartCake(Canvas canvas, double cx, double cy, double rx, double height) {
    final primary = _getPrimaryColor();
    final dark = _getDarkColor();
    final highlight = _getHighlightColor();

    Path createHeart(double yOffset, double scale) {
      final path = Path();
      final w = rx * scale;
      final h = rx * 0.85 * scale;
      final topY = cy + yOffset - h * 0.45;

      path.moveTo(cx, topY + h * 0.3);
      path.cubicTo(
        cx - w * 0.5, topY - h * 0.35,
        cx - w * 0.95, topY + h * 0.3,
        cx, topY + h * 0.95,
      );
      path.cubicTo(
        cx + w * 0.95, topY + h * 0.3,
        cx + w * 0.5, topY - h * 0.35,
        cx, topY + h * 0.3,
      );
      path.close();
      return path;
    }

    final sidePath = Path()
      ..addPath(createHeart(height, 1.0), Offset.zero)
      ..addPath(createHeart(0, 1.0), Offset.zero);
    canvas.drawPath(sidePath, Paint()..color = dark);

    final topPath = createHeart(0, 1.0);
    final topShader = LinearGradient(
      colors: [highlight, primary, dark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: rx * 2));

    canvas.drawPath(topPath, Paint()..shader = topShader);
    canvas.drawPath(
      topPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.5),
    );
  }

  void _drawSquareCake(Canvas canvas, double cx, double cy, double side, double height) {
    final primary = _getPrimaryColor();
    final dark = _getDarkColor();
    final highlight = _getHighlightColor();

    final hw = side * 1.1;
    final hh = side * 0.5;

    final leftFace = Path()
      ..moveTo(cx - hw, cy)
      ..lineTo(cx, cy + hh)
      ..lineTo(cx, cy + hh + height)
      ..lineTo(cx - hw, cy + height)
      ..close();
    canvas.drawPath(leftFace, Paint()..color = dark);

    final rightFace = Path()
      ..moveTo(cx, cy + hh)
      ..lineTo(cx + hw, cy)
      ..lineTo(cx + hw, cy + height)
      ..lineTo(cx, cy + hh + height)
      ..close();
    canvas.drawPath(rightFace, Paint()..color = primary);

    final topFace = Path()
      ..moveTo(cx, cy - hh)
      ..lineTo(cx + hw, cy)
      ..lineTo(cx, cy + hh)
      ..lineTo(cx - hw, cy)
      ..close();

    final topShader = LinearGradient(
      colors: [highlight, primary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCenter(center: Offset(cx, cy), width: hw * 2, height: hh * 2));
    canvas.drawPath(topFace, Paint()..shader = topShader);
    canvas.drawPath(
      topFace,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  void _drawMultiTierCake(Canvas canvas, double cx, double cy) {
    _drawRoundCake(canvas, cx, cy + 22, 116, 54);
    _drawRoundCake(canvas, cx, cy - 40, 78, 48);
  }

  void _drawDrips(Canvas canvas, double cx, double cy, double rx, double ry, Color color) {
    final dripPaint = Paint()..color = color;
    const dripCount = 9;
    final dripOffsets = [12.0, 24.0, 16.0, 28.0, 14.0, 22.0, 10.0, 20.0, 15.0];

    for (int i = 0; i < dripCount; i++) {
      final angle = math.pi + (i * math.pi / (dripCount - 1));
      final x = cx + rx * math.cos(angle);
      final y = cy + ry * math.sin(angle);
      final dripLength = dripOffsets[i];

      final dripPath = Path()
        ..moveTo(x - 4, y)
        ..quadraticBezierTo(x, y + dripLength + 4, x, y + dripLength)
        ..quadraticBezierTo(x + 4, y, x + 5, y)
        ..close();
      canvas.drawPath(dripPath, dripPaint);
      canvas.drawCircle(Offset(x, y + dripLength - 1), 3.2, dripPaint);
    }
  }

  void _drawToppings(Canvas canvas, double cx, double cy) {
    final r = math.Random(42);

    if (toppings.contains(CakeTopping.goldLeaf)) {
      final goldPaint = Paint()..color = const Color(0xFFFFD700);
      for (int i = 0; i < 24; i++) {
        final angle = r.nextDouble() * 2 * math.pi;
        final dist = r.nextDouble() * 56;
        final gx = cx + dist * math.cos(angle);
        final gy = cy + (dist * 0.45) * math.sin(angle);
        final size = 1.5 + r.nextDouble() * 3.5;
        canvas.drawCircle(Offset(gx, gy), size, goldPaint);
      }
    }

    if (toppings.contains(CakeTopping.freshBerries)) {
      final berryPositions = [
        Offset(cx - 36, cy - 6),
        Offset(cx - 22, cy - 14),
        Offset(cx - 8, cy - 16),
        Offset(cx + 18, cy - 12),
        Offset(cx + 34, cy - 4),
      ];

      for (int i = 0; i < berryPositions.length; i++) {
        final pos = berryPositions[i];
        final isStrawberry = i % 2 == 0;
        if (isStrawberry) {
          final strawPath = Path()
            ..moveTo(pos.dx, pos.dy - 6)
            ..lineTo(pos.dx + 6, pos.dy + 7)
            ..lineTo(pos.dx - 6, pos.dy + 7)
            ..close();
          canvas.drawPath(strawPath, Paint()..color = const Color(0xFFD32F2F));
          canvas.drawCircle(Offset(pos.dx, pos.dy - 6), 2.5, Paint()..color = const Color(0xFF388E3C));
        } else {
          canvas.drawCircle(pos, 5.5, Paint()..color = const Color(0xFF283593));
          canvas.drawCircle(Offset(pos.dx - 1.5, pos.dy - 1.5), 1.5, Paint()..color = Colors.white.withValues(alpha: 0.6));
        }
      }
    }

    if (toppings.contains(CakeTopping.macarons)) {
      final macaronColors = [
        const Color(0xFFF48FB1),
        const Color(0xFFFFF59D),
        const Color(0xFFA5D6A7),
      ];
      final macPositions = [
        Offset(cx - 42, cy + 4),
        Offset(cx + 38, cy + 2),
        Offset(cx, cy - 20),
      ];
      for (int i = 0; i < 3; i++) {
        final pos = macPositions[i];
        final col = macaronColors[i];
        canvas.drawOval(Rect.fromCenter(center: pos, width: 18, height: 11), Paint()..color = col);
        canvas.drawRect(Rect.fromCenter(center: pos, width: 15, height: 2.5), Paint()..color = Colors.white.withValues(alpha: 0.8));
      }
    }

    if (toppings.contains(CakeTopping.ferreroRocher)) {
      final rocherPositions = [
        Offset(cx - 28, cy + 8),
        Offset(cx + 24, cy + 6),
      ];
      for (final pos in rocherPositions) {
        canvas.drawCircle(pos, 8, Paint()..color = const Color(0xFF4E342E));
        canvas.drawCircle(pos, 7.5, Paint()..color = const Color(0xFF6D4C41));
        canvas.drawCircle(Offset(pos.dx - 2, pos.dy - 2), 2, Paint()..color = const Color(0xFFFFD54F));
      }
    }
  }

  void _drawMessage(Canvas canvas, double cx, double cy, String text) {
    final textColor = _getMessageColor();
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'Caveat',
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: textColor,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.35),
            offset: const Offset(0.5, 1.0),
            blurRadius: 2,
          ),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
    )..layout(maxWidth: 160);

    textPainter.paint(
      canvas,
      Offset(cx - (textPainter.width / 2), cy - (textPainter.height / 2)),
    );
  }

  @override
  bool shouldRepaint(covariant CakeCanvasPainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.flavor != flavor ||
        oldDelegate.toppings != toppings ||
        oldDelegate.customMessage != customMessage ||
        oldDelegate.photoFile != photoFile;
  }
}
