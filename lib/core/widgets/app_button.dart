import 'package:flutter/material.dart';

import '../extensions/extensions.dart';
import '../theme/app_dimens.dart';

/// Visual weight of a button, mapped to a Material 3 button type.
enum AppButtonVariant { primary, secondary, tonal, text, danger }

/// The app's one button.
///
/// Every button in PocketPilot is this widget. That is what guarantees a
/// consistent height, radius, disabled treatment and — crucially — a
/// consistent *loading* state: an async action swaps the label for a spinner
/// and blocks re-entry, so double-tapping "Save" can never create two
/// transactions.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
  });

  const AppButton.secondary({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.text({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
  }) : variant = AppButtonVariant.text;

  const AppButton.danger({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
  }) : variant = AppButtonVariant.danger;

  final String label;

  /// `null` disables the button — the standard Flutter idiom, kept so callers
  /// can write `onPressed: isValid ? _submit : null`.
  final VoidCallback? onPressed;

  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;
    final Widget child = _buildChild(context);

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.tonal => FilledButton.tonal(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.danger => FilledButton(
        onPressed: effectiveOnPressed,
        style: FilledButton.styleFrom(
          backgroundColor: context.colors.errorContainer,
          foregroundColor: context.colors.onErrorContainer,
        ),
        child: child,
      ),
    };

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildChild(BuildContext context) {
    // AnimatedSwitcher keeps the swap from being a jarring pop, and the fixed
    // spinner size stops the button resizing mid-transition.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: isLoading
          ? SizedBox(
              key: const ValueKey<String>('loading'),
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: variant == AppButtonVariant.primary
                    ? context.colors.onPrimary
                    : context.colors.primary,
              ),
            )
          : Row(
              key: const ValueKey<String>('label'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 18),
                  AppSpacing.sm.gapW,
                ],
                Flexible(
                  child: Text(label, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
    );
  }
}
