# Format

Number formatting: fixed decimals, thousands separators, percentages,
aligned columns, text tables.

```
"f:" u_se< "Format"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `f:` is the
recommended alias. Format imports Strings and Lists.

X_eTaL's `f_ormat` gives a number as it prints, with no width or
precision (ask X8). These functions build the text from the digits. A
formatted list is a list of texts (`Box Char`), one per number, ready
for `f:c_olumn` or `f:t_able`.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `n f:f_ixed v` | `Num a => Int -> a -> Box Char` | each number with exactly `n` decimals, rounded half away from zero |
| `f:t_housands v` | `Num a => a -> Box Char` | each number rounded to a whole number, its thousands separated by commas |
| `n f:a_mount v` | `Num a => Int -> a -> Box Char` | each number with `n` decimals and its thousands separated (money) |
| `n f:p_ercent v` | `Num a => Int -> a -> Box Char` | each fraction as a percentage with `n` decimals |
| `f:c_olumn list` | `Box a -> a` | the texts right-aligned under each other, as a character matrix |
| `f:t_able cells` | `Box Char -> Char` | a matrix of texts, first row the header, as a text table |

In a table the columns are two spaces apart, each as wide as its
widest text; a column whose cells under the header are all numbers is
right-aligned (with its header), other columns left-aligned; a rule
of dashes runs under the header.

## Examples

From `../tests/basics.xtl`:

```
      f:c_olumn 2 f:f_ixed 3.5 -12.25 1000
   3.50
 -12.25
1000.00
      cells := 4 3 r_eshape "item" "qty" "price" "apple" "3" "0.50" "melon" "1" "2.75" "kiwi" "12" "0.25"
      f:t_able cells
item   qty  price
-----  ---  -----
apple    3   0.50
melon    1   2.75
kiwi    12   0.25
```

`2 f:f_ixed 3.14159 2.5 -0.004 1234.5 0` gives the texts `3.14`,
`2.50`, `0.00`, `1234.50`, `0.00`; `f:t_housands 1234567 -9876543`
gives `1,234,567`, `-9,876,543`; `2 f:a_mount -1234567.891` gives
`-1,234,567.89`; `1 f:p_ercent 0.125` gives `12.5%`.

`../tests/checks.xtl` checks with the Check library: fixed texts read
back (with `n_umbers`) as the rounded numbers and have exactly `n`
decimals, thousands without their commas are the digits, a column is
one width.

## Demos

- [`demos/invoice.xtl`](../demos/invoice.xtl): an invoice as a table
  (money to 2 places), the subtotal with thousands separated, a
  discount by a comparison used as a number, the tax as a percentage
  (`just demo Format`).

## Limits

- Rounding is of the Float: `2 f:f_ixed 2.675` is `2.67` or `2.68`
  as the binary Float happens to fall.
- A number is formatted as a whole number and decimals (no exponent
  form): very large or very small Floats are best shown with
  X_eTaL's `f_ormat`.

## Provenance

| Function | After |
| -------- | ----- |
| `f_ixed`, `a_mount` | APL's dyadic format (width and decimals, Dyalog's `8 2` format behavior) |
| `t_housands` | Dyalog's format-by-example (its FMT system function with a comma decoration) |
| `c_olumn`, `t_able` | APL's display of a character matrix; J's table utilities |
