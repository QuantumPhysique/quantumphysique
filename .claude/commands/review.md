Review the current branch against `main` (or the given target branch) and report. Read-only: do not edit files.

Usage: `/review` or `/review <target-branch>`. Target: `$ARGUMENTS` if given, else `main`.

1. `git fetch origin <target>`, then `git diff origin/<target>...HEAD --stat` and the full diff.
2. Read every changed source file in full; the hunks alone hide context.

## Check

- **Correctness**: does the change do what the commits claim; edge cases; no silent fallbacks or defaults that hide a bug.
- **API**: a change to what `lib/quantumphysique.dart` exports (a removed or renamed member, a new required parameter, a new `QPStrings` or `QPAboutStrings` field, a changed default or preference key) is breaking and needs a `Breaking` line saying what the apps have to change. New exports that no app needs, or that expose internals.
- **App-agnostic**: app names, weight or workout wording, behaviour that only makes sense in one app.
- **Conventions**: CLAUDE.md: explicit types, theme values through `QPTheme.of` and `Theme.of` only, no literal text users can see.
- **Released state**: a renamed, reused or reinterpreted preference key without an explicit migration.
- **Comments**: any that restate the code, narrate steps, or explain how instead of why; the fix is deletion. Doc comments longer than what the member is. Public members without one.
- **Tests**: behaviour through the public API, readable on their own. Flag tests of getters, layout, enum tables or plain widget rendering, tests that assert a removed feature is absent, and any test beyond what the CLAUDE.md Tests section asks for (e.g. more than one regression test for a bug fix, edge-case sweeps).
- **Unreleased**: shims, deprecations, migrations or compatibility code for anything that was never released (only under `[Unreleased]` or on this branch).
- **Changelog**: per the CLAUDE.md Changelog section: a change an app can notice without a line under `[Unreleased]`, a breaking change outside `Breaking` or without what to change, a line for an internal change.
- **Commits**: non-conventional subjects, bodies that narrate the diff, issue numbers in subjects.
- **Scope**: dead code, leftover debug output, unrelated drive-by edits.

## Output

Per file, one line per finding with `path:line`: **Issues** (block merge) first, then **Suggestions**. Skip what has nothing to say. Close with one line: merge, or what must change first.
