#!/usr/bin/env bash
# Build the live demo into pages/ (not tracked; the gate builds it
# too). just publish makes it the gh-pages branch, which GitHub Pages
# serves. The site (site/, a Yew app) embeds every library at build
# time; pages/INPUTS records what it was built from, so a stale build
# is not published.
#   scripts/build-pages.sh
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
base="/X_eTaL-libraries/"
dist="$root/target/pages-dist"
"$root/scripts/libs.py" check
(cd "$root/site" && trunk build --release --public-url "$base" --dist "$dist")
mkdir -p "$root/pages"
rsync -a --delete --exclude .nojekyll --exclude INPUTS "$dist/" "$root/pages/"
touch "$root/pages/.nojekyll"
"$root/scripts/pages-inputs.sh" > "$root/pages/INPUTS"
echo "pages/ built; just publish to publish it."
