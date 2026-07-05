import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../theme/app_theme.dart';
import '../utils/app_router.dart';

/// Shows a polished bottom sheet prompting guest users to sign in.
class AuthGuard {
  static Future<bool> requireLogin(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) return true;

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _LoginPromptSheet(),
    );

    if (!context.mounted) return false;
    if (result == 'login') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return context.read<AuthProvider>().isLoggedIn;
    }
    if (result == 'register') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
      return context.read<AuthProvider>().isLoggedIn;
    }
    return false;
  }

  static Future<void> handlePostLogin(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (!context.mounted) return;
    if (auth.user?.role == 'ADMIN') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => AppRouter.homeFor(auth)),
        (_) => false,
      );
    }
  }
}

class _LoginPromptSheet extends StatelessWidget {
  const _LoginPromptSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              24,
              12,
              24,
              24 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              gradient: AppTheme.headerGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Sign in to continue',
                  style: AppTheme.displayMedium.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create an account or sign in to add items to your cart and place orders.',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppTheme.ctaGradient,
                    borderRadius: AppTheme.radiusMd,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, 'login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Sign In'),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, 'register'),
                  child: const Text('Create Account'),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Continue browsing',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
