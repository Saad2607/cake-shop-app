import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_address.dart';
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
  final _addressCtrl = TextEditingController();
  String _label = 'Home';
  String? _editingId;
  bool _loadingGps = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  void _loadForEdit(SavedAddress address) {
    setState(() {
      _editingId = address.id;
      _label = address.label;
      _addressCtrl.text = address.fullAddress;
    });
  }

  void _startNew() {
    setState(() {
      _editingId = null;
      _label = 'Home';
      _addressCtrl.clear();
    });
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _loadingGps = true);
    try {
      final address = await LocationService.getCurrentAddress();
      if (!mounted) return;
      _addressCtrl.text = address;
      _label = LocationService.shortLabelFromAddress(address)
          .replaceFirst('Current location · ', '');
      if (_label == address || _label.length > 20) _label = 'Other';
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
    await context.read<DeliveryAddressProvider>().saveAddress(
          label: _label,
          fullAddress: _addressCtrl.text.trim(),
          id: _editingId,
        );
    if (!mounted) return;
    AppSnackBar.success(context, 'Delivery address saved');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeliveryAddressProvider>();
    final saved = provider.addresses;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
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
                    Text(
                      'Delivery addresses',
                      style: AppTheme.displayMedium.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Save Home, Office or Other for faster checkout',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (saved.isNotEmpty) ...[
                      Row(
                        children: [
                          Text('Saved addresses', style: AppTheme.labelBold),
                          const Spacer(),
                          TextButton(
                            onPressed: _startNew,
                            child: const Text('Add new'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...saved.map((address) {
                        final selected = provider.selected?.id == address.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: selected
                                ? AppTheme.primary.withValues(alpha: 0.08)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () async {
                                await provider.selectAddress(address.id);
                                if (!context.mounted) return;
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Icon(
                                      _iconForLabel(address.label),
                                      color: selected
                                          ? AppTheme.primary
                                          : AppTheme.textMuted,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            address.label,
                                            style: AppTheme.titleMedium.copyWith(
                                              fontSize: 14,
                                              color: selected
                                                  ? AppTheme.primary
                                                  : AppTheme.textDark,
                                            ),
                                          ),
                                          Text(
                                            address.fullAddress,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          size: 18),
                                      onPressed: () => _loadForEdit(address),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      const Divider(color: AppTheme.cardBorder),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      _editingId == null ? 'Add address' : 'Edit address',
                      style: AppTheme.labelBold,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: SavedAddress.presetLabels.map((preset) {
                        final active = _label == preset;
                        return ChoiceChip(
                          label: Text(preset),
                          selected: active,
                          onSelected: (_) => setState(() => _label = preset),
                          selectedColor: AppTheme.primary.withValues(alpha: 0.15),
                          labelStyle: TextStyle(
                            color: active ? AppTheme.primary : AppTheme.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Full address *',
                        hintText: 'House no., street, area, city, pin code',
                        prefixIcon: Icon(Icons.location_on_outlined,
                            color: AppTheme.primary),
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
                        child: Text(_editingId == null ? 'Save address' : 'Update address'),
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

  IconData _iconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'office':
        return Icons.work_outline_rounded;
      default:
        return Icons.location_on_outlined;
    }
  }
}
