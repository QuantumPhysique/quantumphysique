#!/usr/bin/env bash
# Versions and release notes from the conventional commits, for the tag and
# release PR workflows:
#
#   release.sh version dev|main  the version HEAD releases as on that branch;
#                                nothing when no commit calls for a release
#   release.sh notes             the release notes for HEAD, in Markdown
#   release.sh tag <version>     cut the release commit and push its tag
#
# pub reads the version from pubspec.yaml at the tagged commit and ignores a
# tag that disagrees with it, while the branches carry a placeholder. Each tag
# therefore sits on a release commit that no branch contains: a child of the
# merged commit that only sets `version:`. So the last release is the highest
# stable tag, not the nearest reachable one; `<tag>..HEAD` stays exact, since
# a release commit's only parent is the commit it was cut from.
set -euo pipefail

breaking_re='^[a-z]+(\([^)]*\))?!:'
feat_re='^feat(\([^)]*\))?:'
fix_re='^(fix|perf)(\([^)]*\))?:'

usage() {
  echo "usage: release.sh version dev|main | notes | tag <version>" >&2
  exit 2
}

# The highest vX.Y.Z tag; nothing before the first release
last_release() {
  git tag --list 'v*' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V |
    tail -n 1 || true
}

# The non-merge commits after tag $1 (all of them for none), oldest first
commits_since() {
  git log --no-merges --reverse --format=%H "${1:+$1..}HEAD"
}

# breaking, feat, fix or nothing for commit $1
kind() {
  local subject body
  subject="$(git log -1 --format=%s "$1")"
  body="$(git log -1 --format=%b "$1")"
  if [[ $subject =~ $breaking_re ]] ||
    grep -qE '^BREAKING[ -]CHANGE:' <<<"$body"; then
    echo breaking
  elif [[ $subject =~ $feat_re ]]; then
    echo feat
  elif [[ $subject =~ $fix_re ]]; then
    echo fix
  fi
}

# The strongest kind among the commits after tag $1
bump_since() {
  local commit best=''
  for commit in $(commits_since "$1"); do
    case "$(kind "$commit")" in
      breaking)
        echo breaking
        return
        ;;
      feat) best=feat ;;
      fix) if [ -z "$best" ]; then best=fix; fi ;;
    esac
  done
  echo "$best"
}

next_version() {
  local last bump major minor patch next n
  last="$(last_release)"
  bump="$(bump_since "$last")"
  if [ -z "$bump" ]; then return; fi

  IFS=. read -r major minor patch <<<"${last#v}"
  major="${major:-0}" minor="${minor:-0}" patch="${patch:-0}"
  # Before 1.0 a breaking change bumps the minor, like a feature
  case "$major:$bump" in
    0:breaking) next="0.$((minor + 1)).0" ;;
    *:breaking) next="$((major + 1)).0.0" ;;
    *:feat) next="${major}.$((minor + 1)).0" ;;
    *) next="${major}.${minor}.$((patch + 1))" ;;
  esac

  if [ "$1" = dev ]; then
    n="$(git tag --list "v${next}-dev.*" | sed -E 's/^.*-dev\.//' | sort -n |
      tail -n 1)"
    # Only a fix or feature since the last dev tag mints the next one
    if [ -n "$n" ] && [ -z "$(bump_since "v${next}-dev.${n}")" ]; then
      return
    fi
    next="${next}-dev.$((${n:-0} + 1))"
  fi
  echo "$next"
}

section() {
  if [ -n "$2" ]; then printf '## %s\n\n%s\n' "$1" "$2"; fi
}

notes() {
  local commit subject footer breaking='' added='' fixed=''
  for commit in $(commits_since "$(last_release)"); do
    subject="$(git log -1 --format=%s "$commit" |
      sed -E 's/^[a-z]+(\([^)]*\))?!?: //')"
    case "$(kind "$commit")" in
      breaking)
        # The footer says what an app has to change, so it replaces the subject
        footer="$(git log -1 --format=%b "$commit" |
          sed -n -E '/^BREAKING[ -]CHANGE: /{s///p;q;}')"
        breaking+="- ${footer:-$subject}"$'\n'
        ;;
      feat) added+="- ${subject}"$'\n' ;;
      fix) fixed+="- ${subject}"$'\n' ;;
    esac
  done
  section Breaking "$breaking"
  section Added "$added"
  section Fixed "$fixed"
}

tag() {
  local version="$1" tag="v$1"
  git switch --quiet --detach
  sed -i.orig -E "s/^version: .*/version: ${version}/" pubspec.yaml
  rm pubspec.yaml.orig
  if ! grep -qx "version: ${version}" pubspec.yaml; then
    echo "pubspec.yaml has no version line to set" >&2
    exit 1
  fi
  git commit --quiet --message "chore: release ${tag}" pubspec.yaml
  git tag --annotate --message "${tag}" "${tag}"
  git push --quiet origin "refs/tags/${tag}"
  echo "${tag} at $(git rev-parse --short HEAD)"
}

case "${1:-}" in
  version)
    case "${2:-}" in dev | main) next_version "$2" ;; *) usage ;; esac
    ;;
  notes) notes ;;
  tag) if [ -n "${2:-}" ]; then tag "$2"; else usage; fi ;;
  *) usage ;;
esac
