import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../services/onboarding_service.dart';

import '../theme/app_theme.dart';

import '../utils/app_router.dart';

import '../utils/app_session.dart';

import 'onboarding_screen.dart';



class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key});



  @override

  State<SplashScreen> createState() => _SplashScreenState();

}



class _SplashScreenState extends State<SplashScreen>

    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  late Animation<double> _fade;

  late Animation<double> _scale;

  late Animation<Offset> _slide;



  @override

  void initState() {

    super.initState();

    _controller = AnimationController(

      vsync: this,

      duration: const Duration(milliseconds: 1400),

    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _scale = Tween<double>(begin: 0.6, end: 1).animate(

      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),

    );

    _slide = Tween<Offset>(

      begin: const Offset(0, 0.3),

      end: Offset.zero,

    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    _navigate();

  }



  @override

  void dispose() {

    _controller.dispose();

    super.dispose();

  }



  Future<void> _navigate() async {

    final auth = context.read<AuthProvider>();

    final onboardingDone = await OnboardingService.isCompleted();

    await Future.wait([

      Future.delayed(Duration(milliseconds: onboardingDone ? 1200 : 1800)),

      auth.init(),

    ]);

    if (!mounted) return;



    AppSession.markColdStartComplete();



    final Widget next = !onboardingDone

        ? const OnboardingScreen()

        : AppRouter.homeFor(auth);



    Navigator.pushReplacement(

      context,

      PageRouteBuilder(

        pageBuilder: (_, __, ___) => next,

        transitionsBuilder: (_, anim, __, child) =>

            FadeTransition(opacity: anim, child: child),

        transitionDuration: const Duration(milliseconds: 500),

      ),

    );

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        width: double.infinity,

        height: double.infinity,

        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),

        child: Stack(

          children: [

            Positioned(

              top: -60,

              right: -40,

              child: Container(

                width: 200,

                height: 200,

                decoration: BoxDecoration(

                  shape: BoxShape.circle,

                  color: Colors.white.withValues(alpha: 0.05),

                ),

              ),

            ),

            Positioned(

              bottom: 80,

              left: -80,

              child: Container(

                width: 260,

                height: 260,

                decoration: BoxDecoration(

                  shape: BoxShape.circle,

                  color: Colors.white.withValues(alpha: 0.04),

                ),

              ),

            ),

            FadeTransition(

              opacity: _fade,

              child: Center(

                child: Column(

                  mainAxisAlignment: MainAxisAlignment.center,

                  mainAxisSize: MainAxisSize.min,

                  children: [

                    ScaleTransition(

                      scale: _scale,

                      child: Container(

                        width: 120,

                        height: 120,

                        decoration: BoxDecoration(

                          shape: BoxShape.circle,

                          gradient: LinearGradient(

                            begin: Alignment.topLeft,

                            end: Alignment.bottomRight,

                            colors: [

                              Colors.white.withValues(alpha: 0.25),

                              Colors.white.withValues(alpha: 0.08),

                            ],

                          ),

                          border: Border.all(

                            color: Colors.white.withValues(alpha: 0.3),

                            width: 2,

                          ),

                          boxShadow: [

                            BoxShadow(

                              color: Colors.black.withValues(alpha: 0.15),

                              blurRadius: 30,

                              offset: const Offset(0, 10),

                            ),

                          ],

                        ),

                        child: const Icon(

                          Icons.cake_rounded,

                          size: 56,

                          color: Colors.white,

                        ),

                      ),

                    ),

                    const SizedBox(height: 32),

                    SlideTransition(

                      position: _slide,

                      child: Column(

                        mainAxisSize: MainAxisSize.min,

                        children: [

                          Text(

                            'Sweet Delights',

                            textAlign: TextAlign.center,

                            style: AppTheme.displayLarge.copyWith(

                              color: Colors.white,

                              fontSize: 36,

                            ),

                          ),

                          const SizedBox(height: 10),

                          Container(

                            padding: const EdgeInsets.symmetric(

                              horizontal: 16,

                              vertical: 6,

                            ),

                            decoration: BoxDecoration(

                              color: AppTheme.gold.withValues(alpha: 0.2),

                              borderRadius: BorderRadius.circular(20),

                              border: Border.all(

                                color: AppTheme.gold.withValues(alpha: 0.4),

                              ),

                            ),

                            child: Text(

                              'HANDCRAFTED WITH LOVE',

                              style: AppTheme.labelBold.copyWith(

                                color: AppTheme.goldLight,

                                fontSize: 10,

                                letterSpacing: 2,

                              ),

                            ),

                          ),

                          const SizedBox(height: 14),

                          Text(

                            'Premium cakes, delivered fresh',

                            textAlign: TextAlign.center,

                            style: AppTheme.bodyMedium.copyWith(

                              color: Colors.white.withValues(alpha: 0.8),

                            ),

                          ),

                        ],

                      ),

                    ),

                    const SizedBox(height: 56),

                    SizedBox(

                      width: 28,

                      height: 28,

                      child: CircularProgressIndicator(

                        strokeWidth: 2,

                        color: Colors.white.withValues(alpha: 0.7),

                      ),

                    ),

                  ],

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}


