Open or refresh the release PR from `dev` onto `main`.

Usage: `/release`. The version and the release notes come from the squash commits on `dev`, see the CLAUDE.md Branching and release section; nothing here edits a file.

## Step 1: Run

1. `gh workflow run release-pr.yml`, then wait for the run it started: `gh run list --workflow release-pr.yml --limit 1 --json databaseId --jq '.[0].databaseId'` and `gh run watch <id> --exit-status`.
2. On failure, print the error from `gh run view <id> --log-failed`: "Nothing to release" means `dev` holds no fix or feature since the last release; stop.

## Step 2: Report

1. `gh pr list --base main --head dev --json number,title,url,body`: print the title (the version the merge mints), the URL and the release notes from the body.
2. Check each line against the CLAUDE.md Release notes section. A wrong line comes from a squash commit already on `dev`, so it can only be corrected on the GitHub release after the merge, with `gh release edit`; say which.

## After the merge

Merging the release PR, with a merge commit, is the maintainer's call: never merge it. `tag.yml` then tags `vX.Y.Z` and publishes the GitHub release. Never create, push, move or delete a tag yourself.

The apps then move to the release with `flutter pub upgrade quantumphysique`, or `flutter pub upgrade --major-versions quantumphysique` across a new minor (before 1.0) or major version.
