import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/promo_offer_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/promo_catalog_provider.dart';
import '../../theme/admin_theme.dart';

class AdminPromoFormScreen extends StatefulWidget {
  final PromoOfferModel? promo;
  final PromoOfferModel? duplicateFrom;

  const AdminPromoFormScreen({super.key, this.promo, this.duplicateFrom});

  @override
  State<AdminPromoFormScreen> createState() => _AdminPromoFormScreenState();
}

class _AdminPromoFormScreenState extends State<AdminPromoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _subtitleCtrl;
  late final TextEditingController _tapHintCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _discountCtrl;
  late final TextEditingController _minOrderCtrl;
  late final TextEditingController _infoCtrl;
  late final TextEditingController _sortCtrl;
  PromoActionType _action = PromoActionType.discount;
  String? _category = 'BIRTHDAY';
  String _colorStart = '#4A1530';
  String _colorEnd = '#8B2D52';
  String _accent = '#C9A962';
  String _icon = 'local_offer';
  DateTime? _expiresAt;
  bool _active = true;
  bool _saving = false;

  static const _categories = ['BIRTHDAY', 'WEDDING', 'CUPCAKE', 'CUSTOM', 'SEASONAL'];
  static const _icons = ['local_offer', 'delivery_dining', 'camera_alt', 'celebration', 'percent'];

  static const _colorPresets = [
    ('Berry', '#4A1530', '#8B2D52', '#C9A962'),
    ('Chocolate', '#3D2B1F', '#7A5C3E', '#E8C98A'),
    ('Rose', '#5C1A3D', '#B8365E', '#F2C4D0'),
    ('Midnight', '#1A1A2E', '#3D3D6B', '#A8DADC'),
    ('Forest', '#1B3A2F', '#2D6A4F', '#95D5B2'),
    ('Sunset', '#7C2D12', '#EA580C', '#FDE68A'),
  ];

  bool get _isEdit => widget.promo != null;

  @override
  void initState() {
    super.initState();
    final p = widget.promo ?? widget.duplicateFrom;
    _titleCtrl = TextEditingController(
      text: widget.duplicateFrom != null
          ? '${widget.duplicateFrom!.title} (copy)'
          : p?.title ?? '',
    );
    _subtitleCtrl = TextEditingController(text: p?.subtitle ?? '');
    _tapHintCtrl = TextEditingController(text: p?.tapHint ?? 'Tap for details');
    _codeCtrl = TextEditingController(
      text: widget.duplicateFrom != null ? '' : p?.code ?? '',
    );
    _discountCtrl = TextEditingController(
      text: p?.discountPercent != null
          ? (p!.discountPercent! * 100).toStringAsFixed(0)
          : '50',
    );
    _minOrderCtrl = TextEditingController(
      text: p?.minOrder != null ? p!.minOrder!.toStringAsFixed(0) : '',
    );
    _infoCtrl = TextEditingController(text: p?.infoMessage ?? '');
    _sortCtrl = TextEditingController(text: '${p?.sortOrder ?? 0}');
    for (final c in [
      _titleCtrl,
      _subtitleCtrl,
      _tapHintCtrl,
      _codeCtrl,
      _discountCtrl,
      _minOrderCtrl,
      _infoCtrl,
    ]) {
      c.addListener(() => setState(() {}));
    }
    if (p != null) {
      _action = p.action;
      _category = p.category;
      _colorStart = p.colorStart;
      _colorEnd = p.colorEnd;
      _accent = p.accentColor;
      _icon = p.icon;
      _expiresAt = widget.duplicateFrom == null ? p.expiresAtDate : null;
      _active = widget.duplicateFrom != null ? false : p.active;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _tapHintCtrl.dispose();
    _codeCtrl.dispose();
    _discountCtrl.dispose();
    _minOrderCtrl.dispose();
    _infoCtrl.dispose();
    _sortCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildBody() {
    final discountPct = double.tryParse(_discountCtrl.text.trim());
    final minOrder = double.tryParse(_minOrderCtrl.text.trim());
    return {
      'title': _titleCtrl.text.trim(),
      'subtitle': _subtitleCtrl.text.trim(),
      'tapHint': _tapHintCtrl.text.trim(),
      'action': PromoOfferModel.actionToApi(_action),
      if (_action == PromoActionType.discount) ...{
        'code': _codeCtrl.text.trim().toUpperCase(),
        'discountPercent': discountPct != null ? discountPct / 100 : null,
        if (minOrder != null) 'minOrder': minOrder,
      },
      if (_action == PromoActionType.browseCategory && _category != null) 'category': _category,
      if (_action == PromoActionType.info && _infoCtrl.text.trim().isNotEmpty)
        'infoMessage': _infoCtrl.text.trim(),
      'colorStart': _colorStart,
      'colorEnd': _colorEnd,
      'accentColor': _accent,
      'icon': _icon,
      'expiresAt': _expiresAt?.millisecondsSinceEpoch,
      'active': _active,
      'sortOrder': int.tryParse(_sortCtrl.text.trim()) ?? 0,
    };
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final admin = context.read<AdminProvider>();
    final body = _buildBody();
    final ok = _isEdit
        ? await admin.updatePromo(widget.promo!.id, body)
        : await admin.createPromo(body);

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      await context.read<PromoCatalogProvider>().loadActivePromos();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Offer updated' : 'Offer created')),
      );
    } else if (admin.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(admin.error!)));
    }
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_expiresAt ?? now),
    );
    if (time == null) return;
    setState(() {
      _expiresAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.scaffold,
      appBar: AppBar(
        title: Text(
          _isEdit
              ? 'Edit offer'
              : widget.duplicateFrom != null
                  ? 'Duplicate offer'
                  : 'New offer',
        ),
        backgroundColor: AdminTheme.surface,
        foregroundColor: AdminTheme.textPrimary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _preview(),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title *'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _subtitleCtrl,
              decoration: const InputDecoration(labelText: 'Subtitle'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tapHintCtrl,
              decoration: const InputDecoration(labelText: 'Tap hint'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PromoActionType>(
              value: _action,
              decoration: const InputDecoration(labelText: 'Action type'),
              items: const [
                DropdownMenuItem(value: PromoActionType.discount, child: Text('Discount code')),
                DropdownMenuItem(value: PromoActionType.info, child: Text('Info only')),
                DropdownMenuItem(value: PromoActionType.browseCategory, child: Text('Browse category')),
              ],
              onChanged: (v) => setState(() => _action = v ?? PromoActionType.discount),
            ),
            if (_action == PromoActionType.discount) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeCtrl,
                decoration: const InputDecoration(labelText: 'Promo code *'),
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    _action == PromoActionType.discount && (v == null || v.trim().isEmpty)
                        ? 'Code required'
                        : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _discountCtrl,
                      decoration: const InputDecoration(labelText: 'Discount %'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _minOrderCtrl,
                      decoration: const InputDecoration(labelText: 'Min order ₹'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
            if (_action == PromoActionType.browseCategory) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v),
              ),
            ],
            if (_action == PromoActionType.info) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _infoCtrl,
                decoration: const InputDecoration(labelText: 'Info message'),
                maxLines: 3,
              ),
            ],
            const SizedBox(height: 16),
            Text('Banner theme', style: AdminTheme.sectionTitle.copyWith(fontSize: 14)),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _colorPresets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final (name, start, end, accent) = _colorPresets[i];
                  final selected = _colorStart == start && _colorEnd == end;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _colorStart = start;
                      _colorEnd = end;
                      _accent = accent;
                    }),
                    child: Container(
                      width: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_hexColor(start), _hexColor(end)],
                        ),
                        borderRadius: AdminTheme.radiusSm,
                        border: Border.all(
                          color: selected ? AdminTheme.accent : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _icon,
              decoration: const InputDecoration(labelText: 'Icon'),
              items: _icons.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: (v) => setState(() => _icon = v ?? 'local_offer'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sortCtrl,
              decoration: const InputDecoration(labelText: 'Sort order (lower = first)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Expiry date'),
              subtitle: Text(
                _expiresAt == null
                    ? 'No expiry'
                    : '${_expiresAt!.day}/${_expiresAt!.month}/${_expiresAt!.year} ${_expiresAt!.hour}:${_expiresAt!.minute.toString().padLeft(2, '0')}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_expiresAt != null)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => setState(() => _expiresAt = null),
                    ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today_rounded),
                    onPressed: _pickExpiry,
                  ),
                ],
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              subtitle: const Text('Show on home screen when not expired'),
              value: _active,
              activeColor: AdminTheme.accent,
              onChanged: (v) => setState(() => _active = v),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AdminTheme.accent,
                minimumSize: const Size.fromHeight(48),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isEdit ? 'Save changes' : 'Create offer'),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  Widget _preview() {
    final preview = PromoOfferModel(
      id: 'preview',
      title: _titleCtrl.text.isEmpty ? 'Offer title' : _titleCtrl.text,
      subtitle: _subtitleCtrl.text.isEmpty ? 'Subtitle text' : _subtitleCtrl.text,
      tapHint: _tapHintCtrl.text,
      action: _action,
      code: _codeCtrl.text.isEmpty ? null : _codeCtrl.text,
      colorStart: _colorStart,
      colorEnd: _colorEnd,
      accentColor: _accent,
      icon: _icon,
    );
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: preview.gradientColors),
        borderRadius: AdminTheme.radiusMd,
      ),
      child: Row(
        children: [
          Icon(preview.iconData, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  preview.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  preview.subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
