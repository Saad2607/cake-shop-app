import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/customizer/cake_canvas_painter.dart';
import '../../widgets/glass/glass_card.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/primary_button.dart';
import '../../widgets/gradient_header.dart';

class CakeCustomizerScreen extends StatefulWidget {
  const CakeCustomizerScreen({super.key});

  @override
  State<CakeCustomizerScreen> createState() => _CakeCustomizerScreenState();
}

class _CakeCustomizerScreenState extends State<CakeCustomizerScreen> {
  CakeShape _shape = CakeShape.round;
  String _size = '1.0 kg';
  FrostingFlavor _flavor = FrostingFlavor.belgianChocolate;
  final Set<CakeTopping> _toppings = {CakeTopping.freshBerries, CakeTopping.goldLeaf};
  final TextEditingController _messageController = TextEditingController();
  File? _ediblePhoto;
  final ImagePicker _picker = ImagePicker();

  static const Map<CakeShape, (String, double)> _shapeConfig = {
    CakeShape.round: ('Classic Round', 799.0),
    CakeShape.heart: ('Romantic Heart', 899.0),
    CakeShape.square: ('Modern Square', 849.0),
    CakeShape.multiTier: ('Royal 2-Tier', 1499.0),
  };

  static const Map<String, double> _sizeMultipliers = {
    '0.5 kg': 0.75,
    '1.0 kg': 1.0,
    '1.5 kg': 1.45,
    '2.0 kg': 1.85,
  };

