import 'package:flutter/material.dart';

/// Layout sugar that keeps `build` methods shallow.
///
/// Deeply nested `Padding(child: Center(child: ...))` pyramids are the main
/// reason Flutter UI code becomes hard to read; chaining reads top-to-bottom.
extension WidgetX on Widget {
  Widget paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );

  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => Padding(
    padding: EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    ),
    child: this,
  );

  Widget get expanded => Expanded(child: this);

  Widget flexible({int flex = 1}) => Flexible(flex: flex, child: this);

  Widget get centered => Center(child: this);

  Widget sliver() => SliverToBoxAdapter(child: this);

  Widget rounded(double radius) =>
      ClipRRect(borderRadius: BorderRadius.circular(radius), child: this);

  /// Renders the widget only when [condition] holds, otherwise nothing.
  Widget showIf(bool condition) =>
      condition ? this : const SizedBox.shrink();

  Widget onTap(VoidCallback? onTap, {BorderRadius? borderRadius}) =>
      InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: this,
      );
}

/// `12.gapH` / `12.gapW` instead of `SizedBox(height: 12)`.
extension GapX on num {
  Widget get gapH => SizedBox(height: toDouble());

  Widget get gapW => SizedBox(width: toDouble());
}
