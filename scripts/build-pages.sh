#!/usr/bin/env bash
# Build the live demo into pages/, which is committed: the Pages
# workflow publishes that folder as it is (nothing is built on GitHub).
# The site (site/, a Yew app) embeds every library at build time, so
# rebuild after any change to libs/ (the gate checks pages/ is current).
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
echo "pages/ built; commit it (git add pages/) and push to publish."
