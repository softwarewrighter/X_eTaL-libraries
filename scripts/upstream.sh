#!/usr/bin/env bash
# Where X_eTaL stands on this repo's asks (docs/xetal-asks.md): its
# active saga, its saga queue, and for each ask whether the feature is
# in X_eTaL's committed HEAD and in the known-good commit (work/xetal). Reads ../X_eTaL
# (XETAL_REPO overrides); changes nothing.
#   scripts/upstream.sh
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
repo="${XETAL_REPO:-$root/../X_eTaL}"
[ -d "$repo/.git" ] || { echo "upstream: no X_eTaL checkout at $repo" >&2; exit 1; }
vendored="$(cut -c1-7 "$root/XETAL_COMMIT")"
head="$(git -C "$repo" rev-parse --short=7 HEAD)"
echo "X_eTaL HEAD $head ($(git -C "$repo" log -1 --format=%cs)); known-good $vendored, $(git -C "$repo" rev-list --count "$vendored..HEAD") commits behind"
if [ -f "$repo/.agentrail/saga.toml" ]; then
  echo "active saga: $(sed -n 's/^name = "\(.*\)"/\1/p' "$repo/.agentrail/saga.toml"), step $(sed -n 's/^current_step = //p' "$repo/.agentrail/saga.toml")"
fi
echo
echo "saga queue (../X_eTaL/docs/plan.md):"
git -C "$repo" show HEAD:docs/plan.md | grep -E '^[0-9]+\. Saga ' | sed 's/^/  /' | cut -c1-110
echo
# ask | upstream saga | a regex whose match in the code means "there"
asks=(
  "X1 .xtlm macro libraries|Saga 19|xtlm"
  "X2 seeing expansions|Saga 19|--expand|\"expand\""
  "X3 assert, raise, catch|Saga 21|a_ssert|t_ry"
  "X4 []U_CS, []A, []TS|Saga 13|U_CS"
  "X5 empty Char drawn as numbers|Saga 20|kind of an empty"
  "X6 big whole numbers|wish list|BigInt|bigint"
  "X7 matrix divide|none planned|d_omino|m_atdiv"
  "X8 width and precision|wish list|f_ormat_2|dyadic format"
)
printf '%-32s %-14s %-10s %s\n' "ask" "upstream" "HEAD" "known-good"
for a in "${asks[@]}"; do
  IFS='|' read -r name saga pat1 pat2 <<<"$a"
  pat="$pat1${pat2:+|$pat2}"
  in_head=no; in_vendor=no
  git -C "$repo" grep -qE "$pat" HEAD -- components ':!*.md' 2>/dev/null && in_head=yes
  grep -rqE "$pat" "$root/work/xetal/components" --include='*.rs' 2>/dev/null && in_vendor=yes
  printf '%-32s %-14s %-10s %s\n' "$name" "$saga" "$in_head" "$in_vendor"
done
echo
echo "(a \"yes\" is a sign in the code, not a landed feature: confirm by moving XETAL_COMMIT (just bump) and running the ask's repro)"
