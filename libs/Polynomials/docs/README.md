# Polynomials

Polynomials: evaluation, sums, products, derivatives, integrals, real
roots, text.

```
"py:" u_se< "Polynomials"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `py:` is the
recommended alias. Polynomials imports Strings and Format.

A polynomial is its coefficients, highest power first, the way APL's
decode reads digits: `3 -2 1` is `3x^2 - 2x + 1`. Results are Floats.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `p py:a_t x` | `(Num a, Num b) => a -> b -> Float` | the value at each `x` |
| `a py:p_lus b` | `(Num a, Num b) => a -> b -> Float` | the sum |
| `a py:t_imes b` | `(Num a, Num b) => a -> b -> Float` | the product |
| `py:d_erivative p` | `Num a => a -> Float` | the derivative (0 for a constant) |
| `py:i_ntegral p` | `Num a => a -> Float` | the integral that is 0 at 0 |
| `py:r_oots p` | `Num a => a -> Float` | the real roots, in order |
| `py:t_ext p` | `Num a => a -> Char` | the polynomial as text |

All of them work on the whole array at once: `py:a_t` evaluates at
every `x` by a table of powers and an inner product with the
coefficients; `py:t_imes` forms every product of a coefficient of one
with one of the other (an outer product) and sums them by power;
`py:r_oots` runs Newton's method from 64 starting points together.

## Examples

From `../tests/basics.xtl`:

```
      p := 3 -2 1
      py:t_ext p
3x^2 - 2x + 1
      p py:a_t 0 1 2 -1
1.0 2.0 9.0 6.0
      1 1 py:t_imes 1 -1
1.0 0.0 -1.0
      py:d_erivative p
6.0 -2.0
      py:r_oots 1 0 -2
-1.414213562 1.414213562
      py:r_oots 1 -6 11 -6
1.0 2.0 3.0
```

`py:r_oots 1 0 1` (`x^2 + 1`) is empty: it has no real roots.

`../tests/checks.xtl` checks with the Check library, at eleven points:
a product evaluates as the product of the values, a sum as the sum,
the derivative of the integral is the polynomial, the integral is 0
at 0; and the roots of `(x - 1)(x + 2)(x - 3)` are found and are
zeros.

## Demos

- [`demos/curve.xtl`](../demos/curve.xtl): the polynomial through five
  points (solved with the Matrix library), where it crosses zero,
  where it turns (the roots of its derivative), and its picture (`just
  demo Polynomials`).

## Macros (with X_eTaL's macro libraries)

`src/Polynomials.xtlm` beside the functions holds one macro, imported
with them under the same alias. It solves a problem a function cannot:

| Macro | Call | What it does when the program is compiled |
| ----- | ---- | ---------------------------------------- |
| `py:p_oly<` | `"" py:p_oly< "3x^2 - 2x + 1"` | reads the maths notation and writes the coefficients, `3.0 -2.0 1.0`, in place of the call |

A polynomial is written as it is in maths, and the notation is read
before the program runs: like powers are added (`2x + x + 4x^2` is
`4.0 3.0 0.0`), and anything that is not a polynomial in `x` (`3y^2 +
1`) stops the compiler at the call (`notAPolynomial is not defined`),
so nothing parses notation at run time and no typo survives into a
run. The programs in [`../macros/`](../macros/) use it (`just macros`,
with an X_eTaL that runs macro libraries).

## Limits

- Roots are real and found numerically: kept where the value is 0 to
  within 1e-9 and rounded to 9 decimals; a repeated root converges
  slowly but is found; complex roots are not (complex numbers are
  planned upstream).
- Evaluation does not use X_eTaL's `d_ecode` (Horner's rule as APL
  writes it), which takes whole numbers only (ask X9).

## Provenance

| Function | After |
| -------- | ----- |
| `a_t` | APL's decode as polynomial evaluation (x decode p), here a power table and an inner product |
| `t_imes` | the APL idiom of an outer product summed along its anti-diagonals |
| `r_oots` | Newton's method within Cauchy's bound on the roots |
| `d_erivative`, `i_ntegral`, `p_lus`, `t_ext` | the definitions |
