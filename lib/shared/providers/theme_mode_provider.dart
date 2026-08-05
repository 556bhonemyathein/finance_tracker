import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the user's light / dark / system preference.
///
/// [Notifier] is the right primitive here: the state is synchronous, it has
/// initial state available immediately, and it exposes intent-revealing methods
/// (`setMode`, `toggle`) rather than letting the UI mutate raw state.
///
/// Persistence is added in the storage step — [build] will then read the saved
/// value from `SharedPreferences` and [setMode] will write it back.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setMode(ThemeMode mode) => state = mode;

  /// Flips between light and dark; from `system` it jumps to `dark`.
  void toggle() {
    state = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => ThemeMode.dark,
    };
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
  name: 'themeMode',
);
