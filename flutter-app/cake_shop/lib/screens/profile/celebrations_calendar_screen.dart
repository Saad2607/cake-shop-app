import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/celebration.dart';
import '../../providers/celebration_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass/glass_card.dart';
import '../../widgets/glass/primary_button.dart';
import '../../widgets/gradient_header.dart';
import '../catalog/cake_customizer_screen.dart';

class CelebrationsCalendarScreen extends StatelessWidget {
  const CelebrationsCalendarScreen({super.key});

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AddCelebrationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CelebrationProvider>();
    final upcoming = provider.upcomingCelebrations;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: GradientHeader(
        title: 'Celebrations',
        subtitle: 'Never miss a birthday or anniversary',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Occasion',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: upcoming.isEmpty
          ? EmptyState(
              icon: Icons.celebration_outlined,
              title: 'No celebrations added yet',
              subtitle: 'Add family birthdays, anniversaries and special moments to get timely cake reminders.',
              actionLabel: 'Add First Occasion',
              onAction: () => _showAddDialog(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: upcoming.length,
              itemBuilder: (context, i) {
                final item = upcoming[i];
                return _CelebrationCard(celebration: item);
              },
            ),
    );
  }
}

class _CelebrationCard extends StatelessWidget {
  final Celebration celebration;

  const _CelebrationCard({required this.celebration});

  @override
  Widget build(BuildContext context) {
    final days = celebration.daysUntilNext;
    final isToday = celebration.isToday;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppTheme.primary
                        : AppTheme.primaryLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      _getOccasionEmoji(celebration.occasionType),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              celebration.personName,
                              style: AppTheme.titleMedium.copyWith(fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: isToday
                                  ? AppTheme.ctaGradient
                                  : null,
                              color: isToday
                                  ? null
                                  : (days <= 7
                                      ? AppTheme.goldLight
                                      : AppTheme.cardBorder.withValues(alpha: 0.5)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isToday
                                  ? 'TODAY! 🎉'
                                  : (days == 1 ? 'Tomorrow!' : 'In $days days'),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: isToday
                                    ? Colors.white
                                    : (days <= 7 ? const Color(0xFF6B5030) : AppTheme.textMuted),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${celebration.occasionType} · ${DateFormat('dd MMMM').format(celebration.date)}',
                        style: AppTheme.bodySmall.copyWith(
                          fontSize: 11.5,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      if (celebration.cakePreference != null &&
                          celebration.cakePreference!.isNotEmpty)
                        Text(
                          'Prefers: ${celebration.cakePreference}',
                          style: AppTheme.bodySmall.copyWith(
                            fontSize: 10.5,
                            color: AppTheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  color: AppTheme.textMuted.withValues(alpha: 0.6),
                  onPressed: () {
                    context.read<CelebrationProvider>().removeCelebration(celebration.id);
                    AppSnackBar.info(context, 'Celebration removed');
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CakeCustomizerScreen()),
                      );
                    },
                    icon: const Icon(Icons.brush_outlined, size: 15),
                    label: const Text('Custom 3D Cake'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primaryLight, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // returns to catalog / home
                    },
                    icon: const Icon(Icons.cake_outlined, size: 15),
                    label: const Text('Browse Menu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getOccasionEmoji(String occasion) {
    switch (occasion.toLowerCase()) {
      case 'birthday':
        return '🎂';
      case 'anniversary':
        return '💍';
      case 'graduation':
        return '🎓';
      case 'festival':
        return '🪔';
      default:
        return '✨';
    }
  }
}

class _AddCelebrationSheet extends StatefulWidget {
  const _AddCelebrationSheet();

  @override
  State<_AddCelebrationSheet> createState() => _AddCelebrationSheetState();
}

class _AddCelebrationSheetState extends State<_AddCelebrationSheet> {
  final _nameController = TextEditingController();
  final _cakeController = TextEditingController();
  String _occasion = 'Birthday';
  DateTime _date = DateTime.now().add(const Duration(days: 7));

  static const _occasions = ['Birthday', 'Anniversary', 'Graduation', 'Festival', 'Special'];

  @override
  void dispose() {
    _nameController.dispose();
    _cakeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primary,
            onPrimary: Colors.white,
            surface: AppTheme.surface,
            onSurface: AppTheme.textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppSnackBar.error(context, 'Please enter name');
      return;
    }

    final newOccasion = Celebration(
      id: 'cel-${DateTime.now().millisecondsSinceEpoch}',
      personName: name,
      occasionType: _occasion,
      date: _date,
      cakePreference: _cakeController.text.trim().isNotEmpty ? _cakeController.text.trim() : null,
    );

    context.read<CelebrationProvider>().addCelebration(newOccasion);
    Navigator.pop(context);
    AppSnackBar.success(context, 'Celebration reminder saved! 🎉');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Add Celebration Reminder', style: AppTheme.titleLarge),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Person / Event Name',
              hintText: 'e.g. Diya (Best Friend)',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _occasion,
            decoration: const InputDecoration(
              labelText: 'Occasion Type',
              prefixIcon: Icon(Icons.celebration_outlined),
            ),
            items: _occasions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: (v) => setState(() => _occasion = v!),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.cardBorder),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('EEEE, dd MMMM').format(_date),
                    style: AppTheme.titleMedium.copyWith(fontSize: 14),
                  ),
                  const Spacer(),
                  const Text('Change', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cakeController,
            decoration: const InputDecoration(
              labelText: 'Favorite Flavor / Notes (optional)',
              hintText: 'e.g. Belgian Chocolate, loves strawberries',
              prefixIcon: Icon(Icons.cake_outlined),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Save Occasion',
            icon: Icons.check_rounded,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
