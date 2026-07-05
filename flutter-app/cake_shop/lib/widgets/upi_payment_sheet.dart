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
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: AppTheme.radiusLg,
          boxShadow: [AppTheme.softShadow],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_awaitingConfirm) ...[
              const Icon(Icons.help_outline_rounded, color: AppTheme.primary, size: 48),
              const SizedBox(height: 16),
              Text('Payment complete?', style: AppTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Confirm only if you paid ${CurrencyFormatter.format(widget.amount)} in $_openedWith.',
                textAlign: TextAlign.center,
                style: AppTheme.bodySmall.copyWith(height: 1.45),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
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
                width: 36,
                height: 36,
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
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Icon(
            _success ? Icons.check_circle_rounded : Icons.credit_card_rounded,
            color: _success ? AppTheme.success : AppTheme.primary,
            size: _success ? 56 : 32,
          ),
          const SizedBox(height: 16),
          Text(
            _success ? 'Payment successful' : 'Card payment',
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Text(
            CurrencyFormatter.format(widget.amount),
            style: AppTheme.displayMedium.copyWith(color: AppTheme.primary, fontSize: 28),
          ),
          if (!_success) ...[
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Card number',
                hintText: '4242 4242 4242 4242',
                prefixIcon: Icon(Icons.credit_card_outlined),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processing ? null : _pay,
                child: _processing
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Pay ${CurrencyFormatter.format(widget.amount)}'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
          ],
        ],
      ),
    );
  }
}
