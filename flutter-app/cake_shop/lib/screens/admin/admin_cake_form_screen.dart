import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cake.dart';
import '../../providers/admin_provider.dart';
import '../../providers/cake_provider.dart';
import '../../theme/app_theme.dart';

class AdminCakeFormScreen extends StatefulWidget {
  final Cake? cake;

  const AdminCakeFormScreen({super.key, this.cake});

  @override
  State<AdminCakeFormScreen> createState() => _AdminCakeFormScreenState();
}

class _AdminCakeFormScreenState extends State<AdminCakeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _sizesCtrl;
  late final TextEditingController _flavorsCtrl;
  late final TextEditingController _ratingCtrl;
  late final TextEditingController _imageUrlCtrl;
  String _category = 'BIRTHDAY';
  bool _inStock = true;
  bool _saving = false;

  static const _categories = ['BIRTHDAY', 'WEDDING', 'CUPCAKE', 'CUSTOM', 'SEASONAL'];

  bool get _isEdit => widget.cake != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cake;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _priceCtrl = TextEditingController(text: c != null ? c.basePrice.toStringAsFixed(0) : '');
    _sizesCtrl = TextEditingController(text: c?.sizes.join(', ') ?? '1kg, 2kg');
    _flavorsCtrl = TextEditingController(text: c?.flavors.join(', ') ?? 'Chocolate, Vanilla');
    _ratingCtrl = TextEditingController(text: c != null ? c.rating.toString() : '4.5');
    _imageUrlCtrl = TextEditingController(text: c?.imageUrl ?? '');
    _imageUrlCtrl.addListener(() => setState(() {}));
    if (c != null) {
      _category = c.category;
      _inStock = c.inStock;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _sizesCtrl.dispose();
    _flavorsCtrl.dispose();
    _ratingCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  List<String> _parseList(String raw) {
    return raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final body = {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'category': _category,
      'basePrice': double.parse(_priceCtrl.text.trim()),
      'sizes': _parseList(_sizesCtrl.text),
      'flavors': _parseList(_flavorsCtrl.text),
      'rating': double.tryParse(_ratingCtrl.text.trim()) ?? 4.5,
      'inStock': _inStock,
      'imageUrl': _imageUrlCtrl.text.trim(),
    };

    final admin = context.read<AdminProvider>();
    final ok = _isEdit
        ? await admin.updateProduct(widget.cake!.id, body)
        : await admin.createProduct(body);

    setState(() => _saving = false);
    if (!mounted) return;

    if (ok) {
      if (mounted) {
        await context.read<CakeProvider>().loadCakes();
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Product updated' : 'Product added')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(admin.error ?? 'Save failed'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit product' : 'Add product'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Product name *'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Base price (INR) *',
                prefixText: '₹ ',
              ),
              validator: (v) {
                if (v == null || double.tryParse(v.trim()) == null) return 'Enter valid price';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _sizesCtrl,
              decoration: const InputDecoration(
                labelText: 'Sizes (comma separated)',
                hintText: '500g, 1kg, 2kg',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _flavorsCtrl,
              decoration: const InputDecoration(
                labelText: 'Flavors (comma separated)',
                hintText: 'Chocolate, Vanilla',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _ratingCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Rating (0-5)'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _imageUrlCtrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Product image URL',
                hintText: 'https://… (paste link to real cake photo)',
                prefixIcon: Icon(Icons.image_outlined),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use a photo of this exact cake for best results. Upload to Google Drive or Imgur and paste the link.',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted, height: 1.35),
            ),
            if (_imageUrlCtrl.text.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    _imageUrlCtrl.text.trim(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppTheme.cardBorder,
                      child: const Center(
                        child: Icon(Icons.broken_image_outlined, color: AppTheme.textMuted),
                      ),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: AppTheme.cardBorder,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            SwitchListTile(
              title: const Text('In stock'),
              value: _inStock,
              activeColor: AppTheme.primary,
              onChanged: (v) => setState(() => _inStock = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_isEdit ? 'Save changes' : 'Add to catalog'),
            ),
          ],
        ),
      ),
    );
  }
}
