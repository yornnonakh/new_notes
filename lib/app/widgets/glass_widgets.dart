import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.blur = 20,
    this.opacity = 0.8, // Increased for a more "white card" look while keeping glass effect
    this.borderRadius = 20,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.1) 
                : AppTheme.cardColor.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.1) 
                  : AppTheme.dividerColor,
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double borderRadius;

  const GlassButton({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: LiquidGlassContainer(
        borderRadius: borderRadius,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        opacity: 0.2, // Keep buttons more transparent
        child: child,
      ),
    );
  }
}
