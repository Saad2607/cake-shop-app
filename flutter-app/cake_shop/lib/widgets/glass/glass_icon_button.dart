import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Tactile Liquid Glass Icon Button with spring scale animation,
/// frosted background, specular edge highlight, and optional badge counter.
class GlassIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool active;
  final int? badgeCount;
  final String? tooltip;

  const GlassIconButton({
    super.key,
    required this.icon,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    this.size = 44,
    this.iconSize = 20,
    this.iconColor,
    this.backgroundColor,
    this.active = false,
    this.badgeCount,
    this.tooltip,
  }) : onTap = onTap ?? onPressed;

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) _animController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) _animController.reverse();
  }

  void _onTapCancel() {
    if (widget.onTap != null) _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = widget.iconColor ??
        (widget.active ? AppTheme.primary : AppTheme.textDark);

    Widget button = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              widget.active
                  ? BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.24),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    )
                  : AppTheme.softShadow,
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.active
                        ? [
                            AppTheme.primaryLight.withValues(alpha: 0.8),
                            AppTheme.cream.withValues(alpha: 0.9),
                          ]
                        : [
                            widget.backgroundColor ?? Colors.white.withValues(alpha: 0.78),
                            widget.backgroundColor?.withValues(alpha: 0.5) ??
                                Colors.white.withValues(alpha: 0.52),
                          ],
                  ),
                  border: Border.all(
                    color: widget.active
                        ? AppTheme.primary.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.88),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        size: widget.iconSize,
                        color: effectiveIconColor,
                      ),
                      if (widget.badgeCount != null && widget.badgeCount! > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppTheme.ctaGradient,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${widget.badgeCount}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}
