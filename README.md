# quantumphysique

Shared Flutter library for the QuantumPhysique apps, such as
[trale](https://github.com/QuantumPhysique/trale): theme, preferences,
notifier, widgets, settings pages and changelog generator.

It is built for these apps, not as a general-purpose package. It is not on
pub.dev, and before 1.0 every minor release may break the API; the
[release notes](https://github.com/QuantumPhysique/quantumphysique/releases)
say what an app has to change. The library is
licensed under the AGPLv3+, so an app that includes it falls under the AGPLv3
as well.

## What it provides

- **App shell**: `QPApp` shows the app once preferences, notifications and the
  app's own setup are ready, opens the app's onboarding screen, if it has one,
  until the app marks it as seen, and flags the changelog on the first start
  after an update.
- **State**: `QPPreferences` and `QPNotifier`, the base classes for the app's
  settings and state, with theme, language, onboarding, date format, first day
  of the week and reminder settings built in.
- **Theme**: `QPTheme`, a Material 3 theme with built-in palettes, the system
  colours where the platform reports them, contrast levels and scheme
  variants, plus the shared paddings, radii and shapes.
- **Reminders**: `QPNotificationService` schedules notifications;
  `QPReminderRegistry` keeps track of the armed ones across restarts.
- **Pages**: `QPSettingsOverviewPage`, `QPThemeSettingsPage`,
  `QPLanguageSettingsPage`, `QPNotificationsSettingsPage`, `QPAboutPage`,
  `QPFAQPage`, `QPSplash`, and `QPHomePage` with its bottom navigation.
- **Widgets**: `QPWidgetGroup` with the `QPGrouped*` tiles, `QPBentoCard` and
  `QPBentoGrid`, `QPDialog`, `QPButtonGroup`, `QPFilterChip`,
  `QPSelectionCarousel`, `M3EFloatingActionButton`, and the entrance
  animations `QPFadeInEffect` and `QPAnimateInEffect`.
- **Changelog**: a generator that turns the app's `CHANGELOG.md` into Dart,
  and `QPChangelogContent` to show it.
- **Fonts**: RobotoFlex and RobotoMono.

## Install

The package needs Flutter 3.47.1 or newer. Every release is a git tag
`vX.Y.Z`, and every fix or feature merged in between a preview tag
`vX.Y.Z-dev.N`. pub finds both through `tag_pattern`, and reads that key only
when the lower bound of the app's `environment: sdk:` is 3.9 or higher.

```yaml
dependencies:
  material_ui: ^1.8.0
  quantumphysique:
    git:
      url: https://github.com/QuantumPhysique/quantumphysique.git
      tag_pattern: v{{version}}
    version: ^0.1.0

dependency_overrides:
  phosphor_flutter:
    git:
      url: https://github.com/subarnaPdl/phosphor_icons.git
      ref: 514f0a883571c4453dbd6ee3041d1dcba4fb8fc7
```

`material_ui` is Flutter's Material library, published as its own package.
The app imports it directly, since the package does not re-export it.

The override is needed because `phosphor_flutter` 2.1.0 does not compile
against Flutter 3.47, and pub ignores the overrides of a dependency. Drop it
once upstream releases a version that compiles.

### Versions

| `version:` | Takes |
|---|---|
| `^0.2.0` | the newest release from 0.2.0 up to the next breaking one |
| `0.2.1` | exactly 0.2.1 |
| `^0.3.0-dev.1` | the newest preview of 0.3.0, and 0.3.x releases once they exist |

pub prefers a release over a preview whenever both match, so to keep following
previews after a release, raise the lower bound to the next preview. Ship
only releases: previews carry no compatibility promise.

### Upgrading

`pubspec.lock` pins the resolved commit, so `flutter pub get` keeps it.
`flutter pub upgrade quantumphysique` moves to the newest version within the
constraint; `flutter pub upgrade --major-versions quantumphysique` also takes
a breaking one. The release notes list what to change for it.

## Usage

Everything is exported from `package:quantumphysique/quantumphysique.dart`.
An app subclasses `QPPreferences` and `QPNotifier` and starts through `QPApp`:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:quantumphysique/quantumphysique.dart';

class MyPreferences extends QPPreferences {
  MyPreferences() : super.base();
}

class MyNotifier extends QPNotifier {
  MyNotifier() : super(MyPreferences());
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    QPApp<MyNotifier>(
      notifier: MyNotifier(),
      buildRoutes: () => <String, WidgetBuilder>{'/': (_) => const Home()},
      buildStrings: (BuildContext context) =>
          qpStringsFromL10n(AppLocalizations.of(context)!),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}
```

`AppLocalizations` is the app's generated localisation class and `Home` its
first page. `GlobalMaterialLocalizations` comes from `material_ui`; the list
that `gen-l10n` generates in `AppLocalizations.localizationsDelegates` carries
the ones from `flutter_localizations` instead, which `material_ui` does not
use. `onExtraInit` runs the app's own async setup, such as opening a database,
before the first frame.

### Strings

The package has no translations of its own. Every string comes in through
`QPStrings`, which `buildStrings` returns for the current locale, and
`QPAboutStrings`, which `QPAboutPage` takes.

trale has both in every language: copy the `qp_*` keys from its
[ARB files](https://github.com/QuantumPhysique/trale/tree/main/app/lib/l10n)
verbatim, and `qpStringsFromL10n` and `qpAboutStringsFromL10n` from its
[l10n_extension.dart](https://github.com/QuantumPhysique/trale/blob/main/app/lib/core/l10n_extension.dart).
The fields that describe the app itself, such as `translateSubtitle` and
`reminderSubtitle`, and all of `QPAboutStrings` come from keys of the app's
own.

### Reminders on Android

Notifications stay off unless `QPApp` gets a `notificationIcon`, the name of
an Android drawable such as `'@drawable/ic_notification'`. The app's
`AndroidManifest.xml` then needs these entries, which
`flutter_local_notifications` does not merge on its own. Without the
receivers, every scheduled reminder is silently dropped:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />

<!-- inside <application> -->
<receiver
    android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver
    android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON" />
    </intent-filter>
</receiver>
```

Without `SCHEDULE_EXACT_ALARM`, reminders still fire, but Android may delay
them. The plugin also needs core library desugaring, see the Gradle setup in
the [flutter_local_notifications README](https://pub.dev/packages/flutter_local_notifications).

### Changelog

The generator turns the app's `CHANGELOG.md` into a `const Changelog`. From
the app's package root:

```bash
dart run quantumphysique:generate_changelog          # ../CHANGELOG.md to lib/core/changelog.g.dart
dart run quantumphysique:generate_changelog --check  # exits 1 if that file is stale, for CI
```

`--changelog`, `--output` and `--part-of` change the defaults. The output is a
`part` file, so the app needs the library it belongs to, by default
`lib/core/changelog.dart`:

```dart
import 'package:quantumphysique/quantumphysique.dart';

part 'changelog.g.dart';
```

The generator reads `## [Unreleased]` and `## [X.Y.Z] - YYYY-MM-DD` headings
with the sections `Added Features and Improvements`, `Bugfix`,
`Other Changes` and `API Changes Warning`; anything else in a section heading,
such as an emoji, is ignored.

On the first start after an update, `QPApp` sets `showChangelog` on the
notifier. The app shows `QPChangelogContent` then and resets the flag.
`QPAboutPage` lists the whole changelog when it gets `changelog`.

## Development

```bash
flutter pub get --enforce-lockfile
dart format .
flutter analyze
flutter test
```

CI runs the same checks on every pull request, with the lowest Flutter
version that `pubspec.yaml` allows. Pull requests go into `dev` and are
squash-merged, so the title is a conventional commit: it decides the next
version and becomes the line in the release notes. CI tags every merge that
releases; [CLAUDE.md](CLAUDE.md) has the details.

### Trying a change in an app

To run an app against a local clone, put a `pubspec_overrides.yaml` next to
the app's `pubspec.yaml`:

```yaml
dependency_overrides:
  quantumphysique:
    path: ../../quantumphysique
```

The path is relative to the app's `pubspec.yaml`. List the file in the app's
`.gitignore` and never commit it: no other checkout has that path, so CI and
every other build would fail.

## Licence

[GNU AGPLv3+](LICENSE). The fonts in `fonts/` are under the SIL Open Font
License, in the `-OFL.txt` file next to each.
