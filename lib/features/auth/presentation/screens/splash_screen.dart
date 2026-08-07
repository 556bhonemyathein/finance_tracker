import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_assets.dart';
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
            // The launcher artwork itself, so the icon the user tapped and the
            // mark that greets them are the same image. The gradient and the
            // rounded corners are baked into the asset.
            Image.asset(
                  AppAssets.logo,
                  height: 92,
                  width: 92,
                  // The source is 1024² for the icon pipeline; decoding it at
                  // display size keeps ~4MB of pixels out of the image cache.
                  cacheHeight: 276,
                  cacheWidth: 276,
                  filterQuality: FilterQuality.medium,
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
