# quantumphysique

Shared Flutter library for the QuantumPhysique apps: `QPApp`, theme, notifier and preferences base classes, reminders, widget library, settings pages and the changelog generator. Apps depend on it through git tags (`tag_pattern: v{{version}}`), not pub.dev. All commands run from the repository root.

## Setup

```bash
flutter pub get --enforce-lockfile
```

## Tasks

| Task | Command |
|---|---|
| Format | `dart format .` |
| Analyze | `flutter analyze` |
| Tests | `flutter test` |
| One test file | `flutter test test/preferences/qp_preferences_test.dart` |

**Format, analyze and test once, on the finished change.** They are the gate before commit and PR, not a step after every edit. In between, run only what answers a concrete question, usually one test file.

CI (`check.yml`) runs `flutter pub get --enforce-lockfile`, `dart format --set-exit-if-changed`, `flutter analyze` and `flutter test` on every push to `main` and every PR, with the Flutter version from the lower bound in `pubspec.yaml`.

## Trying a change in an app

An app uses a local clone through an untracked `pubspec_overrides.yaml` next to its `pubspec.yaml`:

```yaml
dependency_overrides:
  quantumphysique:
    path: ../../quantumphysique
```

Run the apps that use qp against the change before opening the PR; they get it with their next upgrade. Never commit the override file.

## Branching and release

- `main` is the only long-lived branch; feature branches `feat/<topic>`, `fix/<topic>`, `ci/<topic>`, `chore/<topic>` off `main`, back by merge commit. Never commit to `main` directly.
- Every commit lands on `main` as it is (no squash), so every commit is a conventional commit, see `/commit`. The PR title uses the same format.
- Versions are prepared with `/release`: a `release/prepare_vX.Y.Z` branch with one `chore: prepare vX.Y.Z` commit that turns `[Unreleased]` in `CHANGELOG.md` into `[X.Y.Z] - <date>` and sets `version: X.Y.Z` in `pubspec.yaml`. Only after merge: a GitHub release tagged `vX.Y.Z` with the changelog section as body. Never create tags by hand, never move or delete one.
- pub reads each version from `pubspec.yaml` at the tagged commit and ignores a tag that disagrees with it, so tag and `version:` must match.
- Semver, in 0.x: a breaking change bumps the minor (0.1 → 0.2), everything else the patch.

## Changelog

`CHANGELOG.md` is read by the developers of the apps when they upgrade. Every change an app can notice adds to `[Unreleased]`, in the sections `Breaking`, `Added`, `Changed`, `Fixed`.

- One line per change, in terms of the public API: what an app sees, not how it is done
- Breaking is anything that makes an app fail to compile or behave differently without a change on its side: a removed or renamed export, a new required parameter or `QPStrings` field, a changed default or preference key
- Every `Breaking` line says what an app has to change
  - Bad: `Reworked the reminder strings`
  - Good: `` `QPStrings` takes a required `reminderTitle`; apps add a `qp_reminderTitle` key ``
- Changes an app cannot see (refactoring, tests, CI, tooling) get no line

## Unreleased changes

Released means tagged. Everything else (`[Unreleased]` on `main`, any branch, your own earlier commits in a PR) has reached no app. Changing or removing it needs no deprecation path and no compatibility shim: delete the old code together with its tests, and say so in one line of the PR body.

Released state is different: the apps ship the preference keys and stored values that `QPPreferences` writes. Never rename or reuse a key; a changed key or value format needs an explicit migration, not a silent fallback.

## Project structure

- `lib/quantumphysique.dart`: the one public library; everything it exports from `lib/src/` is API
- `lib/src/app/`: `QPApp`, notifications and reminders
- `lib/src/notifier/`, `lib/src/preferences/`: `QPNotifier` and `QPPreferences`, with `part` files per concern (theme, UI, display, reminders)
- `lib/src/theme/`: `QPTheme`, palettes and system colours
- `lib/src/widgets/`, `lib/src/pages/`: widget library and ready-made pages
- `lib/src/types/`: strings, languages, fonts, icons, the logger and other small types
- `lib/src/changelog/`, `bin/generate_changelog.dart`: the changelog model and the generator the apps run
- `fonts/`: RobotoFlex and RobotoMono with their OFL licences
- `test/`: mirrors `lib/src/`

## Code

- Types everywhere; `const` where possible; single quotes; 80 columns. There is no `analysis_options.yaml` yet, so the analyzer runs with its defaults and this style is kept by hand
- Nothing app-specific: no app names, no weight or workout wording. What one app needs goes here only in a form every app can use; suggest that instead of adding it for one app
- No text users can see as a literal: it comes in through `QPStrings` and `QPAboutStrings`, which the apps fill from their `qp_*` translation keys. The apps copy those keys verbatim, so a field must never name an app or what it tracks
- Theme values only through `QPTheme.of(context)` and `Theme.of(context).colorScheme`; no literal colours, sizes or radii outside `lib/src/theme/`
- Everything exported is a promise to the apps, and renaming or removing it is breaking: export only what an app needs
- Enums carry behaviour in extensions (see `QPCustomThemeExtension`)
- No fallback logic unless explicitly asked; a silent default hides the bug

### Comments

Default is none: names and doc comments say what the code does. Public members get a doc comment: one line, what it is, not how it works. Any other comment exists only for a **why** the reader cannot see in the code (a platform quirk, a workaround, the trigger of a non-obvious branch) and is one or two lines. Never restate the code, narrate steps, or mark the obvious.

```dart
// Bad
counter += 1; // increment counter

// Good
counter += 1; // retries drive the backoff below
```

### Tests

The suite must stay small enough to maintain by hand. A test is the exception, not part of every change.

- Write one only for logic that is easy to break silently and tedious to check by hand: reminder scheduling and time zones, loading and migrating preferences, colour calculations, language and date parsing
- Bug fix: at most one regression test, and only when the bug was in such logic. UI, layout, wiring and platform fixes get none
- New feature: test its core calculation, not every branch, edge case or widget state. Extend an existing test file before creating a new one
- Never: getters and setters, theme or layout, enum tables, plain widget rendering
- When unsure whether a test earns its place, leave it out
- Through the public API, readable on its own; preferences through `SharedPreferences.setMockInitialValues` and a `forTesting` constructor
- On failure, assume the implementation is wrong before the test

## Working with the user

- Concise and direct: lead with the answer or action, no preamble or restatement. One sentence if possible.
- Investigate before concluding: read the source, trace the call path. No "the issue is…" before evidence.
- Non-trivial tasks (several files, an interface change, more than one reasonable design): state the approach in a few lines and get approval first.
- Commit and PR text is short: a conventional subject and at most 2 to 3 lines of why. `/commit`, `/pr` and `/review` carry the details.
