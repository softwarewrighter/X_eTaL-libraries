#!/usr/bin/env bash
# Test Control.xtlm's macro bodies today, before X_eTaL runs .xtlm
# files: each body is an ordinary function from text to text, so the
# file is loaded as a plain library (m:name< := becomes l:name :=),
# each macro is called on its example texts, the expansion compared
# with the expected one, and the expansion itself run as X_eTaL and
# its result compared. Nothing here emulates macro syntax for users.
#   docs/control/check.sh
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
work="$root/target/control"; rm -rf "$work"; mkdir -p "$work"
sed -E 's/^m:([a-z]_[A-Za-z0-9]*)< :=/l:\1 :=/' "$root/docs/control/Control.xtlm" > "$work/ControlBodies.xtl"
xt="$root/scripts/xt"
fail=0
# case NAME LEFT MACRO RIGHT EXPECTED-EXPANSION SETUP AFTER EXPECTED-RESULT
# (the expansion runs between SETUP and AFTER)
case_() {
  local name="$1" left="$2" macro="$3" right="$4" want="$5" setup="$6" after="$7" result="$8"
  printf '"x:" u_se< "ControlBodies"\n%s x:%s %s\n' "$left" "$macro" "$right" > "$work/$name.xtl"
  local got; got="$(cd "$work" && "$xt" run "$name.xtl" 2>&1)" || true
  if [ "$got" != "$want" ]; then echo "FAIL: $name expands to:"; echo "$got"; echo "expected:"; echo "$want"; fail=1; return; fi
  printf '%s\n%s\n%s\n' "$setup" "$got" "$after" > "$work/$name-run.xtl"
  local res; res="$(cd "$work" && "$xt" run "$name-run.xtl" 2>&1)" || true
  if [ "$res" != "$result" ]; then echo "FAIL: $name's expansion gives:"; echo "$res"; echo "expected: $result"; fail=1; return; fi
  echo "ok: $name"
}
case_ if-true  '"n = 4"' i_f '"10 ; 20"' '{ @ -> (n = 4) ? 10; 20 } @' 'n := 4' '' 10
case_ if-false '"n = 0"' i_f '"0.0 ; 100 / n"' '{ @ -> (n = 0) ? 0.0; 100 / n } @' 'n := 4' '' 25.0
case_ unless   '"n = 0"' u_nless '"100 / n ; 0.0"' '{ @ -> (n = 0) ? 0.0; 100 / n } @' 'n := 4' '' 25.0
# Only the branch chosen runs: with n = 0, 1 d_iv n is never evaluated.
case_ if-lazy  '"n = 0"' i_f '"0 ; 1 d_iv n"' '{ @ -> (n = 0) ? 0; 1 d_iv n } @' 'n := 0' '' 0
case_ each     '"2 3 10"' e_ach '"u:t_imes# := { _r * # }"' 'u:t_imes2 := { _r * 2 }
u:t_imes3 := { _r * 3 }
u:t_imes10 := { _r * 10 }' '' 'u:t_imes10 u:t_imes3 7' 210
[ $fail = 0 ] && echo "control: ok" || { echo "control: FAILURES"; exit 1; }
