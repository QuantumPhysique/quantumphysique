# quantumphysique

Shared Flutter library for the QuantumPhysique apps, such as
[trale](https://github.com/QuantumPhysique/trale). It provides:

- `QPApp`, which wraps `MaterialApp` and sets up preferences, theme, locale
  and notifications before the app is shown
- `QPNotifier` and `QPPreferences`, the base classes for app state and
  settings, with theme, language, display and reminder settings built in
- `QPTheme`, a Material 3 theme with built-in palettes, system colours and
  shared paddings, radii and shapes
- reminders through `QPNotificationService` and `QPReminderRegistry`
- widgets such as `QPWidgetGroup` with the `QPGrouped*` tiles, `QPBentoCard`,
  `QPDialog` and `QPFadeInEffect`
- ready-made pages for the settings overview, theme, language,
  notifications, about, FAQ and the splash screen
- a generator that turns the app's `CHANGELOG.md` into Dart, and
  `QPChangelogContent` to show it
- the RobotoFlex and RobotoMono fonts

The package has no translations of its own. The app passes every string in
through `QPStrings` and `QPAboutStrings`, built from its own localisations.

## Adding it to an app

quantumphysique is not on pub.dev. Every release is a git tag `vX.Y.Z`, which
pub finds through `tag_pattern`. This needs Dart 3.9 or newer in the app's
`environment: sdk:` constraint.

```yaml
dependencies:
  quantumphysique:
    git:
      url: https://github.com/QuantumPhysique/quantumphysique.git
      tag_pattern: v{{version}}
    version: ^0.1.0
```

`pubspec.lock` pins the resolved commit. `flutter pub upgrade quantumphysique`
moves to the newest release within the constraint, and
`flutter pub upgrade --major-versions quantumphysique` also crosses a breaking
one. [CHANGELOG.md](CHANGELOG.md) says what an app has to change for each
breaking release.

Everything is exported from one library. An app subclasses `QPPreferences` and
`QPNotifier` and starts through `QPApp`, which builds on `material_ui`:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:quantumphysique/quantumphysique.dart';

void main() {
  runApp(
    QPApp<MyNotifier>(
      notifier: MyNotifier(),
      buildRoutes: () => <String, WidgetBuilder>{'/': (_) => const Home()},
      buildStrings: (BuildContext context) => myQPStrings(context),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}
```

## Changelog generator

From the app's package root:

```bash
dart run quantumphysique:generate_changelog          # ../CHANGELOG.md to lib/core/changelog.g.dart
dart run quantumphysique:generate_changelog --check  # exits 1 if that file is stale, for CI
```

`--changelog`, `--output` and `--part-of` change the defaults. The generator
reads `## [X.Y.Z] - YYYY-MM-DD` headings with the sections
`Added Features and Improvements`, `Bugfix`, `Other Changes` and
`API Changes Warning`.

## Trying a change in an app

To run an app against a local clone before a release, put a
`pubspec_overrides.yaml` next to the app's `pubspec.yaml`:

```yaml
dependency_overrides:
  quantumphysique:
    path: ../../quantumphysique
```

The path is relative to the app's `pubspec.yaml`. List the file in the app's
`.gitignore` and never commit it: no other checkout has that path, so CI and
every other build would fail.

## Development

```bash
flutter pub get --enforce-lockfile
dart format .
flutter analyze
flutter test
```

CI runs the same checks on every pull request, with the lowest Flutter
version that `pubspec.yaml` allows.

## License

The project is licensed [GNU AGPLv3+](LICENSE). The fonts in `fonts/` are
licensed under the SIL Open Font License, see the `-OFL.txt` files next to
them.
