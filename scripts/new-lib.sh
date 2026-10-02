#!/usr/bin/env bash
# Start a library from templates/: lib/Name.xtl, tests/Name/ (a test
# program and its expected output, and the pinned types) and
# docs/libs/Name.md.
#   scripts/new-lib.sh Name alias: "what it is"
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
base="${XETAL_LIBS_ROOT:-$root}"
usage='usage: new-lib.sh Name alias: "what it is"'
name="${1:?$usage}"; alias="${2:?$usage}"; summary="${3:?$usage}"
[[ "$name" =~ ^[A-Z][A-Za-z0-9]*$ ]] || { echo "new-lib: a library name is UpperCamel" >&2; exit 1; }
[[ "$alias" =~ ^[a-z]+:$ ]] || { echo "new-lib: an alias is lowercase letters and a colon (t:)" >&2; exit 1; }
[ ! -e "$base/lib/$name.xtl" ] || { echo "new-lib: lib/$name.xtl exists" >&2; exit 1; }
[ ! -e "$root/vendor/xetal/lib/$name.xtl" ] || { echo "new-lib: $name is a standard library" >&2; exit 1; }
mkdir -p "$base/lib" "$base/tests/$name" "$base/docs/libs"
cp "$root/templates/Library.xtl" "$base/lib/$name.xtl"
cp -R "$root/templates/tests/." "$base/tests/$name/"
cp "$root/templates/page.md" "$base/docs/libs/$name.md"
esc="$(printf '%s' "$summary" | sed 's/[&|\\]/\\&/g')"
for f in "$base/lib/$name.xtl" "$base/tests/$name/basics.xtl" "$base/docs/libs/$name.md"; do
  sed -i.bak -e "s|__NAME__|$name|g" -e "s|__ALIAS__|$alias|g" -e "s|__SUMMARY__|$esc|g" "$f" && rm -f "$f.bak"
done
chmod +x "$base/tests/$name/basics.xtl"
XETAL_BLESS=1 "$root/scripts/test-libs.sh" "$name" >/dev/null
echo "new library: lib/$name.xtl, tests/$name/, docs/libs/$name.md (just test-lib $name)"
