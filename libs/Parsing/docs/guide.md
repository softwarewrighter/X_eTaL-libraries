# Writing a notation macro with Parsing

A walk-through: building one small macro, `for<`, that reads a list
of stepped ranges written the way a paper writes them --
`for i:=0..10 by 2` -- and binds each one to a name. It uses every
kind of tool `libs/Parsing` offers, one at a time, in the order a
real macro needs them. The finished macro is `libs/Ranges`' `r:f_or<`;
this guide builds the same thing from nothing, explaining each piece.

## The problem

X_eTaL's `r_ange` is `1..n`, nothing more (`r_ange 5` is `1 2 3 4
5`): no low bound, no step. A notation that writes a stepped,
zero-based range the way a paper would -- `for i:=0..10 by 2` -- is
useful and the language has no syntax for it, so it is a macro's job
(`docs/macros.md`'s rule: a macro earns its place where a function or
a guard cannot).

A macro is a function from the text written at its call to the
source that replaces it, run before the program is compiled (X_eTaL
MC10). That means it is a little compiler for its own notation, and
like any parser it can go wrong the way the Equations library once
did: its group rule silently dropped the last character of `(y[i] -
p[i])^2`, so it computed `y - p` and never said so (`libs/Parsing`'s
own README tells this story; `demos/before-after.xtl`, in this
library, makes it concrete). `libs/Parsing` exists so a new macro
does not repeat that mistake: every tool here either uses all of its
text or refuses the call, and a parse can be written back and
compared with the text it came from.

## The pieces

`for i:=0..10 by 2` has:

- the word `for` (so the notation reads as a sentence; it has no
  other job);
- an index, `i`, the name the result is bound to;
- a range, `0..10`, written the way `Equations`' own sums write a
  range;
- an optional step, `by 2` (default 1);
- any of several of these, separated by commas: `for i:=0..4, for
  j:=0..9 by 3` binds two names from one call.

Each of `low` and `high` is itself not just a number: it may be a
parenthesized expression (`(n - 1)`), an array's length (`len(A)`),
one of its elements (`A[0]`), or a bare number. Building the bounds
reader is where most of Parsing's tools earn their place.

From here on, a few examples run the finished macro to show what a
piece looks like once it is wired in -- `"r:" u_se< "ForRange"`, its
file built up through this guide, `r:` its alias throughout.

## Splitting the list: `pa:s_plit`

A notation with several comma-separated pieces is cut outside
brackets, so a comma inside a bound's own parentheses is not mistaken
for the list's separator:

```
"pa:" u_se< "Parsing"
      "," pa:s_plit "a, f(b, c), d"
.>------------------.
| .>. .>------. .>. |
| |a| |f(b, c)| |d| |
| '-' '-------' '-' |
'e------------------'
```

Three pieces, `a`, `f(b, c)` and `d` -- boxed, since they are not all
the same length, so they cannot sit in one flat array -- the middle
one kept whole although it has a comma of its own. `for<`'s own first
line is the same call:

```
pieces := '{ p -> h:p_iece d_isclose p } m_ap "," pa:s_plit t:t_rim text
```

one `h:p_iece` per comma-separated range.

## One binding: `pa:b_inding`

`for i:=0..10` (the `by 2` comes off first, next) is exactly the
shape Equations' own sums use for `sum c:=0..C-1`: an operator word,
an index, `:=`, and an inclusive range cut at `..`. `pa:b_inding`
reads it directly:

```
      ("bad-range right", "a loop variable (for)", e_nclose "for") pa:b_inding "for i:=0..10"
(for, i, 0, 10)
```

four texts back: the word, the index, the low bound, the high bound.
Reusing it instead of writing a fifth copy of the same rule is the
point of having `Parsing` at all -- it is the same tool Equations
uses for `sum`, `prod`, `max`, `min` and `integral`.

The index's own rule, `pa:n_ame?`, and the word check (`known := ...
m_atch word ... e_ach words`) are `pa:b_inding`'s; a wrong word is
already refused naming what the notation wants:

```
      @ r:f_or< "while i:=0..10"
