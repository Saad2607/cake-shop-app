import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/delivery_address_provider.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_snackbar.dart';

Future<void> showDeliveryAddressSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _DeliveryAddressSheet(),
  );
}

class _DeliveryAddressSheet extends StatefulWidget {
  const _DeliveryAddressSheet();

  @override
  State<_DeliveryAddressSheet> createState() => _DeliveryAddressSheetState();
}

class _DeliveryAddressSheetState extends State<_DeliveryAddressSheet> {
  final _labelCtrl = TextEditingController(text: 'Home');
  final _addressCtrl = TextEditingController();
  bool _loadingGps = false;

  @override
  void initState() {
    super.initState();
    final saved = context.read<DeliveryAddressProvider>();
    if (saved.hasAddress) {
      _labelCtrl.text = saved.label;
      _addressCtrl.text = saved.fullAddress;
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _loadingGps = true);
    try {
      final address = await LocationService.getCurrentAddress();
      if (!mounted) return;
      _addressCtrl.text = address;
      _labelCtrl.text = LocationService.shortLabelFromAddress(address);
      AppSnackBar.success(context, 'Location detected');
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  Future<void> _save() async {
    if (_addressCtrl.text.trim().isEmpty) {
      AppSnackBar.error(context, 'Please enter your delivery address');
      return;
    }
    await context.read<DeliveryAddressProvider>().setAddress(
          label: _labelCtrl.text.trim().isEmpty ? 'Home' : _labelCtrl.text.trim(),
          fullAddress: _addressCtrl.text.trim(),
        );
    if (!mounted) return;
    AppSnackBar.success(context, 'Delivery address saved');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Delivery address',
                      style: AppTheme.displayMedium.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Used for delivery info and checkout',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
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
                    OutlinedButton.icon(
                      onPressed: _loadingGps ? null : _useCurrentLocation,
                      icon: _loadingGps
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location_rounded),
                      label: Text(
                        _loadingGps ? 'Getting location…' : 'Use current location',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppTheme.cardBorder)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: AppTheme.bodySmall.copyWith(fontSize: 11),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppTheme.cardBorder)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _labelCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Label (e.g. Home, Office)',
                        prefixIcon: Icon(Icons.label_outline, color: AppTheme.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Full address *',
                        hintText: 'House no., street, area, city, pin code',
                        prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.primary),
                      ),
                    ),
                    const SizedBox(height: 24),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppTheme.ctaGradient,
                        borderRadius: AppTheme.radiusMd,
                      ),
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Save address'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
