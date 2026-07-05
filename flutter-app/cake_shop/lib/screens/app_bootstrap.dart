import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/onboarding_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_router.dart';
import '../utils/app_session.dart';
import 'onboarding_screen.dart';
import 'splash_screen.dart';

/// Entry gate: splash on cold start only; resume from background goes straight home.
class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    if (AppSession.coldStartComplete) {
      return const HomeGate();
    }
    return const SplashScreen();
  }
}

/// Loads auth and shows the main app without splash animation.
class HomeGate extends StatefulWidget {
  const HomeGate({super.key});

  @override
  State<HomeGate> createState() => _HomeGateState();
}

class _HomeGateState extends State<HomeGate> {
  bool _ready = false;
  bool _onboardingDone = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await context.read<AuthProvider>().init();
    final onboardingDone = await OnboardingService.isCompleted();
    if (mounted) {
      setState(() {
        _ready = true;
        _onboardingDone = onboardingDone;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }
    if (!_onboardingDone) {
      return const OnboardingScreen();
    }
    return AppRouter.homeFor(context.read<AuthProvider>());
  }
}
