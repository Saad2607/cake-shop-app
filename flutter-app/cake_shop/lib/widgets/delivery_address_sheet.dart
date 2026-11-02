import 'dart:ui';
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
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2B1D19).withValues(alpha: 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, -6),
                ),
              ],
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
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Delivery Addresses',
                          style: AppTheme.displayMedium.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select or add an address for express delivery',
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
                              Text(
                                'SAVED PLACES',
                                style: AppTheme.labelBold.copyWith(
                                  color: AppTheme.textMuted,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: _startNew,
                                child: Text(
                                  'Add new',
                                  style: AppTheme.labelBold.copyWith(
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...saved.map((address) {
                            final selected = provider.selected?.id == address.id;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppTheme.primaryLight.withValues(alpha: 0.4)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected
                                      ? AppTheme.primary.withValues(alpha: 0.4)
                                      : AppTheme.cardBorder,
                                  width: 1.2,
                                ),
                                boxShadow: [AppTheme.softShadow],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  await provider.selectAddress(address.id);
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? AppTheme.primary.withValues(alpha: 0.15)
                                              : AppTheme.cream,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          _iconForLabel(address.label),
                                          color: selected
                                              ? AppTheme.primary
                                              : AppTheme.textMuted,
                                          size: 20,
                                        ),
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
                                            const SizedBox(height: 2),
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
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                          color: AppTheme.textMuted,
                                        ),
                                        onPressed: () => _loadForEdit(address),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 14),
                          const Divider(color: AppTheme.cardBorder),
                          const SizedBox(height: 14),
                        ],
                        Text(
                          _editingId == null ? 'ADD NEW ADDRESS' : 'EDIT ADDRESS',
                          style: AppTheme.labelBold.copyWith(
                            color: AppTheme.textMuted,
                            letterSpacing: 0.6,
                          ),
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
                              selectedColor: AppTheme.primaryLight.withValues(alpha: 0.6),
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: active ? AppTheme.primary : AppTheme.cardBorder,
                              ),
                              labelStyle: TextStyle(
                                color: active ? AppTheme.primary : AppTheme.textDark,
                                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
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
                              : const Icon(Icons.my_location_rounded, size: 18),
                          label: Text(
                            _loadingGps ? 'Getting location…' : 'Use current location (GPS)',
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
                        const SizedBox(height: 22),
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.ctaGradient,
                            borderRadius: AppTheme.radiusMd,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.32),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
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
