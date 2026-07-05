import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/payment_labels.dart';
import '../home/main_screen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String orderNumber;
  final double total;
  final double? subtotal;
  final double? discount;
  final String? promoCode;
  final String? paymentMethod;

  const OrderConfirmationScreen({
    super.key,
    required this.orderNumber,
    required this.total,
    this.subtotal,
    this.discount,
    this.promoCode,
    this.paymentMethod,
  });

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confetti;
  late AnimationController _scaleCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confetti.play();
      _scaleCtrl.forward();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const Spacer(),
                  ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.successLight,
                            AppTheme.goldLight.withValues(alpha: 0.6),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.success.withValues(alpha: 0.2),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppTheme.success,
                        size: 56,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Order confirmed!',
                    style: AppTheme.displayLarge.copyWith(fontSize: 30),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Time to celebrate — your cake is on its way!',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: AppTheme.radiusLg,
                      border: Border.all(color: AppTheme.cardBorder),
                      boxShadow: [AppTheme.softShadow],
                    ),
                    child: Column(
                      children: [
                        Text('Order number', style: AppTheme.bodySmall),
                        const SizedBox(height: 6),
                        Text(
                          widget.orderNumber,
                          style: AppTheme.displayMedium.copyWith(
                            color: AppTheme.primary,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: widget.orderNumber));
                            AppSnackBar.success(context, 'Order number copied');
                          },
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Copy order number'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.textMuted,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Divider(height: 1, color: AppTheme.cardBorder),
                        ),
                        if (widget.discount != null && widget.discount! > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Subtotal', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted)),
                              Text(
                                CurrencyFormatter.format(widget.subtotal ?? widget.total),
                                style: AppTheme.bodyMedium.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Promo${widget.promoCode != null ? ' (${widget.promoCode})' : ''}',
                                style: AppTheme.bodyMedium.copyWith(color: AppTheme.success),
                              ),
                              Text(
                                '-${CurrencyFormatter.format(widget.discount!)}',
                                style: AppTheme.bodyMedium.copyWith(color: AppTheme.success),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total paid', style: AppTheme.titleMedium),
                            Text(
                              CurrencyFormatter.format(widget.total),
                              style: AppTheme.titleLarge.copyWith(
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        if (widget.paymentMethod != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Paid via', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted)),
                              Text(
                                PaymentLabels.format(widget.paymentMethod!),
                                style: AppTheme.titleMedium.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.successLight,
                            borderRadius: AppTheme.radiusSm,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_shipping_rounded,
                                color: AppTheme.success,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Estimated delivery in 2–4 hours',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppTheme.ctaGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MainScreen(initialTab: 2),
                              ),
                              (_) => false,
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              'Track my order',
                              style: AppTheme.titleMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const MainScreen()),
                          (_) => false,
                        );
                      },
                      child: const Text('Continue shopping'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confetti,
            blastDirection: pi / 2,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.08,
            numberOfParticles: 24,
            maxBlastForce: 28,
            minBlastForce: 12,
            gravity: 0.12,
            colors: const [
              AppTheme.primary,
              AppTheme.gold,
              AppTheme.primaryLight,
              AppTheme.success,
              Colors.white,
            ],
          ),
        ],
      ),
    );
  }
}
