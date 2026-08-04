# EcoUnity App

EcoUnity is a Flutter mobile app for sustainability education, social mixing, and practical classroom action. The app is planned around the 17 Sustainable Development Goals, with each SDG module combining short learning content, interactive stories, quizzes or reflections, practical challenges, progress tracking, badges, and teacher support.

The current codebase is the Flutter app foundation for the native EcoUnity mobile app. It uses backend-driven content from the shared Innoventum `core` package, local progress storage, generated localization, and reusable learning activity screens.

## Funding

<img src="assets/images/erasmusplus.png" alt="Erasmus+ logo" width="220">

EcoUnity is created as part of an Erasmus+ funded project.

Funded by the European Union. Views and opinions expressed are however those of the author(s) only and do not necessarily reflect those of the European Union or the European Education and Culture Executive Agency (EACEA). Neither the European Union nor EACEA can be held responsible for them.

## Project Status

This repository currently contains the app baseline for EcoUnity:

- Flutter app shell with authentication and guest access.
- Provider-based state management.
- Backend content loading through `core.WebPageProvider`.
- Hive-backed local progress and badge notification state.
- SDG/module, resource, video, wiki, slides, quiz, drag-drop, badge, dashboard, and settings screens.
- Generated app localization for the PDF-approved language set.
- Architecture and development plan in `docs/`.

The content architecture target is documented in [docs/FLUTTER_ARCHITECTURE_AND_DEVELOPMENT_PLAN.md](docs/FLUTTER_ARCHITECTURE_AND_DEVELOPMENT_PLAN.md).

## Language Baseline

The app base supports the language set defined by the WP5.A2 PDF specifications:

- German (`de`)
- English (`en`)
- Spanish (`es`)
- Finnish (`fi`)
- Polish (`pl`)
- Romanian (`ro`)
- Ukrainian (`uk`)

App shell strings live in `lib/l10n/intl_*.arb` and generated localization files live in `lib/l10n/app_localizations*.dart`.

## Tech Stack

- Flutter `>=3.35.0`
- Dart `>=3.9.0 <4.0.0`
- Provider for state management
- Hive CE for local storage
- Flutter generated localization
- Shared Innoventum `core` package for API, auth, content, storage, forms, badges, and image loading

## Repository Structure

```text
assets/                 App images and configuration
docs/                   Architecture and WP5.A2 specification documents
lib/main.dart           App bootstrap, providers, localization, auth gate
lib/l10n/               ARB files and generated localization classes
lib/src/objects/        App-specific domain extensions and Hive models
lib/src/providers/      App-specific providers
lib/src/screens/        Feature screens
lib/src/util/           Router, settings, storage, theme, helpers
lib/src/widgets/        Shared UI widgets
test/                   Smoke and regression tests
```

## Setup

1. Install Flutter and make sure the project SDK constraints are satisfied.

   ```sh
   flutter --version
   ```

2. Ensure you have access to the Innoventum `core` package.

   `pubspec.yaml` declares `core` from Git, and this development checkout currently has a local `dependency_overrides` path:

   ```yaml
   dependency_overrides:
     core:
       path: /Users/jleinone/flutter_projects/core/core
   ```

   If your local `core` checkout is elsewhere, update the override path or remove the override to use the Git dependency.

3. Install dependencies.

   ```sh
   flutter pub get
   ```

4. Run the app.

   ```sh
   flutter run
   ```

## Generated Files

Localization files are generated from `lib/l10n/intl_*.arb` using Flutter gen-l10n:

```sh
flutter gen-l10n
```

Hive adapters are generated with build runner:

```sh
flutter pub run build_runner build
```

The helper script runs both localization and adapter generation:

```sh
./generate.sh
```

## Tests and Checks

Run the smoke tests:

```sh
flutter test
```

Run static analysis:

```sh
dart analyze
```

Run formatting before committing Dart changes:

```sh
dart format lib test
```

## Architecture Notes

The planned learning model is a modular SDG system:

- 17 SDG learning modules.
- 1 interactive comic or scenario link per SDG.
- 3 micro-learning resources per SDG.
- 1 quiz or reflection per SDG.
- 1 practical action challenge per SDG.
- 1 SDG badge per SDG.
- 1 final EcoUnity completion badge.

The first complete prototype module should be SDG 12, Responsible Consumption and Production.

See the full plan in [docs/FLUTTER_ARCHITECTURE_AND_DEVELOPMENT_PLAN.md](docs/FLUTTER_ARCHITECTURE_AND_DEVELOPMENT_PLAN.md).

## Documentation

Relevant project documents:

- [Flutter Architecture and Development Plan](docs/FLUTTER_ARCHITECTURE_AND_DEVELOPMENT_PLAN.md)
- [WP5.A2 Output 1 - App architecture.pdf](docs/WP5.A2%20Output%201%20-%20App%20architecture.pdf)
- [WP5.2 App content architecture overview.pdf](docs/WP5.2%20App%20content%20architecture%20overview.pdf)

## License

Unless noted otherwise, this repository is released under the Creative Commons CC0 1.0 Universal public domain dedication. See [LICENSE](LICENSE).

Project names, partner names, trademarks, and third-party logos, including the Erasmus+ logo, may be subject to separate rights and are not waived by the repository license.
