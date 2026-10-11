# Tags

Tags: macros only -- names for choices (`e_num<`) and for the parts of
a tagged tuple (`p_arts<`), written when the program is compiled.

```
"tg:" u_se< "Tags"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `tg:` is the
recommended alias.

Tags adds nothing to the language. Each macro writes ordinary
definitions, constants and functions, from a one-line declaration, so
a program uses choices and the parts of a tuple by name instead of by
number or position. A function computes values; it cannot define
names you choose, which is why these are macros. X_eTaL stays array
first: choices are codes that index tables, and a tagged tuple's parts
may be whole columns.

## Macros

| Macro | Call | Writes |
| ----- | ---- | ------ |
| `tg:e_num<` | `@ tg:e_num< "Color: black red green"` | a constant per choice, its code its position: `BLACK := 1`, `RED := 2`, `GREEN := 3`; and the names by code, `COLOR := "black" "red" "green"` |
| `tg:p_arts<` | `@ tg:p_arts< "State: w m v k"` | the tag `STATE := "State"`; the constructor `u:s_tate`; the test `u:s_tate?`; per part a getter (`u:s_tateW`) and a setter (`u:s_etStateW`); `u:s_tateRows` |

### Choices: e_num<

A choice is a code, 1, 2, 3 in the order declared, under a constant
named in capitals. Codes index tables in the same order, so a choice
selects its color, its next state or its move from an array instead
of a chain of guards; `=` compares them, item by item.

From `../tests/basics.xtl`:

```
      BLACK c_at RED c_at GREEN
1 2 3
      d_isclose GREEN s_elect COLOR
green
      palette = RED
1 0 1 0
```

### Tagged tuples: p_arts<

`@ tg:p_arts< "State: w m v k"` declares a kind of tuple whose first
part is a tag naming the kind, then the parts. It writes:

| Name | Type, for State | What |
| ---- | --------------- | ---- |
| `STATE` | `Char` | the tag, `"State"` |
| `u:s_tate (w, m, v, k)` | `(a, b, c, d) -> (Char, a, b, c, d)` | the tagged tuple |
| `u:s_tate? s` | tuple of 5 `-> Bool` | whether `s` is tagged State |
| `u:s_tateW s` | tuple of 5 `-> a` | part `w` (a getter per part) |
| `x u:s_etStateW s` | `a -> (Char, a, b, c, d) -> (Char, a, b, c, d)` | `s` with part `w` replaced by `x`, of the same type (a setter per part) |
| `i u:s_tateRows s` | `Int -> ... -> ...` | the items `i` of every part, when the parts are columns |

A getter is the kind's name with the part's name in capitals after
it; a setter is `u:s_et`, the kind, the part. Kinds are a capital
letter then letters or digits; parts are lowercase, at most 26.

From `../tests/basics.xtl`:

```
      s := u:s_tate (8.0 4.0, 0.0 0.0, 0.0 0.0, 0)
      s
(State, 8.0 4.0, 0.0 0.0, 0.0 0.0, 0)
      u:s_tateW s
8.0 4.0
      (1 + u:s_tateK s) u:s_etStateK s
(State, 8.0 4.0, 0.0 0.0, 0.0 0.0, 1)
```

### Columns

When the parts are arrays of one length, the tagged tuple is a table
stored by column: every operation is on a whole column, and
`u:s_coresRows` takes rows from all of them at once.

From `../tests/columns.xtl`:

```
      u:p_eopleAge t
31 42 27
      '+ r_/ u:p_eopleScore t
6.0
```

## What is checked, and when

| Mistake | Caught | Example |
| ------- | ------ | ------- |
| a malformed declaration | when the program is compiled: `error[bad-enum]`, `error[bad-parts]` | `../tests/badparts.xtl`, `../tests/badenum.xtl` |
| a tuple of another shape | when the program is checked: `error[type-mismatch]` | `../tests/wrong-shape.xtl` |
| a setter given a value of another type | when the program is checked | `../tests/setter-type.xtl` |
| another kind of the same shape | when it runs: `error[wrong-kind]` | `../tests/wrong-kind.xtl` |
| one choice for another (`RED` for `UP`) | not caught: both are Int codes | -- |

From `../tests/wrong-kind.xtl`, where Meters and Feet each have one
part:

```
      u:m_etersV u:m_eters 2.5
2.5
      u:m_etersV u:f_eet 2.5
error[wrong-kind]: expected a Meters at 180..204
```

## Limits

- A tag is text and a choice is an Int, so two kinds of one shape, or
  choices of two enumerations, have the same type: the first is found
  when the program runs, the second not at all. A tag type of its own
  in X_eTaL would find both when the program is checked (X_eTaL's
  docs/adt.md, a proposal).
- Each getter and setter compares the tag when it runs (one
  comparison).
- The functions written take their parameters by position (`a`, `b`,
  ...), not by the parts' names, because of X_eTaL ask X19 (a name
  copied from the call into a lambda can be renamed in one place and
  not another); `xetal expand` shows them so.
- Names are bound once (X_eTaL D135): two kinds in one program cannot
  share a kind name, and two enumerations cannot share a choice name.

## Demos

- [`demos/turtle.xtl`](../demos/turtle.xtl): a turtle's heading is a
  choice, its state a tagged tuple of a position, a heading and a step
  count; turns and moves are tables indexed by the heading
  (`just demo Tags turtle`).
- [`demos/scores.xtl`](../demos/scores.xtl): a table of scores as
  columns, rows taken by position and in order of points.

## Provenance

| Macro | After |
| ----- | ----- |
| `e_num<` | Julia's `@enum` macro and the named constants of APL practice: a choice is a code indexing tables |
| `p_arts<` | Erlang's tagged tuples, TypeScript's discriminated unions (a tag part naming the kind), Bits' `f_ields<` (a getter and a setter per named part); columns after APL's inverted tables and q's tables |

Written for this repository; no code copied.
