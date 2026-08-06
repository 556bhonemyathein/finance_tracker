# PocketPilot

An offline-first personal finance tracker built with Flutter, Riverpod 3 and Isar.

Everything is written to the device first and reconciled with the server later,
so the app is fully usable on a plane, on the underground, or with no backend at
all.

---

## Running

```bash
flutter pub get
dart run build_runner build          # Freezed / json_serializable / Isar schemas
flutter run
```

The default (`dev`) flavour runs against the **on-device backend**: accounts,
sessions and password resets are all satisfied from Isar, so every screen works
with no server. Point it at a real API with:

```bash
flutter run --dart-define=FLAVOR=prod
```

### Release builds

```bash
flutter build apk --release --no-tree-shake-icons
```

`--no-tree-shake-icons` is required: the category icon picker builds `IconData`
from a runtime code point, which the icon tree-shaker cannot analyse. This is
the standard trade-off for any app with a user-facing icon picker.

---

## Architecture

Clean architecture, feature-first.

```
lib/
├── core/                    # cross-cutting infrastructure
│   ├── config/              # flavors, AppConfig, routes, GoRouter
│   ├── constants/           # endpoints, storage keys, app constants
│   ├── theme/               # M3 theme, type scale, design tokens
│   ├── network/             # Dio + auth/retry/error interceptors
│   ├── storage/             # Isar, secure storage, preferences
│   ├── services/            # sync, hashing, local token issuer
│   ├── errors/              # AppException (data) → Failure (UI)
│   ├── extensions/          # context / num / date / string / widget
│   ├── utils/               # Result<T>, logger
│   └── widgets/             # AppButton, AppTextField, states, shell…
├── features/                # auth, dashboard, transactions, categories,
│   └── <feature>/           # reports, profile, settings
│       ├── data/            # data sources + repository implementation
│       ├── domain/          # repository interface, pure logic
│       └── presentation/    # providers, screens, widgets
└── shared/                  # models and providers used by many features
```

**The dependency rule.** `presentation` depends on `domain`; `data` implements
`domain`. A screen never imports Dio or Isar — it asks a repository interface,
and Riverpod decides which implementation answers.

**Errors.** The data layer throws `AppException` (technical). `FailureMapper`
converts it once into a sealed `Failure` carrying user-safe copy. Both are
`sealed`, so a new error type makes the compiler list every site that needs to
handle it.

**Results.** Repositories return `Result<T>` rather than throwing, which makes
fallibility part of the signature instead of a runtime surprise.

---

## Offline-first

Isar is the source of truth. Writes always land locally and are stamped with a
`SyncStatus`:

| Status | Meaning |
| --- | --- |
| `synced` | local matches server |
| `pendingCreate` | created offline, server has never seen it |
| `pendingUpdate` | exists remotely, edited offline |
| `pendingDelete` | tombstoned locally, server still has it |

Rows carry a **client-generated UUID**, so a replayed push updates the existing
row rather than duplicating it. Deletes are tombstones, which makes undo instant
and lets the deletion still be replayed. `SyncCoordinator` watches connectivity
and drains the queue on the offline → online edge.

---

## State management

Riverpod 3, written by hand (no codegen — `riverpod_generator` and
`isar_community_generator` require incompatible analyzer versions).

| Primitive | Used for | Example |
| --- | --- | --- |
| `Provider` | DI and derived values | `authRepositoryProvider` |
| `Notifier` | sync state with intent methods | `TransactionQueryNotifier` |
| `AsyncNotifier` | async state + commands | `AuthNotifier` |
| `FutureProvider` | one-shot async reads | `reportByCategoryProvider` |
| `StreamProvider` | live Isar / connectivity feeds | `categoriesProvider` |
| `.family` | parameterised caching | `transactionPageProvider(query)` |

`TransactionQuery` is a Freezed value object, so `family` caches by *content* —
two screens with the same filters share one database subscription.

---

## Testing

```bash
flutter test
```

92 tests: unit (extensions, `Result`, CSV/PDF export), repository (against a
**real** Isar database), and widget (the shared component library).

The repository tests need the Isar native library, which `flutter test` cannot
download because the test binding stubs out HTTP. Fetch it once:

```bash
mkdir -p .isar
curl -L -o .isar/libisar.dll https://binaries.isar-community.dev/3.3.2/isar_windows_x64.dll
# linux:  .../libisar_linux_x64.so  → .isar/libisar.so
# macOS:  .../libisar_macos.dylib   → .isar/libisar.dylib
```

---

## Notable deviations from the original spec

| Requested | Shipped | Why |
| --- | --- | --- |
| `isar` | `isar_community` | Upstream Isar is unmaintained and will not resolve on Dart 3.12. Same API. |
| Riverpod codegen | hand-written providers | `riverpod_generator` needs analyzer ^13; `isar_community_generator` caps at <11. All required primitives are used. |
| `riverpod_lint` / `custom_lint` | omitted | Not yet compatible with Riverpod 3.4. |
| Firebase (FCM, Crashlytics, Analytics) | **not yet wired** | Needs `google-services.json` / `GoogleService-Info.plist`. `TODO(crashlytics)` seams are in place in `main.dart` and `AppLogger`. |
| Easy Localization | dependency + language picker only | Strings are not yet extracted to ARB/JSON; the picker persists the choice. |

## Not yet built

- Firebase notifications, Crashlytics and Analytics
- Translation files (the localisation *plumbing* is present, the strings are not)
- Backup restore reads pasted JSON rather than opening a file picker
