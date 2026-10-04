# Statistics

Statistics: median, quantiles, five-number summaries, z-scores,
covariance, correlation, a least-squares line, binned counts. Builds
on X_eTaL's standard `Stats`.

```
"sx:" u_se< "Statistics"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `sx:` is the
recommended alias (`s:` is the usual letter for `Stats`). The
standard `Stats` has the mean, variance (of the population), standard
deviation and range; import it beside this one, `"s:" u_se< "Stats"`.
Results are Floats.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `p sx:q_uantile v` | `(Num a, Num b) => a -> b -> Float` | the `p` quantile of `v` for each `p` from 0 to 1, interpolating between the two nearest items |
| `sx:m_edian v` | `Num a => a -> Float` | the middle value (the mean of the two middle ones for an even count) |
| `sx:f_ive v` | `Num a => a -> Float` | least, lower quartile, median, upper quartile, greatest |
| `sx:z_scores v` | `Num a => a -> Float` | how many standard deviations each item is from the mean |
| `a sx:c_ovariance b` | `(Num a, Num b) => a -> b -> Float` | the mean product of the deviations (population) |
| `a sx:c_orrelation b` | `(Num a, Num b) => a -> b -> Float` | Pearson's correlation, from -1 to 1 |
| `x sx:f_it y` | `(Num a, Num b) => a -> b -> Float` | the least-squares line: intercept and slope |
| `n sx:b_ins v` | `Num a => Int -> a -> Int` | how many items fall in each of `n` bins of equal width (Plot's `p:h_istogram` draws them) |

## Examples

From `../tests/basics.xtl`, with `v := 2 4 4 4 5 5 7 9`:

```
      sx:m_edian v
4.5
      0.1 0.9 sx:q_uantile r_ange 10
1.9 9.1
      sx:f_ive 1 2 3 4 5 6 7 8 9 10 100
1.0 3.5 6.0 8.5 100.0
      sx:z_scores v
-1.5 -0.5 -0.5 -0.5 0.0 0.0 1.0 2.0
      x := 1 2 3 4 5
      y := 2 4 5 4 5
      x sx:c_orrelation y
0.7745966692414833
      x sx:f_it y
2.2 0.6
```

`../tests/checks.xtl` checks with the Check library: the median of an
even count, quartiles as R's default (type 7) gives them, z-scores
with mean 0 and standard deviation 1, a perfect line correlating 1
and its reverse -1, the fit recovering a line, the covariance of a
list with itself being its variance, bins counting every item.

## Demos

- [`demos/heights.xtl`](../demos/heights.xtl): twelve heights and
  weights: summaries, correlation, the fitted line, the unusual ones
  by z-score, and the mean of a group that turns out empty, by a
  guarded function that evaluates only the result it chooses (`just
  demo Statistics`).

## Limits

- Variances and standard deviations are of the population (divided by
  `n`), as the standard `Stats` computes them, not the sample (`n - 1`).
- Quantiles interpolate one way (R's type 7, Excel's PERCENTILE);
  other definitions give slightly different quartiles.

## Provenance

| Function | After |
| -------- | ----- |
| `q_uantile`, `m_edian`, `f_ive` | Hyndman and Fan's type 7 (R's default `quantile`), Tukey's five-number summary |
| `z_scores`, `c_ovariance`, `c_orrelation`, `f_it` | the textbook formulas, written as whole-array expressions over the standard `Stats` |
| `b_ins` | J's stats addon's histogram counts |
