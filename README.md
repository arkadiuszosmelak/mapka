# Mapka

Flutter **monorepo** (Melos) built on the conventions in
[`project_fundations.md`](project_fundations.md): pragmatic Clean Architecture,
Bloc/Cubit + hooks, Injectable + GetIt, GoRouter, a token-based design system,
and per-module localization.

## Modules

| Module           | Type          | Depends on                       | Purpose                                              |
| ---------------- | ------------- | -------------------------------- | ---------------------------------------------------- |
| `app`            | App           | all modules                      | Shell: DI root, router assembly, theme, localization |
| `core`           | Core          | — (external only)                | `ModuleManifest`, `BaseCubit`, `Result`, errors, DI  |
| `design_system`  | Design System | `core`                           | Design tokens (`context.colors/…`) + `Dor*` widgets  |
| `d_translations` | Data (`d_`)   | `core`                           | **All** translations (`Strings`, `context.strings`)  |
| `f_onboarding`   | Feature (`f_`)| `core`, `design_system`          | Onboarding flow (intro carousel + permissions)       |
| `f_home`         | Feature (`f_`)| `core`, `design_system`, `d_translations` | Post-onboarding landing screen              |
| `module_template`| —             | `core`, `design_system`          | Template copied by `tools/create_module.sh`          |

Dependency rules (enforced by convention; see the foundations doc): features
never import other features — they communicate through the `app` layer
(routing/callbacks). Every module depends on `core`; `core` depends on nothing
local.

## Getting started

Flutter is pinned via FVM in [`.fvmrc`](.fvmrc) (3.44.0).

```bash
dart pub global activate melos   # once

melos bootstrap                  # install + link all packages
melos intl                       # generate localization classes (intl_utils)
melos gen                        # build_runner (DI, mocks)
melos analyze                    # static analysis (zero warnings)
melos test                       # unit tests
```

Run the app (platform folders live in `modules/app`):

```bash
cd modules/app && flutter run
```

## How the pieces fit

- **Modules** expose a `ModuleManifest` (DI module + route guards + observers).
  `app/lib/modules.dart` lists them; the app aggregates their micro-package DI
  modules into a single `GetIt` (`core` first).
- **Routing**: each module exposes `getXSubtree(...)` returning `List<RouteBase>`.
  Pages receive **navigation callbacks** (e.g. `onCompleted`) bound in the
  module's `routes.dart` — they never reach for another module's routes.
  `app/lib/routing/app_router.dart` composes the subtrees.
- **State**: cubits extend `BaseCubit<State, PresentationEvent>` (Equatable
  state + one-shot presentation events via `bloc_presentation`). Pages resolve
  them with `useBloc<T>()` (hooked_bloc → GetIt).
- **Design tokens**: read through `context.colors`, `context.typography`,
  `context.spacing`, `context.radius`. Never hardcode colors/sizes/spacing.
- **Routing**: the root `GoRouter` lives in DI (`AppRouter`, with a
  `rootNavigatorKey`, an `errorBuilder`, and a `/` → onboarding redirect). Route
  identities are `RouteDefinition` constants; navigate by `name`.
- **Logging & errors**: one DI-provided `Talker` instance is the log sink —
  bloc events (`TalkerBlocObserver`) and route changes (`TalkerRouteObserver`)
  feed it. `bootstrap` runs the app in `runZonedGuarded` and funnels
  `FlutterError.onError`, `PlatformDispatcher.onError` and zone errors into
  `ErrorReporter`. The app's `ErrorReporter` (`CrashlyticsErrorReporter`) logs
  to Talker **and** records to Firebase Crashlytics (uncaught → `fatal: true`,
  handled → non-fatal); `core` stays crash-reporting-agnostic. A native splash
  is held until DI is ready.
- **Localization**: centralized in `d_translations` (single ARB source +
  `intl_utils` → the `Strings` class). Every module reads strings via
  `context.strings.<key>`; keys are prefixed per module (`app_*`,
  `f_onboarding_*`, …). The app registers the single `Strings.delegate`.

