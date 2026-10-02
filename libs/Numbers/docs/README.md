# Numbers

Number theory: gcd and lcm, primes, prime factors, divisors, digits
in any base, whole square roots, Fibonacci numbers.

```
"n:" u_se< "Numbers"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `n:` is the recommended alias.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `a n:g_cd b` | `Int -> Int -> Int` | the greatest common divisor, item by item |
| `a n:l_cm b` | `Int -> Int -> Int` | the least common multiple, item by item (0 with a 0) |
| `n:i_sqrt n` | `Int -> Int` | the whole square root: the largest `s` with `s * s <= n`, item by item |
| `n:p_rimes n` | `Int -> Int` | the primes up to `n` (the sieve of Eratosthenes) |
| `n:p_rime? v` | `Truthy a => Int -> a` | whether each item is prime |
| `n:f_actors n` | `Int -> Int` | the prime factors of one number, smallest first, with repeats |
| `n:d_ivisors n` | `Int -> Int` | every divisor of one number, in order |
| `b n:b_ase n` | `Int -> Int -> Int` | the digits of one number in base `b`, most significant first |
| `n:d_igits n` | `Int -> Int` | its decimal digits |
| `n:f_ib n` | `Num a => Int -> a` | the first `n` Fibonacci numbers, 1 1 2 3 5 ... |

`n:b_ase` is the inverse of the built-in `d_ecode`: `10 d_ecode n:d_igits
n` is `n`. `n:f_ib` is polymorphic in its result: used as Floats
(`0.0 + n:f_ib 100`) it computes in Floats, past the 64-bit limit.

## Examples

From `../tests/basics.xtl`:

```
      12 n:g_cd 8 9 10 0
4 3 2 12
      n:i_sqrt 15 16 17 1000000
3 4 4 1000
      n:p_rimes 50
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47
      t_ally n:p_rimes 10000
1229
      n:p_rime? 0 1 2 3 4 97 91 7919
0 0 1 1 0 1 0 1
      n:f_actors 360
2 2 2 3 3 5
      n:f_actors 600851475143
71 839 1471 6857
      n:d_ivisors 28
1 2 4 7 14 28
      16 n:b_ase 255
15 15
      n:f_ib 12
1 1 2 3 5 8 13 21 34 55 89 144
```

From `../tests/overflow.xtl`:

```
      -1 t_ake n:f_ib 92
7540113804746346429
      -1 t_ake 0.0 + n:f_ib 100
354224848179262000000.0
      -1 t_ake n:f_ib 93
error[integer-overflow]: integer overflow (use a Float, e.g. 2.0)
```

`../tests/checks.xtl` checks with the Check library: the factors
of 1 to 60 multiply back, factors are prime, gcd times lcm is the
product, the sieve agrees with `n:p_rime?` up to 200, the whole square
root brackets its argument, digits decode back, 28 is perfect,
Fibonacci numbers add.

## Demos

- [`demos/primes.xtl`](../demos/primes.xtl): twin primes, the number of Goldbach pairs of each even number, perfect numbers (`just demo Numbers`).

## Limits

- Whole numbers are 64-bit Ints: a result past about 9.2e18 is
  `error[integer-overflow]` (big integers are ask X6).
- `n:p_rimes` strikes multiples one prime at a time up to the square
  root of `n` (one recursion per prime); `n:f_actors` divides out one
  factor at a time; `n:p_rime?` and `n:g_cd` work item by item with
  `e_ach`. All are fine for numbers up to millions.

## Provenance

| Function | After |
| -------- | ----- |
| `g_cd`, `l_cm` | Euclid; APL's gcd and lcm (the `or` and `and` of numbers in APL2 and Dyalog), dfns `gcd` |
| `p_rimes` | the sieve of Eratosthenes; dfns `sieve` |
| `p_rime?`, `f_actors` | trial division; dfns `factors`, `pco` behavior |
| `d_ivisors` | the residue-table idiom |
| `b_ase`, `d_igits` | APL's encode (`e_ncode`), leading zeros dropped |
| `i_sqrt` | the float root, corrected by one either way |
| `f_ib` | the classic, built by `p_ower` |
