# Parsing

Total parsers for macro authors: a notation written inside a string
in, its pieces out or a refusal, nothing dropped.

```
"pa:" u_se< "Parsing"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `pa:` is the
recommended alias.

## Why

A macro parses a notation written inside a string; the language
outside the string is untouched (an X_eTaL macro cannot change how
source is read). A parser that uses part of its text and drops the
rest gives a silent wrong answer: the Equations library once summed
`(y[i] - p[i])^2` as `y - p` because its group rule dropped the last
character. These parsers each use all of their text or refuse the
call: a group must close at its last character, a reference must end
at its bracket, a chain must have a value beside every operator, and a
whole parse can be written back and compared with its text. A refusal
carries the tag the macro passes as `where`: its own error code and the
place to report at (`left`, `right` or `call`), as `[]R_EJECT` takes
them, so `"bad-equation right"` refuses with `error[bad-equation]` at
the call's right side; the message names the text.

## Pieces of text

| Function | Type | What |
| -------- | ---- | ---- |
| `pa:s_queeze t` | `Char -> Char` | `t` without its blanks (spaces, tabs, newlines) |
| `ops pa:t_op t` | `Char -> Char -> Bool` | 1 at each character of `t` that is one of `ops` at the top level: outside parentheses, brackets and braces |
| `ch pa:s_plit t` | `Char -> Char -> Box Char` | `t` cut at each top-level `ch`, the pieces trimmed and boxed |
| `w pa:a_t t` | `Char -> Char -> Int` | the position of the first `w` in `t`, or 0 |
| `(open, close) pa:c_losed t` | `(Char, Char) -> Char -> Bool` | whether `t` is one group in those brackets: it opens with `open` and the depth returns to zero once only, at its last character |
| `pa:g_roup? t` | `Char -> Bool` | whether `t` is one parenthesized group |
| `pa:i_nner t` | `Char -> Char` | the text inside a group: without its first and last characters |

## Kinds of text

| Function | Type | What |
| -------- | ---- | ---- |
| `pa:n_ame? t` | `Char -> Bool` | a lowercase name: a lowercase letter, then letters or digits |
| `pa:n_umber? t` | `Char -> Bool` | digits, with at most one point between digits |
| `pa:w_ord? t` | `Char -> Bool` | a word of name characters: letters, digits, `_` and `:` (an X_eTaL name with its namespace) |
| `pa:a_pplied? t` | `Char -> Bool` | the shape of a function applied: a word, then a parenthesized group that ends the text |

## Refusals

| Function | Type | What |
| -------- | ---- | ---- |
| `ok pa:r_equire (where, message)` | `Bool -> (Char, Char) -> Char` | nothing when `ok` holds; else the call is refused with `message` under the tag `where` (`"bad-text right"`) |
| `(where, allowed) pa:c_haracters t` | `(Char, Char) -> Char -> Char` | `t` when every character of it is in `allowed`; else a refusal naming the first that is not |
| `where pa:w_hole (text, reprint)` | `Char -> (Char, Char) -> Char` | a parse written back (`reprint`) equals `text` without its blanks, or the call is refused: a rule dropped something |

## Parsers

Each uses all of its text or refuses the call under the tag `where`.

| Function | Type | What |
| -------- | ---- | ---- |
| `(where, ops) pa:p_arts t` | `(Char, Char) -> Char -> (Box Char, Char, Bool)` | a chain cut at its top-level operators `ops`: (parts, the operators, whether it opens with a minus); an operator without a value beside it is refused |
| `(where, kind, words) pa:b_inding t` | `(Char, Char, Box Char) -> Char -> (Char, Char, Char, Char)` | `word i:=low..high` as (word, index, low, high): the word one of `words`, the index a name, the range written with `:=` and `..`; a refusal calls the word what `kind` says (`"an operator word"`) |
| `where pa:a_pplied t` | `Char -> Char -> (Char, Box Char)` | `f(a, b)` as (name, arguments), the arguments cut at the top-level commas; whether `f` is a function of the notation and how many arguments it takes is the caller's to check |
| `where pa:r_eference t` | `Char -> Char -> (Char, Box Char)` | `A[i,j]` as (name, indices): a word, then its indices in brackets that end the text (two refusals: the name, and anything after the closing bracket) |

## Examples

From `../tests/basics.xtl`:

```
      "+-" pa:t_op "a + f(b - c) - d"
0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0
      pa:s_queeze "a + b"
a+b
      ("(", ")") pa:c_losed "(a)(b)"
0
      ("(", ")") pa:c_losed "(a (b) c)"
1
      pa:n_umber? "2."
0
      pa:a_pplied? "exp(x) + 1"
0
```

The parsers refuse inside a macro; `../tests/Probe.xtlm` wraps each
one, and the `reject-*` tests pin what each refuses, for example
(`../tests/reject-reference.xtl`):

```
      @ p:r_eference< "X[i]2"
error[bad-text]: an array reference ends with its closing bracket; nothing follows it: X[i]2
```

## Demos

- [`demos/pieces.xtl`](../demos/pieces.xtl): an equation's right side
  taken apart, piece by piece, as a macro library does before it
  writes code.
- [`demos/before-after.xtl`](../demos/before-after.xtl): the naive
  group check any reader might start with, beside `pa:g_roup?`'s,
  and the silently wrong value the naive one implies next to the
  right one -- why Equations once summed `(y[i] - p[i])^2` as
  `y[i] - p[i]`.

## Provenance

Generalized from the Equations library's own helpers after its reader
dropped text (X_eTaL `docs/type-check-macros.md`, approach 9); the
whole-text check is the rule that library follows at every call.
