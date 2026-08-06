import 'dart:ui';

import 'package:flutter/material.dart';

import '../extensions/extensions.dart';
import '../theme/app_dimens.dart';

/// A frosted-glass surface.
///
/// Real glassmorphism needs a `BackdropFilter`, which is genuinely expensive:
/// it forces the compositor to read back what is behind it. So this is used
/// sparingly — the floating nav bar and the dashboard's overlay cards — and
/// never inside a scrolling list, where the readback would run per frame per
/// item.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    super.key,
    this.borderRadius,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.blur = 18,
    this.showBorder = true,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final double blur;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius =
        borderRadius ?? BorderRadius.circular(AppRadius.lg);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.finance.glass,
            borderRadius: radius,
            border: showBorder
                ? Border.all(color: context.finance.glassBorder)
                : null,
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// The standard opaque content card.
///
/// Used everywhere a panel is *not* overlaying something interesting — which
/// is most places. Cheap: no backdrop readback, just a rounded surface.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.borderRadius,
    this.color,
    this.showBorder = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? color;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius =
        borderRadius ?? BorderRadius.circular(AppRadius.lg);

    return Material(
      color: color ?? context.theme.cardTheme.color,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      shape: showBorder
          ? RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: context.colors.outlineVariant),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
