import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_routes.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/providers/core_providers.dart';

/// First-run introduction.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();

  /// Page index is pure UI state confined to this widget, so it stays in
  /// `setState` — promoting it to a provider would add indirection with no
  /// benefit and would survive navigation, which is not what we want.
  int _page = 0;

  static const List<_Slide> _slides = <_Slide>[
    _Slide(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Every penny, accounted for',
      body:
          'Log income, expenses and transfers in seconds. '
          'PocketPilot keeps the running balance so you never guess.',
    ),
    _Slide(
      icon: Icons.insights_rounded,
      title: 'See where it actually goes',
      body:
          'Weekly, monthly and yearly reports turn a list of transactions '
          'into a picture you can act on.',
    ),
    _Slide(
      icon: Icons.cloud_off_rounded,
      title: 'Works without a signal',
      body:
          'Everything is saved on your device first and synced when '
          "you're back online. No spinners on the underground.",
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref
        .read(preferencesServiceProvider)
        .setOnboardingSeen(value: true);
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _page == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (int index) => setState(() => _page = index),
                itemBuilder: (BuildContext context, int index) =>
                    _SlideView(slide: _slides[index]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (int i = 0; i < _slides.length; i++)
                  AnimatedContainer(
                    duration: 250.ms,
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    width: i == _page ? 24 : 6,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? context.colors.primary
                          : context.colors.outlineVariant,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
              ],
            ),
            AppSpacing.xxl.gapH,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: AppButton(
                label: isLast ? 'Get started' : 'Next',
                onPressed: isLast
                    ? _finish
                    : () => _controller.nextPage(
                        duration: 320.ms,
                        curve: Curves.easeOutCubic,
                      ),
              ),
            ),
            AppSpacing.xl.gapH,
          ],
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 140,
            width: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: context.finance.balanceGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Icon(slide.icon, size: 64, color: Colors.white),
          ).animate().scaleXY(begin: 0.85, duration: 400.ms).fadeIn(),
          AppSpacing.huge.gapH,
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: context.text.headlineSmall,
          ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),
          AppSpacing.md.gapH,
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ).animate(delay: 200.ms).fadeIn(),
        ],
      ),
    );
  }
}