error[bad-range]: a binding starts with a loop variable (for) (for): while i:=0..10
```

(shown through the macro itself, since `pa:b_inding`'s refusal, like
every refusal in this library, only fires while a macro is expanding
-- calling a refusing parser bare from a plain program is
`error[hook-outside-macro]`; `tests/Probe.xtlm` is Parsing's own
wrapper for showing refusals in isolation).

## The optional step: `pa:a_t` and `pa:n_umber?`

`by 2` is cut off before `pa:b_inding` ever sees it (its own range
reader takes everything after `..` as the high bound, so `by` left in
would be read as part of `10`): a plain substring search,
`pa:a_t`, finds `" by "`; its position decides whether a step was
written at all:

```
h:p_iece := { t ->
  at := " by " pa:a_t t
  (core, stepText) := (0 = at) h:p_ickPair ((t, "1"), (t:t_rim (at - 1) t_ake t, t:t_rim (at + 3) d_rop t))
  _ := (pa:n_umber? stepText) pa:r_equire ("bad-range right", "a step is a whole number: " c_at stepText)
  ...
```

`pa:n_umber?` is a kind check, not a parser that drops anything, so
pairing it with `pa:r_equire` is the idiom for "refuse unless this
text has the shape I need": written out, `("bad-range right",
"a step is a whole number: " c_at stepText)` is `where` and
`message`; `pa:r_equire` does nothing when the check passes, else
calls `[]R_EJECT` with them (more on `where` below).

## The bounds: a small reader of its own

A bound is not only a number. It is a chain of `+` and `-` (so `len(A)
- 1` and `A[0] + 1` both work), each piece one of four shapes: a
group, a function applied, a reference, or a bare atom. This is the
same dispatch Equations' own `h:v_alueOf` makes, just over four cases
instead of eight.

### A chain with a leading minus: `pa:p_arts`

```
("bad-range right", "+-") pa:p_arts "len(A)-1"
```

cuts a chain at its top-level operators, giving the parts, the
operators between them, and whether it opens with a bare `-` (so `-5
+ n` reads as `0 - 5 + n`, not a parse error for having no part
before the first operator). It refuses when an operator has no value
beside it:

```
      @ r:f_or< "for i:=0..1+"
error[bad-range]: an operator needs a value on each side: 1+
```

A chain with no `+` or `-` at all (a bare bound, `"10"`) has nothing
for `pa:p_arts` to cut, so `for<`'s `h:b_ound` checks for an operator
first and only calls it when one is there -- the same guard Equations
makes before calling its own chain reader.

### A balanced group: `pa:g_roup?` and `pa:i_nner`

A bound in parentheses, `(n - 1)`, is a group: `pa:g_roup?` checks it
opens and closes exactly once, at the first and last character
(`(a)(b)` is two groups, not one, and `pa:g_roup?` says so); `pa:i_nner`
strips the parentheses so the inside can be read the same way as any
other bound -- `h:b_ound` simply calls itself on it:

```
      pa:g_roup? "(a)(b)"
0
      pa:g_roup? "((a) + b)"
1
      pa:i_nner "(a + b)"
a + b
```

### A function applied: `pa:a_pplied?` and `pa:a_pplied`

`len(A)` has the shape a function call always does -- a word, then
one parenthesized group that ends the text -- which `pa:a_pplied?`
checks and `pa:a_pplied` takes apart into (name, arguments):

```
      pa:a_pplied? "len(A)"
1
      "bad-range right" pa:a_pplied "len(A)"
(1: len
, 2:
 .>----.
 | .>. |
 | |A| |
 | '-' |
 'e----'
)
```

(the second half of the pair is itself a boxed array -- one argument,
`A` -- since a function may take more than one; `len` never does, but
`pa:a_pplied` cannot know that, so it always gives the arguments cut
at the top-level commas, however many there are).

`for<` only knows one function, `len`, so it refuses any other name
right there, naming what it expected:

```
h:f_n := { t ->
  (name, args) := "bad-range right" pa:a_pplied t
  _ := (("len" m_atch name) & 1 = t_ally args) pa:r_equire ("bad-range right", "a bound's function is len(name): " c_at t)
  "(t_ally " c_at (d_isclose f_irst args) c_at ")"
}
```

`t_ally` is X_eTaL's own array-length function; the macro's job is
only to translate the notation's `len(A)` into it.

### A reference: `pa:r_eference`

`A[0]` -- one element of a caller's array, read 0-origin as the
notation writes it -- is `pa:r_eference`'s job: name, then indices in
brackets that must end the text (its own refusal, separate from
`pa:a_pplied`'s, is for anything found after the closing bracket):

```
      "bad-range right" pa:r_eference "A[0]"
(1: A
, 2:
 .>----.
 | .>. |
 | |0| |
 | '-' |
 'e----'
)
```

`for<` turns that into X_eTaL's own 1-origin `s_elect`:

```
h:r_ef := { t ->
  (name, ix) := "bad-range right" pa:r_eference t
  "((1 + " c_at (d_isclose f_irst ix) c_at ") s_elect " c_at name c_at ")"
}
```

### Putting the four together

`h:a_tom` is the one-case-at-a-time dispatch, tried in an order where
each check is safe to make before the others (a group must be checked
before a plain name, or `(n)` would never reach it; a reference's `[`
is checked last since neither a group nor a function call contains
one at the top level of a bound):

```
h:a_tom := { t ->
  pa:g_roup? t ? h:b_ound pa:i_nner t
  pa:a_pplied? t ? h:f_n t
  0 < "[" pa:a_t t ? h:r_ef t
  t
}
```

A bare name or number falls through unchanged -- it is already valid
X_eTaL.

## Nothing dropped: `pa:w_hole`

Every piece above reads *some* of the text correctly on its own; what
stops one of them from reading only *part* of it and leaving the rest
on the floor (exactly what happened to Equations) is comparing the
whole call's text with the same text reconstructed from what was
parsed:

```
reprint := "," t:j_oin '{ b -> (rp, _) := d_isclose b; rp } m_ap pieces
_ := "bad-range right" pa:w_hole (text, reprint)
```

`pa:w_hole`'s rule is simple: the reprint must equal the original
text with its blanks removed (`pa:s_queeze`), or the call is refused
naming what was read and from where. It catches the case none of the
pieces above would, on their own: a bound whose reader stopped early
and left trailing text sitting unread:

```
      @ r:f_or< "for i:=0..10 extra"
error[bad-range]: the parser did not use all of the text: it read fori:=0..10 extra from for i:=0..10 extra
```

(`h:b_ound`'s fallback case, `t` bare, happily accepted `"10 extra"`
as a high bound with no complaint of its own -- it is `pa:w_hole`,
not that case, that catches the extra word. This is exactly why the
check exists: no single piece has to be perfectly suspicious of its
own input, as long as the whole call is checked once at the end.)

## The macro itself

```
## A comma-separated list of "for i:=lo..hi [by step]" pieces, each
## binding its own name to a stepped range; the whole call's text
## must be used, nothing dropped (Parsing's whole-text check).
## takes: @ text
## uses: parsed
m:f_or< := { @ text ->
  pieces := '{ p -> h:p_iece d_isclose p } m_ap "," pa:s_plit t:t_rim text
  reprint := "," t:j_oin '{ b -> (rp, _) := d_isclose b; rp } m_ap pieces
  _ := "bad-range right" pa:w_hole (text, reprint)
  "" t:j_oin '{ b -> (_, st) := d_isclose b; st } m_ap pieces
}
```

Each `h:p_iece` gives back two texts: a canonical reprint (for the
whole-text check above) and the statement it binds, `i := 0 + (2 *
((r_ange (1 + f_loor ((10 - 0) / 2))) - 1))` -- ordinary X_eTaL, built
once from the parsed low, high and step, run like any other
expression when the program runs. Trying it:

```
      "r:" u_se< "ForRange"
      A := 0 0 0 0 0
      @ r:f_or< "for i:=0..10 by 2, for j:=0..len(A)-1"
      i
0 2 4 6 8 10
      j
0 1 2 3 4
```

## The where tag

Every refusal above passed a string like `"bad-range right"` as
`where`. It is not one piece of data but two, read by `[]R_EJECT`
itself (`"code place" []R_EJECT "message"`, X_eTaL MC20): the error
code (`bad-range`, becomes `error[bad-range]` in the message shown)
and the place to report the error at -- `left`, `right` or `call`,
meaning the macro's left argument, its right argument, or the call as
a whole. `for<` takes no left argument worth pointing at (it is `@`),
so every refusal in it says `right`; `Equations`' two-sided macros say
`left` for a mistake in the result's name and its indices, `right`
for one in the expression.

Tracing one call all the way through: `@ r:f_or< "while i:=0..10"`
reaches `pa:b_inding`'s own check,

```
known l:r_equire (where, "a binding starts with " c_at kind c_at " (" c_at (", " t:j_oin words) c_at "): " c_at s)
```

with `where` still the string `"bad-range right"` handed down from
`h:p_iece`'s own call to `pa:b_inding`. `l:r_equire` is `ok ? ""; where
[]R_EJECT message` -- since `known` is false here, it calls
`"bad-range right" []R_EJECT "a binding starts with a loop variable
(for) (for): while i:=0..10"`. `[]R_EJECT` reads `"bad-range right"`
as the pair (`bad-range`, `right`), stops the macro's expansion, and
reports `error[bad-range]` at the call's right argument (the string
`"while i:=0..10"` itself) with the message as written:

```
error[bad-range]: a binding starts with a loop variable (for) (for): while i:=0..10
 --> range-demo.xtl:2:11
  |
2 | @ r:f_or< "while i:=0..10"
  |           ^^^^^^^^^^^^^^^^
```

(`range-demo.xtl` is `"r:" u_se< "ForRange"` on line 1, the call on
line 2; the file this guide builds up does the same.) Nothing in
`for<` ever names a line or column itself -- `where`
names only which *side* of the call is at fault, and the compiler
turns that into the span shown, the same way it would for any other
error.

## Where this goes next

`libs/Ranges` packages exactly this macro for real use, with its own
tests, a good-input demo and one demo per mistake above, each pinning
the refusal it shows here. `libs/Equations` is the same architecture
grown up: eight kinds of expression instead of four, two sides
instead of one, and a LaTeX reader sharing the same parse. Reading
its `h:v_alueOf` after this guide should look familiar rather than
dense.
