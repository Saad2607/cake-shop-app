import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/upi_payment_service.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../utils/payment_labels.dart';

/// Opens the selected UPI app, then asks the user to confirm payment on return.
Future<bool> showUpiPaymentFlow(
  BuildContext context, {
  required double amount,
  required String paymentMethod,
  String orderNote = 'Cake order',
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _UpiPaymentDialog(
      amount: amount,
      paymentMethod: paymentMethod,
      orderNote: orderNote,
    ),
  );
  return result == true;
}

class _UpiPaymentDialog extends StatefulWidget {
  final double amount;
  final String paymentMethod;
  final String orderNote;

  const _UpiPaymentDialog({
    required this.amount,
    required this.paymentMethod,
    required this.orderNote,
  });

  @override
  State<_UpiPaymentDialog> createState() => _UpiPaymentDialogState();
}

class _UpiPaymentDialogState extends State<_UpiPaymentDialog>
    with WidgetsBindingObserver {
  bool _launched = false;
  bool _awaitingConfirm = false;
  bool _launching = true;
  String? _launchError;
  String? _openedWith;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openUpiApp());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _launched && !_awaitingConfirm) {
      setState(() => _awaitingConfirm = true);
    }
  }

  Future<void> _openUpiApp() async {
    setState(() {
      _launching = true;
      _launchError = null;
    });

    final appCode = UpiPaymentService.appCodeFromMethod(widget.paymentMethod);
    final candidates = UpiPaymentService.launchCandidates(
      amount: widget.amount,
      note: widget.orderNote,
      appCode: appCode,
    );

    for (final uri in candidates) {
      try {
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (ok) {
          if (!mounted) return;
          setState(() {
            _launched = true;
            _launching = false;
            _openedWith = _labelForUri(uri);
          });
          return;
        }
      } catch (_) {
        continue;
      }
    }

    if (!mounted) return;
    setState(() {
      _launching = false;
      _launchError =
          'Could not open a UPI app. Install PhonePe, Google Pay or Paytm, or pay with Cash on Delivery.';
    });
  }

  String _labelForUri(Uri uri) {
    final scheme = uri.scheme;
    if (scheme == 'phonepe') return 'PhonePe';
    if (scheme == 'tez' || scheme == 'gpay') return 'Google Pay';
    if (scheme == 'paytmmp') return 'Paytm';
    return 'UPI app';
  }

  @override
  Widget build(BuildContext context) {
    final appLabel = PaymentLabels.upiAppName(widget.paymentMethod) ?? 'UPI';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.4),
              boxShadow: [AppTheme.softShadow],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_awaitingConfirm) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.help_outline_rounded, color: AppTheme.primary, size: 40),
                  ),
                  const SizedBox(height: 18),
                  Text('Payment complete?', style: AppTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Confirm only if you paid ${CurrencyFormatter.format(widget.amount)} in $_openedWith.',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodySmall.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppTheme.ctaGradient,
                      borderRadius: AppTheme.radiusMd,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Yes, payment done'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('No, go back'),
                  ),
                ] else if (_launchError != null) ...[
                  const Icon(Icons.error_outline_rounded, color: AppTheme.secondary, size: 48),
                  const SizedBox(height: 16),
                  Text('UPI app not found', style: AppTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    _launchError!,
                    textAlign: TextAlign.center,
                    style: AppTheme.bodySmall.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _openUpiApp,
                      child: const Text('Try again'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ] else ...[
                  const SizedBox(
                    width: 38,
                    height: 38,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _launching ? 'Opening $appLabel…' : 'Complete payment in $appLabel',
                    style: AppTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _launching
                        ? 'You will be redirected to pay ${CurrencyFormatter.format(widget.amount)}'
                        : 'Return here after paying to confirm your order',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodySmall.copyWith(height: 1.45),
                  ),
                  if (_launched) ...[
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => setState(() => _awaitingConfirm = true),
                      child: const Text('I have completed payment'),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Routes UPI to real app deep link; card stays on mock sheet.
Future<bool> processOnlinePayment(
  BuildContext context, {
  required double amount,
  required String paymentMethod,
  String orderNote = 'Cake order',
}) async {
  if (paymentMethod.startsWith('UPI')) {
    return showUpiPaymentFlow(
      context,
      amount: amount,
      paymentMethod: paymentMethod,
      orderNote: orderNote,
    );
  }
  return showMockPaymentSheet(
    context,
    amount: amount,
    paymentMethod: paymentMethod,
  );
}

// Re-export mock sheet for card payments.
Future<bool> showMockPaymentSheet(
  BuildContext context, {
  required double amount,
  required String paymentMethod,
}) async {
  return _showCardMockSheet(context, amount: amount, paymentMethod: paymentMethod);
}

Future<bool> _showCardMockSheet(
  BuildContext context, {
  required double amount,
  required String paymentMethod,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    builder: (ctx) => _CardMockSheet(amount: amount),
  );
  return result == true;
}

class _CardMockSheet extends StatefulWidget {
  final double amount;
  const _CardMockSheet({required this.amount});

  @override
  State<_CardMockSheet> createState() => _CardMockSheetState();
}

class _CardMockSheetState extends State<_CardMockSheet> {
  bool _processing = false;
  bool _success = false;

  Future<void> _pay() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() {
      _processing = false;
      _success = true;
    });
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 1.4,
            ),
          ),
          padding: EdgeInsets.fromLTRB(24, 14, 24, 20 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_success) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: AppTheme.success, size: 40),
                ),
                const SizedBox(height: 16),
                Text('Payment approved', style: AppTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  'Paid ${CurrencyFormatter.format(widget.amount)}',
                  style: AppTheme.bodySmall,
                ),
                const SizedBox(height: 24),
              ] else if (_processing) ...[
                const SizedBox(
                  width: 38,
                  height: 38,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primary),
                ),
                const SizedBox(height: 20),
                Text('Processing card payment…', style: AppTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  CurrencyFormatter.format(widget.amount),
                  style: AppTheme.displayMedium.copyWith(color: AppTheme.primary, fontSize: 24),
                ),
                const SizedBox(height: 24),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Debit / Credit card', style: AppTheme.titleLarge),
                    Text(
                      CurrencyFormatter.format(widget.amount),
                      style: AppTheme.titleLarge.copyWith(color: AppTheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.credit_card_rounded, color: AppTheme.primary, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('•••• •••• •••• 4242', style: AppTheme.titleMedium),
                            Text('Demo checkout · Tap to pay', style: AppTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppTheme.ctaGradient,
                    borderRadius: AppTheme.radiusMd,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _pay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Pay ${CurrencyFormatter.format(widget.amount)}'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
