# Plot

Text charts: bars, sparklines, histograms, scatter plots on a
character grid; and line charts as pictures, with axes, a title, named
axes and several lines in one chart.

```
"p:" u_se< "Plot"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `p:` is the
recommended alias. Plot imports Strings, Format and the standard Svg.

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
| `p:l_ine! v` | `Num a => a -> Char` | `v` as a line chart with axes, a picture shown with `[]S_HOW`; gives its SVG text |
| `names p:l_ines! series` | `Num a => Box Char -> Box a -> Char` | several lines in one chart, one per boxed vector of `series` (each its own length), colored in turn and named in a legend |
| `labels p:c_hart! series` | `Num a => Box Char -> Box a -> Char` | as `p:l_ines!`, with a title and named axes: `labels` is the title, the horizontal axis's name, the vertical axis's name, then a name per series (`""` leaves one out) |

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

A line chart's vertical axis spans the values, however small their
range (`p:l_ine! 0.0012 0.0009 0.0007 0.0005` has ticks 0.00050,
0.00085, 0.00120), with three ticks (least, middle, greatest); the
horizontal axis is the positions 1 to the longest series. A single
value is drawn as a point, and a flat series gets a range around its
value. Loss and accuracy of a training run in one picture:

```
("Training" "step" "value" "loss" "accuracy") p:c_hart! (e_nclose losses) c_at e_nclose accuracy
```

`../tests/chart-svg.xtl` pins the SVG text of such a chart;
`../tests/lines.xtl` checks the line charts with Check (a small range
spread over the axis, a single point, two lines in two colors and a
legend, a title and the axes' names).

`../tests/checks.xtl` checks with the Check library: a bar per value,
the longest 40 wide and the others in proportion, a sparkline of
`r_ange 8` is all eight heights, a scatter has the asked shape and a
mark per distinct point, a histogram a bar per bin.

## Demos

- [`demos/weather.xtl`](../demos/weather.xtl): a year of rainfall as
  bars, temperatures as a sparkline and a line picture, a scatter of
  temperature against rain, and rain and temperature in one titled
  chart (`just demo Plot`).

## Limits

- Bars and scatter scale to the data; negative values are not drawn
  as bars.
- Points closer than one character land in the same cell.
- The sparkline's block characters need a font that has them (most
  monospace fonts do).
- The lines of a chart share one vertical axis (no second axis for a
  series in other units), and six colors are used in turn.
- A chart is 480 by 280; the picture scales to where it is shown.

## Provenance

| Function | After |
| -------- | ----- |
| `b_ars`, `h_istogram` | the APL bar-chart idiom (a row of marks per value), APL's PLOT workspace ideas |
| `s_park` | Edward Tufte's sparklines, drawn with Unicode block elements |
| `s_catter` | the character-grid scatter of APL plotting workspaces |
| `l_ine!`, `l_ines!`, `c_hart!` | the line plot of plotting libraries (gnuplot, matplotlib's `plot` with `title`, `xlabel`, `ylabel` and `legend`), drawn with X_eTaL's standard Svg and `[]S_HOW` |
