#!/usr/bin/env bash
#
# Render the book and publish it to the gh-pages branch.
#
#   ./scripts/publish.sh
#
# main holds the source. gh-pages holds the rendered site and nothing else.
# GitHub serves gh-pages. Nothing rendered is committed to main, so a chapter
# edit is a one-file diff rather than a one-file diff buried in ninety
# regenerated HTML pages.
#
# The cost of that split is that main can look perfectly up to date while the
# live site is stale, because publishing is a separate act from pushing. That
# is what build-info.json and scripts/check-pages-sync.sh exist to catch.

set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$PWD"
EXPECTED_PAGES=19
OUT="_book"

fail() { printf '\n  FAILED: %s\n\n' "$1" >&2; exit 1; }

# A preview watching the files will race the render and can leave the output
# half-moved. This has actually happened.
if pgrep -f "quarto preview" > /dev/null 2>&1; then
  fail "a 'quarto preview' is running. Stop it first — it will race this render."
fi

# The published site records the commit it came from. If the tree is dirty that
# record is a lie, and the sync check downstream becomes worthless.
if ! git diff --quiet HEAD 2>/dev/null; then
  git status --short >&2
  fail "uncommitted changes. Commit them first so the published site records a real commit."
fi

branch=$(git rev-parse --abbrev-ref HEAD)
[ "$branch" = "main" ] || fail "on branch '$branch'. Publish from main."

echo "==> rendering and publishing to gh-pages"
quarto publish gh-pages --no-prompt --no-browser || fail "quarto publish exited non-zero. Read the output above."

echo "==> checking what was published"

pages=$(find "$ROOT/$OUT" -maxdepth 1 -name '*.html' | wc -l | tr -d ' ')
[ "$pages" = "$EXPECTED_PAGES" ] || fail "$OUT/ has $pages pages, expected $EXPECTED_PAGES. Update EXPECTED_PAGES if you added a chapter."

stray=$(find "$ROOT" -maxdepth 1 -name '*.html' | wc -l | tr -d ' ')
[ "$stray" = "0" ] || fail "$stray rendered page(s) stranded at the project root."

[ -f "$ROOT/$OUT/search.json" ] || fail "$OUT/search.json is missing. Search will silently return nothing."
[ -f "$ROOT/$OUT/build-info.json" ] || fail "$OUT/build-info.json is missing. The post-render stamp did not run."

echo "==> checking every solution link resolves"
grep -ho 'solutions\.html#sec-sol-[a-z0-9-]*' "$ROOT/$OUT"/*.html | sed 's/.*#//' | sort -u > /tmp/rintro-links.$$
while IFS= read -r slug; do
  grep -q "id=\"$slug\"" "$ROOT/$OUT/solutions.html" || fail "dead solution link: $slug has no anchor in solutions.html"
done < /tmp/rintro-links.$$
links=$(wc -l < /tmp/rintro-links.$$ | tr -d ' '); rm -f /tmp/rintro-links.$$

echo "==> confirming gh-pages now matches main"
"$ROOT/scripts/check-pages-sync.sh" --local || fail "published site does not match main. See above."

cat <<SUMMARY

  Published. $pages pages, $(find "$ROOT/$OUT" -name '*.svg' | wc -l | tr -d ' ') figures, $links solution links resolving.

  https://cerm-nus.github.io/r-intro/

SUMMARY
