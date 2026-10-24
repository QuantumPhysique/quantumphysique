#!/usr/bin/env bash
# Applies the repository settings the release flow depends on. Re-runs
# converge; needs admin rights and an existing dev branch.
#
#   merge settings  squash and merge commits on, rebase off (rulesets
#                   restrict, they don't enable); the squash commit is the PR
#                   title and body, so a BREAKING CHANGE footer reaches git;
#                   merged branches auto-deleted, dev and main survive through
#                   their rulesets
#   default branch  dev
#   rulesets        .github/rulesets/: dev takes squash merges with a linted
#                   title, main merge commits; v* tags are immutable, since a
#                   release commit is reachable only through its tag. main
#                   does not require PRs to be up to date: nothing merges main
#                   back into dev, so dev always lags by the merge commits.
#
# Run from anywhere inside the clone: .github/scripts/setup-repo.sh
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

REPO="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
echo "Configuring ${REPO}"

gh api -X PATCH "repos/${REPO}" \
  -f default_branch=dev \
  -F allow_squash_merge=true \
  -F allow_merge_commit=true \
  -F allow_rebase_merge=false \
  -F allow_update_branch=true \
  -F allow_auto_merge=true \
  -F delete_branch_on_merge=true \
  -f squash_merge_commit_title=PR_TITLE \
  -f squash_merge_commit_message=PR_BODY >/dev/null
echo "default branch dev, merge settings applied"

for file in .github/rulesets/*.json; do
  name="$(jq -r .name "$file")"
  id="$(gh api "repos/${REPO}/rulesets?includes_parents=false" \
    --jq ".[] | select(.name == \"${name}\") | .id")"
  if [ -n "$id" ]; then
    gh api -X PUT "repos/${REPO}/rulesets/${id}" --input "$file" >/dev/null
  else
    gh api -X POST "repos/${REPO}/rulesets" --input "$file" >/dev/null
  fi
  echo "ruleset ${name}: applied"
done
