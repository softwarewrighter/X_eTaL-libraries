# Trig

Trigonometric functions not in the base language: the tangent, the
inverse sine and cosine, and the two-argument arctangent, written in
closed form from X_eTaL's builtins (`s_in`, `c_os`, `a_tan`, `^`).

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
```

That is: `tan(pi/4) = 1`; `asin` of -1, -1/2, 0, 1/2, 1 is -90, -30,
0, 30, 90 degrees; `acos` of the same is 180, 120, 90, 60, 0 degrees;
the points (1, 1), (-1, 1), (-1, -1), (1, -1) are at 45, 135, -135 and
-45 degrees; the points on the axes are at 0, 180, 90 and -90 degrees,
and the origin is given 0.

`../tests/checks.xtl` checks with the Check library: `tan(pi/3) =
sqrt 3`, `tan` is odd, `asin(sqrt 2 / 2) = pi/4`, `asin` and `acos`
undo `sin` and `cos`, `asin x + acos x = pi/2`, `atan2(sin a, cos a) =
a` all the way round, `atan2` agreeing with `atan` right of the y axis
and not changing when both coordinates are scaled, the axes and the
origin.

## Demos

- [`demos/angles.xtl`](../demos/angles.xtl): the angles of a 3-4-5
  triangle from its sides (the law of cosines, `tr:a_cos`), and the
  headings of points round the origin (`tr:a_tan2`), in degrees
  (`just demo Trig`).

## Limits

- `tr:a_sin` and `tr:a_cos` outside -1..1 have no real angle: the
  square root (`^ 0.5`) they take refuses with `error[complex-result]`
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

## Provenance

| Function | After |
| -------- | ----- |
| `t_an` | `tan x = sin x / cos x` |
| `a_sin` | the half-angle identity `asin x = 2 atan(x / (1 + sqrt(1 - x^2)))` |
| `a_cos` | `acos x = 2 asin(sqrt((1 - x) / 2))`, from `cos 2t = 1 - 2 sin^2 t` |
| `a_tan2` | `atan(y / x)` corrected by quadrant: plus pi for `x < 0, y >= 0`, minus pi for `x < 0, y < 0`, pi/2 or -pi/2 on the y axis, 0 at the origin (the convention C's `atan2` documents) |

Written for X_eTaL-libraries, X_eTaL-ML's ask E4
(`../X_eTaL-ML/docs/xetal-libraries-asks.md`).
