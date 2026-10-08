# Tuples in X_eTaL-libraries

X_eTaL (eXperimental Extensible **Typed Array** Language) got tuple
values in Saga 39 (`(w, m, v, k)`, decided with the user 2026-10-07,
`../X_eTaL/docs/lang-choices.md` TU1-TU12). This page says when a
tuple is warranted here, and when an array stays the right choice,
the same way `docs/macros.md` says when a macro is warranted.

## The rule (decided with the user, 2026-10-08)

Use a tuple only where it adds value over an array: for type safety
(the type says how many parts, and of what, instead of trusting a
convention), for convenience (a pattern destructures it by name
instead of `f_irst`/`d_rop` by position), or for notation (the parts
read as what they are, not as an unlabeled vector). Most of all: a
grouping of **different-typed** arrays, which an array cannot hold at
all. Not because a tuple can: a fixed count of same-typed numbers
that gets added to, scaled, or concatenated with others like it is an
array's job, and a tuple cannot do that job (TU7: no arithmetic
through a tuple; TU2: a tuple has no shape to concatenate).

This is a *Typed Array* language: the array is the default, whole-array
operations are the idiom demonstrated everywhere in this repository,
and a tuple is reached for only when an array would lose or hide
something real.

## Array idioms (stay an array)

A result or parameter stays an array when it is further computed on
as one, concatenated with others of its kind, or has no fixed count:

- **Geometry's points.** A point (or a polygon's corners) is a 2-row
  array, `x` over `y`, because it is added to, scaled by, and
  concatenated with other points: `(ge:c_entroid tri) + 5.0 -2.0`,
  fed whole into `ge:m_ove`, `ge:s_cale`, `ge:r_otate`. A tuple could
  not be added to a number or passed through those (TU7); the array
  is not a convenience here, it is the only thing that works.
- **Statistics' `f_ive`.** The five-number summary is computed by one
  vectorized call, `0.0 0.25 0.5 0.75 1.0 l:q_uantile v`: the five
  percentiles ride through `q_uantile` together as an array. A tuple
  has no such whole-array path; building one would mean five separate
  calls where one now does the work of all five.
- Anything whose count is not fixed at compile time: a library's
  columns, a text's words, a chunking's pieces, a group's members --
  `Box` (boxed, ragged) arrays, never tuples (TU1: a tuple's arity is
  part of its type, fixed by the literal that makes it).

## Tuple idioms (worth a tuple)

Audited 2026-10-08 against every exported function's type
(`libs/*/tests/types.out`, 168 exports) and every `Box`-typed
parameter or result: no case here combines genuinely different-typed
parts yet (the domain is mostly homogeneous numeric and text
processing). Two found a real, same-typed case for the other two
reasons, type safety and convenience:

- **`Strings.r_eplace`'s `pair` parameter.** Today it is `Box Char`
  (a boxed list of any length), called as `"cat" "dog" t:r_eplace
  "..."`. Tried: `"a" "b" "c" t:r_eplace "abc"` does not fail -- it
  silently drops `"c"` and answers `bbc`. A `(Char, Char)` parameter
  makes the wrong arity a type error instead of a silent wrong
  answer: real type safety, not style.
- **`Statistics.f_it`'s result.** Today it is two Floats packed as an
  array (`intercept c_at slope`), typed only `Float` -- the type does
  not say it is always exactly two. The one caller destructures it by
  position (`f_irst f`, `f_irst 1 d_rop f`, `heights.xtl`). A
  `(Float, Float)` result types the arity and lets the caller write
  `(intercept, slope) := x sx:f_it y`.

Not yet implemented (a decision for a step of its own): both change
an exported signature, `r_eplace`'s calling convention most of all --
strand notation, `"cat" "dog" t:r_eplace ...`, becomes a tuple
literal, `("cat", "dog") t:r_eplace ...`. Worth doing, but a step
that updates every call site, the page, the tests and the baselines
together, not a silent rewrite.

## Verified on the known-good commit (2026-10-08, X_eTaL d284a8c)

- A literal and destructuring both work: `t := (3, 4.5)` then
  `(a, b) := t` binds `a` to `3`, `b` to `4.5`.
- A lambda's parameter pattern destructures a tuple directly, in
  either position: `{ (a, b) t -> ... }` called `("x", "y") u:g_
  "z"` works (the shape `r_eplace` would take).
- A dyadic call still reads left-function-right as always: `u:f_ 3
  4.5` is `f_` called monadically on the array `3 4.5`, not `f_`
  called on two arguments (strand notation makes two adjacent
  literals one array); the dyadic call is `3 u:f_ 4.5`. A tuple
  parameter sidesteps this ambiguity by making the two parts one
  value, written `(3, 4.5)`, instead of relying on which side of the
  call each one lands.
