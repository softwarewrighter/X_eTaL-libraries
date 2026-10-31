# Trig

Trigonometric and hyperbolic functions not in the base language: the
tangent, the inverse sine and cosine, the two-argument arctangent, the
hyperbolic sine and cosine and their inverses (with the inverse
hyperbolic tangent), degrees and radians, and the length of a vector
without overflow, written in closed form from X_eTaL's builtins
(`s_in`, `c_os`, `a_tan`, `s_qrt`, `e_xp`, `e_xpm1`, `l_og`,
`l_og1p`).

The hyperbolic tangent is X_eTaL's builtin `t_anh` (exact near 0, 1.0
for a large argument): Trig has no `tr:t_anh` and no copy of it.

```
"tr:" u_se< "Trig"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `tr:` is the
recommended alias.

Angles are in radians. Every function works on whole arrays, one
element at a time, and its results are Floats.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `tr:t_an x` | `Num a => a -> Float` | the tangent, `sin x / cos x` |
| `tr:a_sin x` | `Num a => a -> Float` | the angle whose sine is `x`, from -pi/2 to pi/2 |
| `tr:a_cos x` | `Num a => a -> Float` | the angle whose cosine is `x`, from 0 to pi |
| `y tr:a_tan2 x` | `(Num a, Num b) => a -> b -> Float` | the angle of the point (x, y) from the positive x axis, from -pi to pi |
| `tr:s_inh x` | `Num a => a -> Float` | the hyperbolic sine, `(e^x - e^-x) / 2` |
| `tr:c_osh x` | `Num a => a -> Float` | the hyperbolic cosine, `(e^x + e^-x) / 2` |
| `tr:a_sinh x` | `Num a => a -> Float` | the inverse hyperbolic sine, for every `x` |
| `tr:a_cosh x` | `Num a => a -> Float` | the inverse hyperbolic cosine, for `x` of 1 or more, from 0 up |
| `tr:a_tanh x` | `Num a => a -> Float` | the inverse hyperbolic tangent, for `x` strictly between -1 and 1 |
| `t_anh x` | `Num a => a -> Float` | (the builtin, not Trig's) the hyperbolic tangent |
| `tr:d_egrees x` | `Num a => a -> Float` | the angle `x` (radians) in degrees |
| `tr:r_adians x` | `Num a => a -> Float` | the angle `x` (degrees) in radians |
| `y tr:h_ypot x` | `(Num a, Num b) => a -> b -> Float` | the length of (x, y), `sqrt(x^2 + y^2)`, without overflow or underflow |

## Examples

From `../tests/basics.xtl`, with known angles (pi/4 is 45 degrees,
pi/6 is 30):

```
      tr:t_an 0.0 c_at (p_i @) / 4.0
0.0 0.9999999999999999
      tr:a_sin -1 -0.5 0 0.5 1
-1.5707963267948966 -0.5235987755982988 0.0 0.5235987755982988 1.5707963267948966
      tr:a_cos -1 -0.5 0 0.5 1
3.141592653589793 2.0943951023931953 1.5707963267948968 1.0471975511965976 0.0
      (1 1 -1 -1) tr:a_tan2 1 -1 -1 1
0.7853981633974483 2.356194490192345 -2.356194490192345 -0.7853981633974483
      (0 0 1 -1 0) tr:a_tan2 1 -1 0 0 0
0.0 3.141592653589793 1.5707963267948966 -1.5707963267948966 0.0
      tr:s_inh -1 0 1 1e-10
-1.1752011936438014 0.0 1.1752011936438014 0.00000000009999999999999999
      tr:c_osh -1 0 1 1e-5
1.5430806348152437 1.0 1.5430806348152437 1.00000000005
      t_anh -1 0 1 1e-10
-0.7615941559557649 0.0 0.7615941559557649 0.0000000001
      tr:a_sinh -1 0 1 1e-10
-0.881373587019543 0.0 0.881373587019543 0.0000000001
      tr:a_cosh 1 2 1e8 1e300
0.0 1.3169578969248166 19.11382792451231 691.4686750787736
      tr:a_tanh -0.5 0 0.5 1e-10
-0.5493061443340549 0.0 0.5493061443340549 0.0000000001
      tr:d_egrees (p_i @) * 0 0.25 0.5 1 -2
