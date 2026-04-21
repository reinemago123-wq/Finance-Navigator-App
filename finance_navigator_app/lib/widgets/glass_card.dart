import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme.dart';

// ─────────────────────────────────────────────
//  GlassCard — frosted glass effect container
//  Used throughout the app for cards, panels, etc.
// ─────────────────────────────────────────────

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double blurStrength;
  final List<BoxShadow>? shadows;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.blurStrength = 12.0,
    this.shadows,
  });

  /// Gold-tinted glass variant
  factory GlassCard.gold({
    required Widget child,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) =>
      GlassCard(
        padding: padding,
        borderRadius: borderRadius,
        backgroundColor: AppColors.glassGold,
        borderColor: AppColors.glassGoldBorder,
        blurStrength: 16,
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? Rd.card,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurStrength,
          sigmaY: blurStrength,
        ),
        child: Container(
          padding: padding ?? const EdgeInsets.all(Sp.md),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.glassWhite,
            borderRadius: borderRadius ?? Rd.card,
            border: Border.all(
              color: borderColor ?? AppColors.glassBorder,
              width: 1.0,
            ),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }
}