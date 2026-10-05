# Plot

Text charts: bars, sparklines, histograms, scatter plots on a
character grid, and line charts as pictures.

```
"p:" u_se< "Plot"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `p:` is the
recommended alias. Plot imports Strings and Format.

A text chart is a character matrix: it prints as lines in a terminal,
a notebook or the live demo. A picture is an SVG document shown with
`[]S_HOW`: the command line writes it to a numbered file (`--draw
DIR`), the live demo shows it under the output.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `labels p:b_ars values` | `Num a => Box Char -> a -> Char` | a horizontal bar per value, labeled, the longest 40 wide, each followed by its value (values at least 0) |
| `p:s_park v` | `Num a => a -> Char` | a sparkline: one block character per value, from the least (lowest) to the greatest |
| `n p:h_istogram v` | `Num a => Int -> a -> Char` | `v` counted into `n` bins of equal width, drawn as bars labeled by each bin's range |
| `size p:s_catter xy` | `Num a => Int -> a -> Char` | the points `xy` (2 rows, x over y, as `[]P_ATH` takes them) marked on a grid `w` wide and `h` high (`size` is `w h`), y up |
| `p:l_ine! v` | `Num a => a -> Char` | `v` as a line chart, a picture shown with `[]S_HOW` (x is 1, 2, 3, ...); gives its SVG text |

## Examples

From `../tests/basics.xtl`:

```
      ("apples" "pears" "plums") p:b_ars 12 30 6
apples |################ 12                        
pears  |######################################## 30
plums  |######## 6                                 
      4 p:h_istogram 1 2 2 3 3 3 4 4 5 9
1.00-3.00 |######################## 3                
3.00-5.00 |######################################## 5
5.00-7.00 |######## 1                                
7.00-9.00 |######## 1                                
```

`p:s_park 1 2 3 5 8 13 8 5 3 2 1` is eleven block characters rising
to the full block and falling again (Unicode's lower blocks, U+2581
to U+2588; see it in the live demo).

`(20 8) p:s_catter (2 20 r_eshape x c_at x * x)`, with `x := r_ange
20`, draws the parabola as stars climbing to the top right.

`../tests/checks.xtl` checks with the Check library: a bar per value,
the longest 40 wide and the others in proportion, a sparkline of
`r_ange 8` is all eight heights, a scatter has the asked shape and a
mark per distinct point, a histogram a bar per bin.

## Demos

- [`demos/weather.xtl`](../demos/weather.xtl): a year of rainfall as
  bars, temperatures as a sparkline and a line picture, and a scatter
  of temperature against rain (`just demo Plot`).

## Limits

- Bars and scatter scale to the data; negative values are not drawn
  as bars.
- Points closer than one character land in the same cell.
- The sparkline's block characters need a font that has them (most
  monospace fonts do).

## Provenance

| Function | After |
| -------- | ----- |
| `b_ars`, `h_istogram` | the APL bar-chart idiom (a row of marks per value), APL's PLOT workspace ideas |
| `s_park` | Edward Tufte's sparklines, drawn with Unicode block elements |
| `s_catter` | the character-grid scatter of APL plotting workspaces |
| `l_ine!` | X_eTaL's `[]P_ATH` and `[]S_HOW` |
