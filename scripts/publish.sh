#!/usr/bin/env bash
#
# Render the book, check the result is sane, and only then let it be committed.
#
#   ./scripts/publish.sh
#
# This exists because of a real failure. Quarto renders each chapter to the
# project root and moves the files into docs/ at the end. If that move is
# interrupted — most easily by a `quarto preview` still watching the files in
# another terminal — the render exits non-zero having left most of the site at
# the top level and docs/ half-written. `git add -A` then commits the wreckage,
# and because the pages that did land look fine locally, nothing announces the
# problem until the published site is missing two thirds of its chapters.

set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$PWD"
EXPECTED_PAGES=19

fail() { printf '\n  FAILED: %s\n\n' "$1" >&2; exit 1; }

# A preview process racing the render is the known cause. Say so rather than
# letting it corrupt the output.
if pgrep -f "quarto preview" > /dev/null 2>&1; then
  fail "a 'quarto preview' is running. Stop it first — it will race this render."
fi

echo "==> rendering"
quarto render || fail "quarto render exited non-zero. Read the output above; do not commit."

echo "==> checking the render landed where it should"

stray=$(find "$ROOT" -maxdepth 1 -name '*.html' | wc -l | tr -d ' ')
[ "$stray" = "0" ] || fail "$stray rendered page(s) stranded at the project root. The move into docs/ did not finish."

pages=$(find "$ROOT/docs" -maxdepth 1 -name '*.html' | wc -l | tr -d ' ')
[ "$pages" = "$EXPECTED_PAGES" ] || fail "docs/ has $pages pages, expected $EXPECTED_PAGES. Update EXPECTED_PAGES if you added a chapter."

[ -f "$ROOT/docs/.nojekyll" ] || fail "docs/.nojekyll is missing. GitHub Pages will hand the site to Jekyll."
[ -f "$ROOT/docs/search.json" ] || fail "docs/search.json is missing. Search will silently return nothing."

echo "==> checking nothing needed is being ignored by git"

# The one that bites: an unanchored *_files/ pattern in .gitignore also matches
# docs/<chapter>_files/, so the site publishes with every figure broken while
# looking perfect locally.
#
# --no-index is what makes this check work at all. Without it git reports
# already-tracked files as "not ignored", because ignore rules do not apply to
# anything in the index — so once docs/ has been committed once, the check
# silently passes forever and only a brand new chapter would ever trip it.
while IFS= read -r d; do
  git check-ignore -q --no-index "$d" && fail "$d is gitignored — the published site would lose its figures."
done < <(find "$ROOT/docs" -type d -name '*_files')

git check-ignore -q --no-index docs/.nojekyll && fail "docs/.nojekyll is gitignored."

echo "==> checking every solution link resolves"

grep -ho 'solutions\.html#sec-sol-[a-z0-9-]*' "$ROOT"/docs/*.html | sed 's/.*#//' | sort -u > /tmp/rintro-links.$$
while IFS= read -r slug; do
  grep -q "id=\"$slug\"" "$ROOT/docs/solutions.html" || fail "dead solution link: $slug has no anchor in solutions.html"
done < /tmp/rintro-links.$$
links=$(wc -l < /tmp/rintro-links.$$ | tr -d ' ')
rm -f /tmp/rintro-links.$$

cat <<SUMMARY

  OK. $pages pages, $(find "$ROOT/docs" -name '*.svg' | wc -l | tr -d ' ') figures, $links solution links all resolving.

  Next:
    git add -A && git commit -m "..." && git push

SUMMARY
