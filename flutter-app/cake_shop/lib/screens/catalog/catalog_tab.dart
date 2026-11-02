import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cake_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cake_card_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_search_bar.dart';
import '../../widgets/sort_filter_sheet.dart';
import 'cake_customizer_screen.dart';
import 'cake_detail_screen.dart';

class CatalogTab extends StatefulWidget {
  final String? initialCategory;

  const CatalogTab({super.key, this.initialCategory});

  @override
  State<CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends State<CatalogTab> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  static const _categories = [
    ('ALL', 'All Creations', Icons.auto_awesome_rounded),
    ('BIRTHDAY', 'Birthday', Icons.celebration_rounded),
    ('WEDDING', 'Wedding', Icons.favorite_rounded),
    ('CUPCAKE', 'Cupcakes', Icons.cake_rounded),
    ('CUSTOM', 'Custom', Icons.brush_rounded),
    ('SEASONAL', 'Seasonal', Icons.ac_unit_rounded),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CakeProvider>().setCategory(widget.initialCategory!);
      });
    }
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value, CakeProvider provider) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 320), () {
      provider.setSearch(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CakeProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Explore Menu', style: AppTheme.displayMedium),
                            const SizedBox(height: 2),
                            Text(
                              'Handcrafted artisan cakes & desserts',
                              style: AppTheme.bodySmall,
                            ),
                          ],
                        ),
                        GlassContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          borderRadius: AppTheme.radiusPill,
                          child: Text(
                            '${provider.displayCakes.length} items',
                            style: AppTheme.labelBold.copyWith(
                              color: AppTheme.primary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GlassSearchBar(
                      controller: _searchController,
                      hintText: 'Search by cake, flavor, theme…',
                      onChanged: (v) => _onSearchChanged(v, provider),
                      onClear: () => provider.setSearch(''),
                      onFilterTap: () => showSortFilterSheet(context, provider),
                      hasActiveFilter: provider.sortOption != CakeSortOption.recommended,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final cat = _categories[i];
                          final isSelected = provider.selectedCategory == cat.$1;
                          return GestureDetector(
                            onTap: () {
                              if (cat.$1 == 'CUSTOM') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const CakeCustomizerScreen()),
                                );
                              } else {
                                provider.setCategory(cat.$1);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: AppTheme.radiusPill,
                                gradient: isSelected
                                    ? AppTheme.ctaGradient
                                    : null,
                                color: isSelected
                                    ? null
                                    : Colors.white.withValues(alpha: 0.8),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.85)
                                      : AppTheme.cardBorder,
                                  width: 1.2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primary.withValues(alpha: 0.28),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : [AppTheme.softShadow],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    cat.$3,
                                    size: 15,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat.$2,
                                    style: AppTheme.labelBold.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textDark,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: provider.isLoading && provider.cakes.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                )
              : provider.displayCakes.isEmpty
                  ? EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No cakes found',
                      subtitle: 'Try adjusting your search query or filters.',
                      actionLabel: _searchController.text.isNotEmpty
                          ? 'Clear search'
                          : null,
                      onAction: () {
                        _searchController.clear();
                        provider.setSearch('');
                      },
                    )
                  : RefreshIndicator(
                      color: AppTheme.primary,
                      onRefresh: provider.loadCakes,
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.58,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: provider.displayCakes.length,
                        itemBuilder: (context, i) {
                          final cake = provider.displayCakes[i];
                          return CakeCardWidget(
                            cake: cake,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CakeDetailScreen(cakeId: cake.id),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }
}