  static const Map<CakeTopping, (String, double, IconData)> _toppingConfig = {
    CakeTopping.freshBerries: ('Fresh Berries', 120.0, Icons.eco_outlined),
    CakeTopping.goldLeaf: ('24K Gold Leaf', 150.0, Icons.auto_awesome),
    CakeTopping.macarons: ('French Macarons', 140.0, Icons.cookie_outlined),
    CakeTopping.ferreroRocher: ('Ferrero Rocher', 130.0, Icons.lens),
  };

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  double get _calculatedPrice {
    final basePrice = _shapeConfig[_shape]!.$2;
    final sizeMultiplier = _sizeMultipliers[_size] ?? 1.0;
    double total = basePrice * sizeMultiplier;

    for (final t in _toppings) {
      total += _toppingConfig[t]!.$2;
    }

    if (_ediblePhoto != null) {
      total += 150.0;
    }

    return total.roundToDouble();
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _ediblePhoto = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Unable to pick photo: $e');
      }
    }
  }

  void _addToCart() async {
    final cart = context.read<CartProvider>();
    final shapeName = _shapeConfig[_shape]!.$1;
    final flavorName = _getFlavorTitle(_flavor);
    final toppingsSummary = _toppings.map((t) => _toppingConfig[t]!.$1).join(', ');

    String customDescription = '$shapeName · $flavorName';
    if (_toppings.isNotEmpty) {
      customDescription += ' · Toppings: $toppingsSummary';
    }
    if (_ediblePhoto != null) {
      customDescription += ' · (Edible Photo Included)';
    }

    final icingText = _messageController.text.trim();
    final combinedNotes = [
      if (icingText.isNotEmpty) 'Icing: "$icingText"',
      customDescription,
    ].join(' · ');

    await cart.addItem(
      cakeId: 'custom-creation-${DateTime.now().millisecondsSinceEpoch}',
      cakeName: 'Custom $shapeName ($flavorName)',
      quantity: 1,
      selectedSize: _size,
      selectedFlavor: flavorName,
      customMessage: combinedNotes.isNotEmpty ? combinedNotes : null,
      unitPrice: _calculatedPrice,
    );

    if (mounted) {
      AppSnackBar.success(context, 'Your artisan cake design was added to Cart!');
      Navigator.pop(context);
    }
  }

  String _getFlavorTitle(FrostingFlavor f) {
    switch (f) {
      case FrostingFlavor.belgianChocolate:
        return 'Belgian Chocolate Ganache';
      case FrostingFlavor.blushRose:
        return 'Blush Strawberry Rose';
      case FrostingFlavor.vanillaBean:
        return 'Madagascar Vanilla Bean';
      case FrostingFlavor.pistachioCream:
        return 'Sicilian Pistachio Velvet';
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _calculatedPrice;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: GradientHeader(
        title: 'Cake Studio',
        subtitle: 'Interactive Visual 3D Decorator',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInteractiveCanvas(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('1. CHOOSE BASE SHAPE'),
                  const SizedBox(height: 10),
                  _buildShapeSelector(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('2. SELECT CAKE WEIGHT'),
                  const SizedBox(height: 10),
                  _buildSizeSelector(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('3. FROSTING & FLAVOR'),
                  const SizedBox(height: 10),
                  _buildFlavorSelector(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('4. GOURMET TOPPINGS'),
                  const SizedBox(height: 10),
                  _buildToppingSelector(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('5. EDIBLE PHOTO PRINT'),
                  const SizedBox(height: 10),
                  _buildPhotoPickerCard(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('6. PIPED ICING CALLIGRAPHY'),
                  const SizedBox(height: 10),
                  _buildMessageInput(),
                ],
              ),
            ),
          ),
          _buildBottomAction(totalPrice),
        ],
      ),
    );
  }

  Widget _buildInteractiveCanvas() {
    return Container(
      height: 270,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.95),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B1D19).withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: CustomPaint(
                painter: CakeCanvasPainter(
                  shape: _shape,
                  flavor: _flavor,
                  toppings: _toppings,
                  customMessage: _messageController.text,
                  photoFile: _ediblePhoto,
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 14),
                  SizedBox(width: 5),
                  Text(
                    'Live Visual Preview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_ediblePhoto != null)
            Positioned(
              top: 14,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.gold, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.file(
                    _ediblePhoto!,
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.labelBold.copyWith(
        fontSize: 11,
        color: AppTheme.primary,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildShapeSelector() {
    return Row(
      children: CakeShape.values.map((s) {
        final isSelected = _shape == s;
        final info = _shapeConfig[s]!;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => setState(() => _shape = s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.ctaGradient : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppTheme.cardBorder,
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [AppTheme.softShadow],
                ),
                child: Column(
                  children: [
                    Icon(
                      _getShapeIcon(s),
                      color: isSelected ? Colors.white : AppTheme.primary,
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      info.$1.split(' ').first,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(info.$2),
                      style: TextStyle(
                        fontSize: 9.5,
                        color: isSelected ? Colors.white.withValues(alpha: 0.9) : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getShapeIcon(CakeShape s) {
    switch (s) {
      case CakeShape.round:
        return Icons.circle_outlined;
      case CakeShape.heart:
        return Icons.favorite_border_rounded;
      case CakeShape.square:
        return Icons.crop_square_rounded;
      case CakeShape.multiTier:
        return Icons.layers_outlined;
    }
  }

  Widget _buildSizeSelector() {
    return Row(
      children: _sizeMultipliers.keys.map((sizeKey) {
        final isSelected = _size == sizeKey;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _size = sizeKey),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.ctaGradient : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppTheme.cardBorder,
                  ),
                ),
                child: Center(
                  child: Text(
                    sizeKey,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFlavorSelector() {
    return Column(
      children: FrostingFlavor.values.map((f) {
        final isSelected = _flavor == f;
        final title = _getFlavorTitle(f);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => setState(() => _flavor = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryLight.withValues(alpha: 0.35)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.cardBorder,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getFlavorSwatch(f),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 20),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getFlavorSwatch(FrostingFlavor f) {
    switch (f) {
      case FrostingFlavor.belgianChocolate:
        return const Color(0xFF3E2723);
      case FrostingFlavor.blushRose:
        return const Color(0xFFE892A2);
      case FrostingFlavor.vanillaBean:
        return const Color(0xFFFFF6E5);
      case FrostingFlavor.pistachioCream:
        return const Color(0xFFA8C69F);
    }
  }

  Widget _buildToppingSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: CakeTopping.values.map((t) {
        final isSelected = _toppings.contains(t);
        final info = _toppingConfig[t]!;
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _toppings.remove(t);
              } else {
                _toppings.add(t);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? AppTheme.ctaGradient : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? Colors.transparent : AppTheme.cardBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  info.$3,
                  size: 16,
                  color: isSelected ? Colors.white : AppTheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${info.$1} (+${CurrencyFormatter.format(info.$2)})',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPhotoPickerCard() {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: _ediblePhoto != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(_ediblePhoto!, fit: BoxFit.cover),
                  )
                : const Icon(Icons.add_a_photo_outlined, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _ediblePhoto != null ? 'Edible Photo Attached' : 'Print on Edible Sugar Sheet',
                  style: AppTheme.titleMedium.copyWith(fontSize: 13.5),
                ),
                Text(
                  _ediblePhoto != null ? 'Printed in food-grade organic coloring' : '+₹150 · 100% Edible FDA Certified',
                  style: AppTheme.bodySmall.copyWith(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          if (_ediblePhoto != null)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFFD32F2F), size: 20),
              onPressed: () => setState(() => _ediblePhoto = null),
            )
          else
            TextButton(
              onPressed: _pickPhoto,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('Upload'),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return TextField(
      controller: _messageController,
      maxLength: 35,
      decoration: InputDecoration(
        hintText: 'e.g. Happy 25th Birthday Saad! ✨',
        labelText: 'Custom Cake Message',
        prefixIcon: const Icon(Icons.edit_note_rounded, color: AppTheme.primary),
        suffixIcon: _messageController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => _messageController.clear(),
              )
            : null,
      ),
    );
  }

  Widget _buildBottomAction(double total) {
    return GlassContainer(
      blurSigma: 24,
      opacity: 0.94,
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.95),
        width: 1.4,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2B1D19).withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, -6),
        ),
      ],
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Customized Total',
                  style: AppTheme.labelBold.copyWith(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(total),
                  style: AppTheme.titleLarge.copyWith(
                    color: AppTheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: PrimaryButton(
                label: 'Add to Cart',
                icon: Icons.shopping_bag_outlined,
                onPressed: _addToCart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
