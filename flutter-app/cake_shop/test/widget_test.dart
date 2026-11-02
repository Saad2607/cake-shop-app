import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cake_shop/theme/app_theme.dart';
import 'package:cake_shop/theme/admin_theme.dart';
import 'package:cake_shop/widgets/app_logo.dart';
import 'package:cake_shop/widgets/glass/glass_container.dart';
import 'package:cake_shop/widgets/glass/glass_card.dart';
import 'package:cake_shop/widgets/glass/glass_icon_button.dart';
import 'package:cake_shop/widgets/glass/glass_search_bar.dart';
import 'package:cake_shop/widgets/glass/primary_button.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Liquid Glass Design System Tests', () {
    test('AppTheme defines required liquid glass colors and properties', () {
      expect(AppTheme.primary, const Color(0xFFC7516B));
      expect(AppTheme.cream, const Color(0xFFFFF7F0));
      expect(AppTheme.background, const Color(0xFFFAF6F2));
      expect(AppTheme.textDark, const Color(0xFF2B1D19));
      expect(AppTheme.textMuted, const Color(0xFF7D6E68));
      expect(AppTheme.accentRose, const Color(0xFFDE526C));
      expect(AppTheme.glassWhite, isNotNull);
      expect(AppTheme.glassBorder, isNotNull);
    });

    test('AdminTheme defines merchant palette and typography', () {
      expect(AdminTheme.accent, const Color(0xFFC7516B));
      expect(AdminTheme.scaffold, const Color(0xFFF7F4F0));
      expect(AdminTheme.online, const Color(0xFF2E8558));
    });

    testWidgets('GlassContainer renders child with backdrop filter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassContainer(
              blurSigma: 16,
              color: Colors.white,
              child: const Text('Frosted Content'),
            ),
          ),
        ),
      );

      expect(find.text('Frosted Content'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('GlassCard renders with elevation and border', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassCard(
              onTap: () => tapped = true,
              child: const Text('Card Item'),
            ),
          ),
        ),
      );

      expect(find.text('Card Item'), findsOneWidget);
      await tester.tap(find.text('Card Item'));
      expect(tapped, isTrue);
    });

    testWidgets('GlassIconButton responds to taps and displays badge', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassIconButton(
              icon: Icons.shopping_bag_outlined,
              badgeCount: 3,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      await tester.tap(find.byType(GlassIconButton));
      expect(tapped, isTrue);
    });

    testWidgets('PrimaryButton displays label, icon, and handles click', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Proceed to Checkout',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Proceed to Checkout'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
      await tester.tap(find.text('Proceed to Checkout'));
      expect(pressed, isTrue);
    });

    testWidgets('GlassSearchBar renders search input and clear button', (tester) async {
      final controller = TextEditingController(text: 'Chocolate');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassSearchBar(
              controller: controller,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Chocolate'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('AppLogo renders artisan cake custom paint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppLogo.home(),
            ),
          ),
        ),
      );

      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
