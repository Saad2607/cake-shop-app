import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/onboarding_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../utils/app_router.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      useBrandLogo: true,
      title: 'Handcrafted Artisan Cakes',
      subtitle:
          'Discover premium tiered cakes, rich cupcakes, and custom-baked celebration creations made with love.',
      colors: [Color(0xFFFFF0F4), Color(0xFFFBE6EB)],
    ),
    _Slide(
      icon: Icons.delivery_dining_rounded,
      title: 'Express Doorstep Delivery',
      subtitle:
          'Set your delivery address, pick a scheduled slot, and enjoy chilled, fresh delivery in 2–4 hours.',
      colors: [Color(0xFFEAF5EE), Color(0xFFF7F1E4)],
    ),
    _Slide(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Seamless Payments',
      subtitle:
          'Pay instantly with Google Pay, PhonePe, Paytm, Cards or Cash on Delivery. Order effortlessly whenever you crave sweetness.',
      colors: [Color(0xFFFBF2E9), Color(0xFFF8DCE2)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await OnboardingService.markCompleted();
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => AppRouter.homeFor(auth),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Skip',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _OnboardingPage(slide: _slides[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 26 : 8,
                  height: 7,
                  decoration: BoxDecoration(
                    gradient: _page == i ? AppTheme.ctaGradient : null,
                    color: _page == i ? null : AppTheme.cardBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.ctaGradient,
                    borderRadius: AppTheme.radiusMd,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.32),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_page < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        );
                      } else {
                        _finish();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _page < _slides.length - 1 ? 'Next' : 'Get Started',
                      style: AppTheme.titleMedium.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final IconData? icon;
  final bool useBrandLogo;
  final String title;
  final String subtitle;
  final List<Color> colors;

  const _Slide({
    this.icon,
    this.useBrandLogo = false,
    required this.title,
    required this.subtitle,
    required this.colors,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _Slide slide;

  const _OnboardingPage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: slide.colors,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.16),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: slide.useBrandLogo
                ? const AppLogo(size: 96, showCircleBackground: true)
                : Icon(slide.icon, size: 76, color: AppTheme.primary),
          ),
          const SizedBox(height: 44),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: AppTheme.displayMedium.copyWith(
              fontSize: 26,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textMuted,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
