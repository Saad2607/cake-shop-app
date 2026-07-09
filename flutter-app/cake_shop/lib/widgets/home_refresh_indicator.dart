import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Material-style pull refresh: white floating circle + burgundy arrow.
class HomeRefreshIndicator extends StatefulWidget {
  final RefreshIndicatorMode refreshState;
  final double pulledExtent;
  final double refreshTriggerPullDistance;
  final double refreshIndicatorExtent;

  const HomeRefreshIndicator({
    super.key,
    required this.refreshState,
    required this.pulledExtent,
    required this.refreshTriggerPullDistance,
    required this.refreshIndicatorExtent,
  });

  @override
  State<HomeRefreshIndicator> createState() => _HomeRefreshIndicatorState();
}

class _HomeRefreshIndicatorState extends State<HomeRefreshIndicator>
    with SingleTickerProviderStateMixin {
  static const _circleSize = 48.0;
  static const _iconSize = 26.0;

  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didUpdateWidget(HomeRefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    final refreshing = widget.refreshState == RefreshIndicatorMode.refresh;
    if (refreshing && !_spin.isAnimating) {
      _spin.repeat();
    } else if (!refreshing && _spin.isAnimating) {
      _spin.stop();
      _spin.reset();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final refreshing = widget.refreshState == RefreshIndicatorMode.refresh;
    final pulled = widget.pulledExtent;

    if (!refreshing && pulled < 16) {
      return const SizedBox.shrink();
    }

    final extent = refreshing
        ? widget.refreshIndicatorExtent
        : pulled.clamp(0.0, widget.refreshIndicatorExtent);

    final revealStart = 36.0;
    final opacity = refreshing
        ? 1.0
        : ((pulled - revealStart) / 28).clamp(0.0, 1.0);

    if (!refreshing && opacity <= 0) {
      return SizedBox(height: extent);
    }

    final pullProgress =
        (pulled / widget.refreshTriggerPullDistance).clamp(0.0, 1.0);
    final pullRotation = pullProgress * math.pi * 1.35;

    return SizedBox(
      height: extent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: _circleSize,
              height: _circleSize,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryDark.withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: refreshing
                    ? RotationTransition(
                        turns: _spin,
                        child: const Icon(
                          Icons.refresh_rounded,
                          size: _iconSize,
                          color: AppTheme.primaryDark,
                        ),
                      )
                    : Transform.rotate(
                        angle: pullRotation,
                        child: const Icon(
                          Icons.refresh_rounded,
                          size: _iconSize,
                          color: AppTheme.primaryDark,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