0.0 45.0 90.0 180.0 -360.0
      tr:r_adians 0 45 90 180 360
0.0 0.7853981633974483 1.5707963267948966 3.141592653589793 6.283185307179586
      (3 5 8 0) tr:h_ypot 4 12 15 0
5.0 13.0 17.0 0.0
```

That is: `tan(pi/4) = 1`; `asin` of -1, -1/2, 0, 1/2, 1 is -90, -30,
0, 30, 90 degrees; `acos` of the same is 180, 120, 90, 60, 0 degrees;
the points (1, 1), (-1, 1), (-1, -1), (1, -1) are at 45, 135, -135 and
-45 degrees; the points on the axes are at 0, 180, 90 and -90 degrees,
and the origin is given 0. `sinh 1 = 1.1752...`, `cosh 1 = 1.5430...`;
`asinh 1 = ln(1 + sqrt 2)`, `acosh 2 = ln(2 + sqrt 3)`, `atanh(1/2) =
ln(3) / 2`; near 0, `sinh x`, `asinh x`, `atanh x` (and `tanh x`) are
`x` to the digits shown and `cosh x` is `1 + x^2/2`. A half turn is
180 degrees and 90 degrees is pi/2; (3, 4), (5, 12), (8, 15) are
Pythagorean triples.

`../tests/checks.xtl` checks with the Check library: `tan(pi/3) =
sqrt 3`, `tan` is odd, `asin(sqrt 2 / 2) = pi/4`, `asin` and `acos`
undo `sin` and `cos`, `asin x + acos x = pi/2`, `atan2(sin a, cos a) =
a` all the way round, `atan2` agreeing with `atan` right of the y axis
and not changing when both coordinates are scaled, the axes and the
origin.

`../tests/hyperbolic.xtl` checks the hyperbolics: near 0, each against
its series with relative error below 1e-12 (the textbook `(e^x -
e^-x) / 2` is off by 8e-8 at `x = 1e-10`); `acosh` just above 1;
either side of where each switches to its large-argument form (20 for
`sinh`/`cosh`, 1e8 for `asinh`/`acosh`), against the textbook form
where that form is accurate; `sinh` finite at 710 and infinite at 711;
`cosh^2 - sinh^2 = 1`; `atanh` just below 1; and each inverse undoing
its function (`atanh` undoing the builtin `t_anh`).

`../tests/units.xtl` checks degrees and radians (each undoing the
other, `sin 30 degrees = 1/2`) and `h_ypot`: Pythagorean triples,
signs, the axes, `1e200` and `1e-200` (where `x^2` would overflow or
underflow), sizes 600 orders apart, and a point at radius 2.

## Demos

- [`demos/angles.xtl`](../demos/angles.xtl): the angles of a 3-4-5
  triangle from its sides (the law of cosines, `tr:a_cos`), and the
  headings of points round the origin (`tr:a_tan2`), in degrees
  (`tr:d_egrees`), and their distances (`tr:h_ypot`) (`just demo Trig
  angles`).
- [`demos/catenary.xtl`](../demos/catenary.xtl): a 110 m cable hung
  between poles 100 m apart: its catenary found by bisection on the
  arc length (`tr:s_inh`), the sag (`tr:c_osh`), the angle at each
  pole, and where it is 1 m above its lowest point (`tr:a_cosh`)
  (`just demo Trig catenary`).

## Limits

- `tr:a_sin` and `tr:a_cos` outside -1..1 have no real angle: the
  square root (`s_qrt`) they take refuses with `error[domain]`
  (tests `domain-asin`, `domain-acos`). The library adds no check of
  its own; the builtin's refusal is the check.
- `tr:t_an` is the quotient of the builtins, so it is within a few
  units in the last place of the true tangent (`tan(pi/4)` prints
  `0.9999999999999999`). Near an odd multiple of pi/2 the cosine is
  tiny and the tangent huge; at the Float nearest pi/2 it is about
  1.6e16, not a division by zero.
- `tr:a_sin` uses the half-angle form, so it keeps full relative
  accuracy near 0 and has no division by zero at -1 or 1. `tr:a_cos`
  is `2 asin(sqrt((1 - x) / 2))`, accurate near both ends, where `pi/2
  - asin x` would lose the digits of a small result near `x = 1`.
- `tr:a_tan2` takes 0 for a zero coordinate whatever its sign: a point
  on the negative x axis is at pi, never -pi, and the origin is at 0
  (C's `atan2` tells `+0.0` from `-0.0`; X_eTaL's `=` does not).

- `tr:s_inh` and `tr:c_osh` keep a relative error below 1e-12 near 0
  (`sinh` through `e_xpm1`, so the subtraction of two numbers near 1
  never happens; `cosh` is near 1 there and needs no care). Past
  `|x| = 20` they are `e^(|x| - ln 2)`, which does not overflow before
  the result itself does (at about `|x| = 710.47`, where they become
  `inf`); `e^x / 2` alone would overflow from 709.78.
- `tr:a_sinh` keeps a relative error below 1e-12 near 0 (through
  `l_og1p`) and works for every Float: past 1e8 it is `ln(2|x|)`, so
  `x^2` is never formed where it would overflow.
- `tr:a_cosh` below 1 has no real value: the square root of `x - 1`
  (`s_qrt`) refuses with `error[domain]` (test `domain-acosh`). Just
  above 1 it is accurate to the last digits of `x - 1`
  (`log1p(t + sqrt(t) sqrt(t + 2))`, `t = x - 1`).
- `tr:a_tanh` at -1 and 1 is infinite: the division by `1 - |x|`
  refuses with `error[division-by-zero]` (test `domain-atanh-one`);
  beyond them `l_og1p` refuses with `error[domain]` (test
  `domain-atanh`). Near 0 its relative error is below 1e-12.
- Inverting a flat function loses what the flatness hides: `tr:a_cosh
  tr:c_osh 0.1` is `0.09999999999999905`, because `cosh 0.1` rounds to
  a Float that holds only the first digits of `0.1^2 / 2`.

- `tr:h_ypot` divides both coordinates by the larger magnitude before
  squaring, so it overflows only where the length itself does
  (`1.5e308 tr:h_ypot 1.5e308` is past the largest Float, `inf`) and
  keeps small lengths that `x^2` would underflow to 0. It costs two
  divisions more than `s_qrt (x * x) + y * y`, and may differ from it
  in the last digit.
- `tr:d_egrees` and `tr:r_adians` multiply by a rounded `180 / pi`:
  a conversion back and forth can be off in the last digit
  (`tr:d_egrees tr:r_adians 30` is `29.999999999999996`).

## Provenance

| Function | After |
| -------- | ----- |
| `t_an` | `tan x = sin x / cos x` |
| `a_sin` | the half-angle identity `asin x = 2 atan(x / (1 + sqrt(1 - x^2)))` |
| `a_cos` | `acos x = 2 asin(sqrt((1 - x) / 2))`, from `cos 2t = 1 - 2 sin^2 t` |
| `s_inh` | `sinh a = (m + m / (m + 1)) / 2` with `m = e^a - 1` (the identity `e^-a = 1 / (m + 1)`); `e^(a - ln 2)` past 20 |
| `c_osh` | `cosh a = 1 + m^2 / (2 (m + 1))`, the same `m`; `e^(a - ln 2)` past 20 |
| `a_sinh` | `asinh a = log1p(a + a^2 / (1 + sqrt(1 + a^2)))` (rationalizing `sqrt(a^2 + 1) - 1`); `ln 2a` past 1e8 |
| `a_cosh` | `acosh x = log1p(t + sqrt(t (t + 2)))`, `t = x - 1`; `ln 2x` past 1e8 |
| `a_tanh` | `atanh a = log1p(2a / (1 - a)) / 2`, from `(1 + a) / (1 - a) = 1 + 2a / (1 - a)` |
| `d_egrees`, `r_adians` | `x * 180 / pi`, `x * pi / 180` |
| `h_ypot` | `m sqrt((x/m)^2 + (y/m)^2)`, `m` the larger of `abs x` and `abs y`, the scaling every careful `hypot` uses |
| `a_tan2` | `atan(y / x)` corrected by quadrant: plus pi for `x < 0, y >= 0`, minus pi for `x < 0, y < 0`, pi/2 or -pi/2 on the y axis, 0 at the origin (the convention C's `atan2` documents) |

Written for X_eTaL-libraries, X_eTaL-ML's ask E4
(`../X_eTaL-ML/docs/xetal-libraries-asks.md`).
