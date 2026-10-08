#!/usr/bin/env bash
# Build the cross-reference site (xetal doc --out) into pages/doc: every
# library and macro library in libs/, and every demo, so each name shows
# whose it is (l: a library's export, h: a helper, u: a demo's own) and
# every call links to its definition, across files. Indexed and
# searchable by name or type, grouped by directory in the side bar
# (X_eTaL's own doc site, ask G18). The side bar's order is each
# directory's first mention, not sorted (X_eTaL has no sort for it): a
# library several others import (Strings, Lists, Format) would get
# pulled to wherever its first importer falls, so those go first here,
# ahead of the otherwise alphabetical sweep, to keep the list closer to
# the libraries' own order. Run by scripts/build-pages.sh (just pages)
# and by `just doc`.
#   scripts/doc-site.sh             # into pages/doc
#   XETAL_DOC_OUT=DIR scripts/doc-site.sh
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
out="${XETAL_DOC_OUT:-pages/doc}"
rm -rf "$out"
shared=(libs/Strings/src/Strings.xtl libs/Lists/src/Lists.xtl libs/Format/src/Format.xtl)
scripts/xt doc --out "$out" "${shared[@]}" libs/*/src/*.xtl libs/*/src/*.xtlm libs/*/demos/*.xtl > /dev/null
echo "doc: $(find "$out" -name '*.html' | wc -l | tr -d ' ') pages in $out"
