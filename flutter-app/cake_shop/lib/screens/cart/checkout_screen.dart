import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/delivery_address_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/promo_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/payment_labels.dart';
import '../../widgets/delivery_address_sheet.dart';
import '../../widgets/delivery_eta_chip.dart';
import '../../widgets/gradient_header.dart';
import '../../utils/promo_countdown.dart';
import '../../utils/promo_offers.dart';
import '../../widgets/upi_payment_sheet.dart';
import '../orders/order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _promoController = TextEditingController();
  final _upiIdController = TextEditingController();
  DateTime? _deliveryDate;
  String _paymentMethod = 'UPI';
  String _selectedUpiApp = 'GPAY';
  String _deliverySlot = 'express';
  bool _isPlacing = false;

  static const _deliverySlots = [
    ('express', 'Express · 2–4 hours', 'Fastest'),
    ('today_afternoon', 'Today · 2–4 PM', 'Popular'),
    ('today_evening', 'Today · 6–8 PM', ''),
    ('tomorrow_morning', 'Tomorrow · 10 AM–12 PM', ''),
  ];

  @override
  void initState() {
    super.initState();
    final saved = context.read<DeliveryAddressProvider>().fullAddress;
    if (saved.isNotEmpty) _addressController.text = saved;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final code = context.read<PromoProvider>().appliedCode;
      if (code != null && mounted) _promoController.text = code;
    });
    _deliveryDate = DateTime.now();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _promoController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _deliveryDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _deliveryDate = date);
  }

  String _resolvePaymentMethod() {
    if (_paymentMethod == 'COD') return 'COD';
    if (_paymentMethod == 'CARD') return 'CARD';
    final upiId = _upiIdController.text.trim();
    if (upiId.isNotEmpty) return 'UPI:$upiId';
    return 'UPI_$_selectedUpiApp';
  }

  bool _isValidUpiId(String id) {
    if (id.contains('@') && id.length >= 5) return true;
    return RegExp(r'^\d{10}$').hasMatch(id);
  }

  Future<void> _placeOrder() async {
    if (_addressController.text.trim().isEmpty) {
      _showError('Please enter your delivery address');
      return;
    }
    if (_deliveryDate == null) {
      _showError('Please select a delivery date');
      return;
    }

    final promo = context.read<PromoProvider>();
    final cart = context.read<CartProvider>();
    final cartTotal = cart.total;
    if (promo.minOrderWarning(cartTotal) != null) {
      _showError(promo.minOrderWarning(cartTotal)!);
      return;
    }

    final payable = promo.payableTotal(cartTotal);
    final paymentApiValue = _resolvePaymentMethod();

    if (_paymentMethod == 'UPI') {
      final upiId = _upiIdController.text.trim();
      if (upiId.isNotEmpty && !_isValidUpiId(upiId)) {
        _showError('Enter a valid UPI ID (e.g. name@oksbi) or 10-digit mobile');
        return;
      }
    }

    if (PaymentLabels.requiresOnlinePayment(paymentApiValue)) {
      final paid = await processOnlinePayment(
        context,
        amount: payable,
        paymentMethod: paymentApiValue,
        orderNote: 'Sweet Delights order',
      );
      if (!mounted || !paid) return;
    }

    setState(() => _isPlacing = true);
    final slotLabel = _deliverySlots.firstWhere((s) => s.$1 == _deliverySlot).$2;
    final addressWithSlot =
        '${_addressController.text.trim()}\nDelivery slot: $slotLabel';
    final order = await context.read<OrderProvider>().placeOrder(
          deliveryAddress: addressWithSlot,
          deliveryDate: _deliveryDate!.millisecondsSinceEpoch,
          paymentMethod: paymentApiValue,
          promoCode: promo.hasDiscount ? promo.appliedCode : null,
        );
    setState(() => _isPlacing = false);

    if (!mounted) return;

    if (order != null) {
      await context.read<CartProvider>().loadCart();
      context.read<PromoProvider>().clear();
      await NotificationService.instance.showOrderPlaced(order.orderNumber);
      if (mounted) {
        await context.read<NotificationProvider>().incrementCustomerCount();
        context.read<NotificationProvider>().recordOrder(order.id, order.status);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(
            orderNumber: order.orderNumber,
            total: order.totalAmount,
            subtotal: order.discountAmount > 0 ? order.subtotalAmount : null,
            discount: order.discountAmount > 0 ? order.discountAmount : null,
            promoCode: order.promoCode,
            paymentMethod: order.paymentMethod,
          ),
        ),
      );
    } else {
      _showError('Failed to place order. Please try again.');
    }
  }

  void _showError(String msg) {
    AppSnackBar.error(context, msg);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final promo = context.watch<PromoProvider>();
    final discount = promo.discountAmount(cart.total);
    final payable = promo.payableTotal(cart.total);
    final minWarning = promo.minOrderWarning(cart.total);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const GradientHeader(
        title: 'Checkout',
        subtitle: 'Almost there — one step to sweetness',
        showBack: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _stepsRow(),
                  const SizedBox(height: 20),
                  _orderSummary(cart),
                  const SizedBox(height: 24),
                  _sectionTitle('Delivery details'),
                  const SizedBox(height: 10),
                  DeliveryEtaChip.checkout(scheduledDate: _deliveryDate),
                  const SizedBox(height: 12),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _addressController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Delivery address',
                            hintText: 'House no., street, city, pin code',
                            prefixIcon: Icon(Icons.location_on_outlined),
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(height: 1, color: AppTheme.cardBorder),
                        TextButton.icon(
                          onPressed: () async {
                            await showDeliveryAddressSheet(context);
                            if (!mounted) return;
                            final saved = context
                                .read<DeliveryAddressProvider>()
                                .fullAddress;
                            if (saved.isNotEmpty) {
                              setState(() => _addressController.text = saved);
                            }
                          },
                          icon: const Icon(Icons.my_location_rounded, size: 18),
                          label: const Text('Use saved or GPS location'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    onTap: _pickDate,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: AppTheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Delivery date', style: AppTheme.bodySmall),
                              const SizedBox(height: 2),
                              Text(
                                _deliveryDate == null
                                    ? 'Today (express)'
                                    : _isToday(_deliveryDate!)
                                        ? 'Today · express delivery'
                                        : DateFormat('EEEE, dd MMM yyyy')
                                            .format(_deliveryDate!),
                                style: AppTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppTheme.textMuted.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.successLight,
                          AppTheme.goldLight.withValues(alpha: 0.5),
                        ],
                      ),
                      borderRadius: AppTheme.radiusMd,
                      border: Border.all(
                        color: AppTheme.success.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_rounded,
                          color: AppTheme.success,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Express delivery · 2–4 hours · Free',
                            style: AppTheme.titleMedium.copyWith(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _sectionTitle('Delivery slot'),
                  const SizedBox(height: 10),
                  ..._deliverySlots.map((slot) {
                    final selected = _deliverySlot == slot.$1;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _deliverySlot = slot.$1),
                          borderRadius: AppTheme.radiusMd,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.primaryLight.withValues(alpha: 0.25)
                                  : AppTheme.surface,
                              borderRadius: AppTheme.radiusMd,
                              border: Border.all(
                                color: selected ? AppTheme.primary : AppTheme.cardBorder,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 20,
                                  color: selected ? AppTheme.primary : AppTheme.textMuted,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(slot.$2, style: AppTheme.titleMedium.copyWith(fontSize: 14)),
                                ),
                                if (slot.$3.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.goldLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      slot.$3,
                                      style: AppTheme.labelBold.copyWith(fontSize: 9),
                                    ),
                                  ),
                                Radio<String>(
                                  value: slot.$1,
                                  groupValue: _deliverySlot,
                                  activeColor: AppTheme.primary,
                                  onChanged: (v) => setState(() => _deliverySlot = v!),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  _sectionTitle('Payment method'),
                  const SizedBox(height: 8),
                  Text(
                    'Pay online',
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _paymentOption(
                    title: 'UPI',
                    subtitle: 'Opens PhonePe, GPay or Paytm with amount pre-filled',
                    icon: Icons.account_balance_wallet_rounded,
                    value: 'UPI',
                    badge: 'Popular',
                  ),
                  if (_paymentMethod == 'UPI') ...[
                    const SizedBox(height: 12),
                    _upiAppSelector(),
                  ],
                  const SizedBox(height: 10),
                  _paymentOption(
                    title: 'Debit / Credit Card',
                    subtitle: 'Visa, Mastercard, RuPay',
                    icon: Icons.credit_card_rounded,
                    value: 'CARD',
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Pay on delivery',
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _paymentOption(
                    title: 'Cash on Delivery',
                    subtitle: 'Pay when your cake arrives',
                    icon: Icons.payments_outlined,
                    value: 'COD',
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('Promo code'),
                  const SizedBox(height: 12),
                  _promoSection(promo, minWarning),
                  const SizedBox(height: 24),
                  _card(
                    child: Column(
                      children: [
                        _billRow('Item total', CurrencyFormatter.format(cart.total)),
                        if (discount > 0) ...[
                          const SizedBox(height: 10),
                          _billRow(
                            'Promo (${promo.appliedCode})',
                            '-${CurrencyFormatter.format(discount)}',
                            valueColor: AppTheme.success,
                          ),
                        ],
                        const SizedBox(height: 10),
                        _billRow('Delivery', 'FREE', valueColor: AppTheme.success),
                        const SizedBox(height: 10),
                        _billRow('Service fee', 'FREE', valueColor: AppTheme.success),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1, color: AppTheme.cardBorder),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('To pay', style: AppTheme.titleLarge),
                            Text(
                              CurrencyFormatter.format(payable),
                              style: AppTheme.displayMedium.copyWith(
                                fontSize: 24,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(payable),
        ],
      ),
    );
  }

  Widget _stepsRow() {
    return Row(
      children: [
        _stepChip('Cart', false),
        _stepLine(),
        _stepChip('Checkout', true),
        _stepLine(),
        _stepChip('Done', false),
      ],
    );
  }

  Widget _stepChip(String label, bool active) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: active ? AppTheme.ctaGradient : null,
              color: active ? null : AppTheme.cardBorder,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: active
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                  : Text(
                      label[0],
                      style: AppTheme.labelBold.copyWith(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTheme.labelBold.copyWith(
              fontSize: 9,
              color: active ? AppTheme.primary : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepLine() {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 18),
      color: AppTheme.cardBorder,
    );
  }

  Widget _buildBottomBar(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: _isPlacing ? null : AppTheme.ctaGradient,
              color: _isPlacing ? AppTheme.cardBorder : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isPlacing
                  ? null
                  : [
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
                onTap: _isPlacing ? null : _placeOrder,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: _isPlacing
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _placeOrderLabel(total),
                          style: AppTheme.titleMedium.copyWith(color: Colors.white),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _promoSection(PromoProvider promo, String? minWarning) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Enter code',
                    hintText: 'e.g. SWEET50',
                    prefixIcon: Icon(Icons.local_offer_outlined),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final ok = promo.applyCode(_promoController.text);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok ? 'Promo code applied' : 'Invalid promo code',
                      ),
                    ),
                  );
                },
                child: const Text('Apply'),
              ),
            ],
          ),
          if (promo.applied != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${promo.appliedCode} applied',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.success),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    promo.clear();
                    _promoController.clear();
                  },
                  child: const Text('Remove'),
                ),
              ],
            ),
          ],
          if (promo.applied?.expiresAt != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.goldLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    PromoCountdown.label(promo.applied!.expiresAt!),
                    style: AppTheme.labelBold.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF6B5030),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (minWarning != null) ...[
            const SizedBox(height: 8),
            Text(
              minWarning,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.secondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _orderSummary(CartProvider cart) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Your order', style: AppTheme.titleLarge),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.goldLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'}',
                  style: AppTheme.labelBold.copyWith(
                    color: const Color(0xFF6B5030),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...cart.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryLight.withValues(alpha: 0.5),
                          AppTheme.goldLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.cake_rounded,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.cakeName ?? 'Cake',
                          style: AppTheme.titleMedium.copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${item.quantity}× ${item.selectedSize} · ${item.selectedFlavor}',
                          style: AppTheme.bodySmall.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(item.lineTotal),
                    style: AppTheme.titleMedium.copyWith(
                      fontSize: 13,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: AppTheme.displayMedium.copyWith(fontSize: 20));
  }

  Widget _card({required Widget child, VoidCallback? onTap}) {
    return Material(
      color: AppTheme.surface,
      borderRadius: AppTheme.radiusLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.radiusLg,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: AppTheme.radiusLg,
            border: Border.all(color: AppTheme.cardBorder),
            boxShadow: [AppTheme.softShadow],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _billRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted)),
        Text(
          value,
          style: AppTheme.titleMedium.copyWith(
            fontSize: 14,
            color: valueColor ?? AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  String _placeOrderLabel(double total) {
    final amount = CurrencyFormatter.format(total);
    if (_paymentMethod == 'UPI') {
      return 'Pay $amount with UPI';
    }
    if (_paymentMethod == 'CARD') {
      return 'Pay $amount with card';
    }
    return 'Place order · $amount';
  }

  Widget _upiAppSelector() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Choose UPI app', style: AppTheme.titleMedium.copyWith(fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _upiAppChip('PHONEPE', 'PhonePe', const Color(0xFF5F259F))),
              const SizedBox(width: 8),
              Expanded(child: _upiAppChip('GPAY', 'GPay', const Color(0xFF4285F4))),
              const SizedBox(width: 8),
              Expanded(child: _upiAppChip('PAYTM', 'Paytm', const Color(0xFF00BAF2))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('OR', style: AppTheme.bodySmall.copyWith(fontSize: 10)),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _upiIdController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Pay with UPI ID',
              hintText: 'yourname@oksbi or 10-digit mobile',
              prefixIcon: Icon(Icons.alternate_email_rounded),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _upiAppChip(String value, String label, Color color) {
    final hasUpiId = _upiIdController.text.trim().isNotEmpty;
    final selected = !hasUpiId && _selectedUpiApp == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() {
          _selectedUpiApp = value;
          _upiIdController.clear();
        }),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : AppTheme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : AppTheme.cardBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: selected ? color : AppTheme.textMuted,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? color : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    String? badge,
  }) {
    final selected = _paymentMethod == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _paymentMethod = value),
        borderRadius: AppTheme.radiusLg,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: AppTheme.radiusLg,
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.cardBorder,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [AppTheme.softShadow],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primaryLight.withValues(alpha: 0.4)
                      : AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: selected ? AppTheme.primary : AppTheme.textMuted,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title, style: AppTheme.titleMedium),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.successLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.success,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(subtitle, style: AppTheme.bodySmall.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              Radio<String>(
                value: value,
                groupValue: _paymentMethod,
                activeColor: AppTheme.primary,
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
