import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_dimens.dart';

/// Shown while the session is being restored.
///
/// It has no logic of its own: the router's `redirect` holds navigation here
/// until `authProvider` finishes loading, then routes onward. Keeping the
/// decision in one place (the router) rather than in a splash-screen timer is
/// what makes auto-login deterministic instead of a race.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                  height: 92,
                  width: 92,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: context.finance.balanceGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: const Icon(
                    Icons.savings_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                )
                .animate()
                .scaleXY(begin: 0.6, duration: 550.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 400.ms),
            AppSpacing.xl.gapH,
            Text(AppConstants.appName, style: context.text.headlineMedium)
                .animate(delay: 200.ms)
                .fadeIn()
                .slideY(begin: 0.3, curve: Curves.easeOut),
            AppSpacing.xs.gapH,
            Text(
                  AppConstants.appTagline,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                )
                .animate(delay: 350.ms)
                .fadeIn(),
            AppSpacing.huge.gapH,
            const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ).animate(delay: 500.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}
