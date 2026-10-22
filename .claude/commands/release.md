Prepare a release: version bump, changelog, PR, and after the merge the tag.

Usage: `/release` or `/release <X.Y.Z>`. Version: `$ARGUMENTS` if given, else proposed in step 2.

## Step 1: Check

1. `git fetch origin main`, `git switch main`, `git pull --ff-only`: stop on uncommitted changes to tracked files.
2. `[Unreleased]` in `CHANGELOG.md` is not empty, otherwise there is nothing to release; stop.
3. Read `version:` in `pubspec.yaml` and the latest `## [X.Y.Z]` heading in `CHANGELOG.md`; they must match.

## Step 2: Version

Propose the next version from `[Unreleased]` ([SemVer](https://semver.org)):

| `[Unreleased]` holds | Before 1.0 | From 1.0 |
|---|---|---|
| `Breaking` | minor | major |
| `Added` | patch | minor |
| Only `Changed` or `Fixed` | patch | patch |

Show the proposal with the line that decided it and ask: this version, or a different one?

## Step 3: Prepare

Only after the version is confirmed. On a branch `release/prepare_vX.Y.Z`:

1. `pubspec.yaml`: `version: X.Y.Z`.
2. `CHANGELOG.md`:
   - Bring every `[Unreleased]` line in line with the CLAUDE.md Changelog section: one line each, every `Breaking` line saying what the apps have to change.
   - Insert `## [X.Y.Z] - <today, YYYY-MM-DD>` directly below `## [Unreleased]`, so `[Unreleased]` stays as an empty heading on top.
   - Footer: `[Unreleased]` compares `vX.Y.Z...main`; add `[X.Y.Z]: …/compare/v<previous>...vX.Y.Z` below it.
3. Show the new changelog section; after approval commit both files as `chore: prepare vX.Y.Z` (via `/commit`) and open the PR (via `/pr`).

## Step 4: After merge

Only once the PR is merged, and after asking:

1. `git fetch origin main`: `version:` in `pubspec.yaml` on `origin/main` must be `X.Y.Z`, since pub ignores a tag that disagrees with it.
2. Create the GitHub release, which tags `vX.Y.Z`:

```bash
gh release create vX.Y.Z --target main --title "vX.Y.Z" --notes "<the X.Y.Z changelog section, without its heading>"
```

Never create, push, move or delete a tag any other way.

The apps then move to the release with `flutter pub upgrade quantumphysique`, or `flutter pub upgrade --major-versions quantumphysique` across a breaking one.
