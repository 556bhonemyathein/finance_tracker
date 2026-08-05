import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';

/// Exposes the active [AppConfig] to the whole provider graph.
///
/// It throws by design: `main()` must override it with the resolved config via
/// `ProviderScope(overrides: [...])`. Failing loudly at start-up beats silently
/// falling back to a dev base URL in a production build.
///
/// This "override at the root" pattern is Riverpod's dependency injection: no
/// service locator, no globals, and tests can inject a fake config by
/// overriding the same provider.
final appConfigProvider = Provider<AppConfig>(
  (Ref ref) => throw UnimplementedError(
    'appConfigProvider must be overridden in ProviderScope',
  ),
  name: 'appConfig',
);
