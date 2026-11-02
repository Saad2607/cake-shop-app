import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/glass/glass_card.dart';

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
        title: Text('Help & Support', style: AppTheme.displayMedium.copyWith(fontSize: 20)),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppTheme.headerGradient,
              borderRadius: AppTheme.radiusLg,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'We\'re here to help',
                      style: AppTheme.titleLarge.copyWith(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Questions about your cake order, delivery time, custom messaging or payment? Reach out anytime.',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _tile(
            icon: Icons.call_rounded,
            title: 'Call Support',
            subtitle: '+91 98765 43210 · 9 AM – 9 PM',
            onTap: () => _call(context),
          ),
          _tile(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Live Chat',
            subtitle: 'Instant assistance for active orders',
            onTap: () => AppSnackBar.info(context, 'Chat support coming soon'),
          ),
          _tile(
            icon: Icons.help_outline_rounded,
            title: 'Frequently Asked Questions',
            subtitle: 'Delivery times, freshness, cancellations & refunds',
            onTap: () => _showFaqs(context),
          ),
          _tile(
            icon: Icons.report_problem_outlined,
            title: 'Report an Issue',
            subtitle: 'Wrong cake, delivery delay, payment dispute',
            onTap: () => AppSnackBar.info(
              context,
              'Describe your issue in Orders → Order details',
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
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.titleMedium.copyWith(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTheme.bodySmall.copyWith(fontSize: 11, color: AppTheme.textMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  void _showFaqs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, scroll) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Frequently Asked Questions', style: AppTheme.displayMedium.copyWith(fontSize: 20)),
              const SizedBox(height: 16),
              _faqItem(
                'How fresh are the cakes?',
                'Every cake is baked freshly upon order confirmation using premium artisan ingredients.',
              ),
              _faqItem(
                'What is express delivery?',
                'Express orders are baked and delivered within 2–4 hours within city limits.',
              ),
              _faqItem(
                'Can I customize the cake message?',
                'Yes! On any cake details screen, you can specify a custom piping message for free.',
              ),
              _faqItem(
                'How do I cancel my order?',
                'You can cancel orders in PENDING status from your Orders tab with a single tap.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: AppTheme.titleMedium.copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          Text(answer, style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted, height: 1.4)),
        ],
      ),
    );
  }
}
