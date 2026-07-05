import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_snackbar.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _call(BuildContext context) async {
    final uri = Uri.parse('tel:+919876543210');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      AppSnackBar.info(context, 'Call support: +91 98765 43210');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.headerGradient,
              borderRadius: AppTheme.radiusLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We\'re here to help',
                  style: AppTheme.titleLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Questions about your order, delivery or payment? Reach us anytime.',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _tile(
            icon: Icons.call_rounded,
            title: 'Call support',
            subtitle: '+91 98765 43210 · 9 AM – 9 PM',
            onTap: () => _call(context),
          ),
          _tile(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Chat with us',
            subtitle: 'Usually replies within 5 minutes',
            onTap: () => AppSnackBar.info(context, 'Chat support coming soon'),
          ),
          _tile(
            icon: Icons.help_outline_rounded,
            title: 'FAQs',
            subtitle: 'Delivery, refunds, custom cakes',
            onTap: () => _showFaqs(context),
          ),
          _tile(
            icon: Icons.report_problem_outlined,
            title: 'Report an issue',
            subtitle: 'Wrong item, late delivery, payment problem',
            onTap: () => AppSnackBar.info(
              context,
              'Describe your issue in Orders → order details',
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppTheme.surface,
        borderRadius: AppTheme.radiusMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTheme.radiusMd,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTheme.titleMedium.copyWith(fontSize: 15)),
                      Text(subtitle, style: AppTheme.bodySmall.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppTheme.textMuted.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFaqs(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          children: [
            Text('FAQs', style: AppTheme.titleLarge),
            const SizedBox(height: 16),
            _Faq(
              q: 'How long does delivery take?',
              a: 'Express delivery is 2–4 hours for same-day orders placed before 6 PM.',
            ),
            _Faq(
              q: 'Can I cancel my order?',
              a: 'Yes, while status is Pending. After confirmation, contact support.',
            ),
            _Faq(
              q: 'What payment methods do you accept?',
              a: 'UPI (PhonePe, GPay, Paytm), cards, and cash on delivery.',
            ),
            _Faq(
              q: 'Do you offer custom messages on cakes?',
              a: 'Yes — add your message on the product page before adding to cart.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Faq extends StatelessWidget {
  final String q;
  final String a;

  const _Faq({required this.q, required this.a});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q, style: AppTheme.titleMedium.copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          Text(a, style: AppTheme.bodySmall.copyWith(height: 1.45)),
        ],
      ),
    );
  }
}
