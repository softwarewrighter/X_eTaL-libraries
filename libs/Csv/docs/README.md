# Csv

Comma-separated values: lines to fields (quoted fields kept whole), a
table of texts, columns by number or name, numbers, and back to text.

```
"cs:" u_se< "Csv"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `cs:` is the
recommended alias. Csv imports Strings and Lists.

A table is a matrix of texts (`Box Char`), a row per line, its first
row the header. Fields follow RFC 4180: a field in double quotes may
hold commas, and a doubled quote inside it stands for one. A whole
line is split at once: a running count of the quote marks tells
which commas are inside quotes. Read a file with X_eTaL's `[]N_GET`
and write one with `[]N_PUT`.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `cs:f_ields line` | `Char -> Box Char` | the fields of one line |
| `cs:r_ows text` | `Char -> Box Char` | the table of a whole text, a row per line |
| `n cs:c_olumn table` | `Int -> a -> a` | the texts of column `n`, without the header |
| `name cs:f_ield table` | `Eq a => a -> Box a -> Box a` | the texts of the column with that header |
| `name cs:n_umbers table` | `Char -> Box Char -> Float` | that column as numbers |
| `cs:t_ext table` | `Box Char -> Char` | the table as comma-separated text, quoting where needed |

## Examples

From `../tests/basics.xtl`:

```
      text := "name,city,age\nAna,Oslo,34\n\"Lee, Kim\",\"Rio\",29\nBo,Lima,41\n"
      t := cs:r_ows text
      s_hape t
4 3
      "age" cs:n_umbers t
34.0 29.0 41.0
      cs:t_ext t
name,city,age
Ana,Oslo,34
"Lee, Kim",Rio,29
Bo,Lima,41
```

`cs:f_ields "1,\"Smith, Jo\",\"say \"\"hi\"\"\",4"` gives the four
fields `1`, `Smith, Jo`, `say "hi"` and `4`.

`../tests/checks.xtl` checks with the Check library: a table's shape,
writing then reading gives the table back, a comma inside quotes, a
doubled quote, an empty field, a column's numbers, columns by number
and by name agree.

## Demos

- [`demos/cities.xtl`](../demos/cities.xtl): five cities read from CSV
  text, their densities set as a table (with Format), a median and a
  correlation (with Statistics) (`just demo Csv`).

## Limits

- Every line has the same number of fields; a quoted field may not
  span lines.
- An empty field is drawn with the numbers mark `~` when a table or
  row prints boxed; it is an empty text, as `t_ally` shows (an X_eTaL
  display bug, ask X5).
- `cs:n_umbers` needs every cell of the column to be a number (empty
  cells are an error from `n_umbers`).

## Provenance

| Function | After |
| -------- | ----- |
| `f_ields`, `r_ows`, `t_ext` | RFC 4180; the quote-parity idiom of APL CSV readers (Dyalog's `CSV` system function behavior) |
| `c_olumn`, `f_ield`, `n_umbers` | column access by index and header, as in J's `tables/csv` addon |
