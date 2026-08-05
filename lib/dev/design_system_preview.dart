import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/extensions/extensions.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/app_typography.dart';
import '../shared/providers/theme_mode_provider.dart';

/// TEMPORARY — a visual smoke test for the theme built in step 1.
///
/// It renders the type scale, the semantic finance colours and a glass panel so
/// light/dark can be eyeballed before any real feature exists. This file is
/// deleted once go_router and the dashboard land.
class DesignSystemPreview extends ConsumerWidget {
  const DesignSystemPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            tooltip: 'Toggle theme (current: ${mode.name})',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            icon: Icon(
              context.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
          ),
          AppSpacing.sm.gapW,
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.page),
              children: [
                Text(AppConstants.appTagline, style: context.text.displaySmall)
                    .animate()
                    .fadeIn(duration: AppConstants.durationMedium)
                    .slideY(begin: 0.15, curve: Curves.easeOutCubic),
                AppSpacing.sm.gapH,
                Text(
                  'Design tokens preview — step 1 foundation.',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                AppSpacing.xxl.gapH,
                const _BalanceCard(),
                AppSpacing.lg.gapH,
                Row(
                  children: [
                    _StatChip(
                      label: 'Income',
                      value: 4820.0.toCompactCurrency(),
                      color: context.finance.income,
                      icon: Icons.south_west_rounded,
                    ).expanded,
                    AppSpacing.md.gapW,
                    _StatChip(
                      label: 'Expense',
                      value: 2364.5.toCompactCurrency(),
                      color: context.finance.expense,
                      icon: Icons.north_east_rounded,
                    ).expanded,
                  ],
                ),
                AppSpacing.xxl.gapH,
                FilledButton(onPressed: () {}, child: const Text('Filled button')),
                AppSpacing.md.gapH,
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Outlined button'),
                ),
                AppSpacing.md.gapH,
                const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search transactions',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                AppSpacing.xxxl.gapH,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gradient hero card — the shape the real dashboard balance card will take.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          colors: context.finance.balanceGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current balance',
            style: context.text.labelMedium?.copyWith(color: Colors.white70),
          ),
          AppSpacing.sm.gapH,
          Text(
            12480.75.toCurrency(),
            style: context.text.displayMedium?.copyWith(
              color: Colors.white,
              fontFeatures: AppTypography.tabularFigures,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppConstants.durationSlow).scaleXY(
      begin: 0.97,
      curve: Curves.easeOutBack,
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.14),
            child: Icon(icon, size: 16, color: color),
          ),
          AppSpacing.md.gapH,
          Text(label, style: context.text.labelMedium),
          AppSpacing.xxs.gapH,
          Text(value, style: context.text.titleLarge?.copyWith(color: color)),
        ],
      ),
    );
  }
}

