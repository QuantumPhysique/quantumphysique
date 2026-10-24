Open a pull request from the current branch into `dev` (or the given target branch).

Usage: `/pr` or `/pr <target-branch>`. Target: `$ARGUMENTS` if given, else `dev`.

## Step 1: Check

1. `git fetch origin <target>`.
2. `git branch --show-current`: on `dev` or `main`, stop and propose a `feat/<topic>` or `fix/<topic>` branch first.
3. `git status --short`: stop on uncommitted changes to tracked files.
4. `gh pr view --json url`: if a PR already exists for this branch, `git push`, print its URL, done.
5. `git log origin/<target>..HEAD --oneline` and `git diff origin/<target>...HEAD --stat`: the scope. Every commit must be a conventional commit (`/commit`); reword before opening if one is not.
6. Title and body follow the CLAUDE.md Release notes section: a type that releases exactly when an app can notice the change, and a breaking change with `!` and its `BREAKING CHANGE:` footer.
7. Format, analyze and tests run once, here, on the finished branch: if they have not run on this exact tree, run `dart format --output=none --set-exit-if-changed .`, `flutter analyze` and `flutter test` and fix what they report before opening.

## Step 2: Open

Present target, title and body; after approval:

```bash
git push -u origin HEAD
gh pr create --base <target> --title "…" --body "…"
```

Print the URL.

## Format

**Title**: one conventional-commit line (`feat:`, `fix:`, …), at most 72 characters, linted by CI. It becomes the squash commit on `dev`: its type decides the version bump, and for `feat`, `fix` and `perf` it is the line in the release notes, so it says what an app sees. With a single commit it is that commit's subject.

**Body**: readable in a minute; it becomes the body of the squash commit.

```text
<why this change, 1 to 3 sentences>

**Changes**
- <one line per logical change, only when there is more than one>

Closes #<issue>

BREAKING CHANGE: <what an app has to change, only when the branch breaks the API>
```

Removing or reworking something that was never released (in no stable tag): one line in the body saying so, no migration, no compatibility note beyond that.

The footer goes last, one line, as the CLAUDE.md Release notes section shows; it is the release-notes line. No file lists, no test plan, no "this PR", no headers beyond Changes, nothing the diff already says.