## Flavors

Three flavors — `dev`, `staging`, `prod` — with separate app IDs and names so
they install side by side:

| Flavor    | Android applicationId      | iOS bundle id              | Name          |
| --------- | -------------------------- | -------------------------- | ------------- |
| `dev`     | `com.croxoner.mapka.dev`     | `com.croxoner.mapka.dev`     | Mapka Dev     |
| `staging` | `com.croxoner.mapka.staging` | `com.croxoner.mapka.staging` | Mapka Staging |
| `prod`    | `com.croxoner.mapka`         | `com.croxoner.mapka`         | Mapka         |

Each flavor has its own entry point (`lib/main_<flavor>.dart`) calling
`bootstrap(AppFlavor.x)`; the active `AppFlavor` is registered in DI. Non-prod
builds show a corner banner.

Run from VS Code via `.vscode/launch.json` (Mapka dev/staging/prod), or:

```bash
cd modules/app
flutter run --flavor dev    -t lib/main_dev.dart
flutter run --flavor prod   -t lib/main_prod.dart --release
```

- **Android**: `productFlavors` in `modules/app/android/app/build.gradle.kts`.
- **iOS**: per-flavor build configurations (`Debug-dev`, …) + shared schemes
  (`dev`/`staging`/`prod`), generated by `modules/app/ios/setup_flavors.rb`
  (re-run after adding a flavor: `GEM_HOME=/tmp/mapka-gems ruby ios/setup_flavors.rb`).

## Adding a module

```bash
tools/create_module.sh f_profile
# then register ProfileModule in app/lib/modules.dart,
# add its subtree in app/lib/routing/app_router.dart, and `melos bootstrap`.
```

## Release signing (Android)

Release builds are signed from `modules/app/android/key.properties` (gitignored;
see `key.properties.example`). The keystore (`app/mapka-release.jks`, also
gitignored) holds key alias `mapka-alias`. When `key.properties` is absent the
build falls back to debug keys, so local/PR builds work without it.

In CI the keystore + `key.properties` are recreated from these GitHub Secrets:

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | `base64` of `mapka-release.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | store password |
| `ANDROID_KEY_PASSWORD` | key password |
| `ANDROID_KEY_ALIAS` | `mapka-alias` |
| `FIREBASE_SERVICE_ACCOUNT` | service-account JSON (App Distribution); optional |
| `MAPBOX_DOWNLOADS_TOKEN` | Mapbox secret `sk.` token (build-time SDK download) |
| `MAPBOX_ACCESS_TOKEN` | Mapbox public `pk.` token (runtime, via `--dart-define`) |

## Mapbox tokens

Two different tokens, two different homes (neither committed):

- **`sk.` download token** (build-time, secret) → `~/.gradle/gradle.properties`
  as `MAPBOX_DOWNLOADS_TOKEN` locally; GitHub Secret of the same name in CI.
  Needed to fetch the native Mapbox SDK.
- **`pk.` access token** (runtime) → `modules/app/config/<flavor>.json`
  (gitignored; copy `config/example.json`), read in Dart via
  `MapboxConfig.accessToken` (`String.fromEnvironment`) and applied in
  `bootstrap`. Launch configs pass `--dart-define-from-file=config/<flavor>.json`;
  CI passes it from the `MAPBOX_ACCESS_TOKEN` secret. Restrict this token in the
  Mapbox dashboard (URL / package / SHA).

## CI

- [`ci.yaml`](.github/workflows/ci.yaml) — on PRs: bootstrap → intl → gen →
  analyze → test.
- [`android-build.yaml`](.github/workflows/android-build.yaml) — manual
  (pick a flavor) or on `v*` tags: builds a signed release APK per flavor,
  uploads it as a run artifact (30-day retention), and — for `dev`/`staging`
  when `FIREBASE_SERVICE_ACCOUNT` is set — ships it to **Firebase App
  Distribution** (group `testers`). App ID per flavor is read from
  `google-services.json`. `prod` is left for the Play Store.
