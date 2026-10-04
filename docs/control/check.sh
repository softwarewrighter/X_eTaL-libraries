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
case_ case-number '"n"' c_ase '"0: \"zero\"; 1: \"one\"; \"many\""' \
  '{ @ -> caseSubject := (n); caseSubject m_atch (0) ? "zero"; caseSubject m_atch (1) ? "one"; "many" } @' 'n := 1' '' 'one'
case_ case-text '"w"' c_ase '"\"cat\": 1; \"dog\": 2; 0"' \
  '{ @ -> caseSubject := (w); caseSubject m_atch ("cat") ? 1; caseSubject m_atch ("dog") ? 2; 0 } @' 'w := "dog"' '' 2
# The subject is evaluated once: 2 is printed once, then the result.
case_ case-once '"p_rint! 2"' c_ase '"1: 10; 2: 20; 0"' \
  '{ @ -> caseSubject := (p_rint! 2); caseSubject m_atch (1) ? 10; caseSubject m_atch (2) ? 20; 0 } @' '' '' '2
20'
# Compile-time errors: nothing runs (the 99 before the choice is never printed).
case_ case-types '"n"' c_ase '"0: 1; \"two\""' \
  '{ @ -> caseSubject := (n); caseSubject m_atch (0) ? 1; "two" } @' 'n := 0
p_rint! 99' '' 'error[type-mismatch]: expected a number, found Char at 73..78'
case_ case-no-default '"n"' c_ase '"0: 1; 1: 2"' \
  '{ @ -> caseSubject := (n); caseSubject m_atch (0) ? 1; caseSubject m_atch (1) ? 2; noDefaultInCase } @' 'n := 0
p_rint! 99' '' 'error[undefined-name]: noDefaultInCase is not defined at 101..116'
case_ when-true '"n > 2"' w_hen '"p_rint! 7"' '{ @ -> n_ot (n > 2) ? @; p_rint! 7; @ } @' 'n := 3' '' '7
@'
case_ when-false '"n > 2"' w_hen '"p_rint! 7"' '{ @ -> n_ot (n > 2) ? @; p_rint! 7; @ } @' 'n := 1' '' '@'
case_ let '"a := 2; b := 3"' l_et '"a * b"' '{ @ -> a := 2; b := 3; a * b } @' '' '' 6
# a is local: using it after the expansion fails at compile time, so not even 3 is printed.
case_ let-local '"a := 2"' l_et '"a + 1"' '{ @ -> a := 2; a + 1 } @' '' 'a' 'error[undefined-name]: a is not defined at 26..27'

# X_eTaL's own system macros (no library), expanded as docs/control.md says.
sys() {
  local name="$1" src="$2" want="$3"
  local got; got="$(cd "$work" && "$xt" expand -e "$src" 2>&1)" || true
  if [ "$got" = "$want" ]; then echo "ok: system $name"; else echo "FAIL: system $name expands to:"; echo "$got"; echo "expected: $want"; fail=1; fi
}
sys i_f '"n = 0" i_f< "0.0; 100 / n"' '{ @ -> (n = 0) ? 0.0; 100 / n } @'
sys u_nless '"n = 0" u_nless< "p_rint! 1"' '{ @ -> (n = 0) ? @; p_rint! 1; @ } @'
sys e_ach '"a b" e_ach< "u:$w_x := 1"' 'u:a_x := 1
u:b_x := 1'
[ $fail = 0 ] && echo "control: ok" || { echo "control: FAILURES"; exit 1; }
