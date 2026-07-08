import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/promo_provider.dart';
import '../utils/promo_countdown.dart';
import '../theme/app_theme.dart';
import '../utils/promo_offers.dart';

class PromoBanner extends StatefulWidget {
  /// Called when user taps "browse custom cakes" (or other category promos).
  final void Function(String category)? onBrowseCategory;

  const PromoBanner({super.key, this.onBrowseCategory});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final _controller = PageController();
  int _page = 0;

  void _onTap(PromoOffer offer) {
    switch (offer.action) {
      case PromoAction.applyDiscount:
        context.read<PromoProvider>().apply(offer);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${offer.code} applied — discount at checkout'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      case PromoAction.showInfo:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(offer.infoMessage ?? offer.subtitle),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      case PromoAction.browseCategory:
        final category = offer.category;
        if (category != null) {
          widget.onBrowseCategory?.call(category);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Showing ${offer.title.toLowerCase()}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = PromoOffers.all;

    return Column(
      children: [
        SizedBox(
          height: 172,
          child: PageView.builder(
            controller: _controller,
            padEnds: true,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: banners.length,
            itemBuilder: (_, i) {
              final b = banners[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onTap(b),
                    borderRadius: AppTheme.radiusLg,
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: b.colors,
                        ),
                        borderRadius: AppTheme.radiusLg,
                        boxShadow: [
                          BoxShadow(
                            color: b.colors.first.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 16,
                            bottom: 12,
                            child: Icon(
                              b.icon,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: b.accent.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    b.code != null ? 'OFFER' : 'INFO',
                                    style: AppTheme.labelBold.copyWith(
                                      color: b.accent,
                                      fontSize: 9,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  b.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.displayMedium.copyWith(
                                    color: Colors.white,
                                    fontSize: 19,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  b.subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 11,
                                    height: 1.25,
                                  ),
                                ),
                                if (b.expiresAt != null) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      PromoCountdown.label(b.expiresAt!),
                                      style: AppTheme.labelBold.copyWith(
                                        color: b.accent,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.touch_app_rounded,
                                      size: 13,
                                      color: Colors.white.withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        b.tapHint,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTheme.labelBold.copyWith(
                                          color: Colors.white.withValues(alpha: 0.75),
                                          fontSize: 9,
                                        ),
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
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                gradient: active ? AppTheme.ctaGradient : null,
                color: active ? null : AppTheme.cardBorder,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
