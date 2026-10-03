# Random

Randomness: shuffles, deals, choices, uniform and normal samples,
weighted picks.

```
"r:" u_se< "Random"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `r:` is the
recommended alias.

Everything is built on the built-in `r_oll!`, so `xetal run --seed N`
(or `XETAL_SEED`) makes a run repeatable; the tests run with `--seed
1`. Every function has an effect, so each name ends in `!`.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `r:s_huffle! v` | `a -> a` | the items of `v` in a random order |
| `k r:d_eal! n` | `Int -> Int -> Int` | `k` different numbers from `1..n`, in random order |
| `r:c_hoice! v` | `a -> a` | one item of `v`, each as likely |
| `k r:s_ample! v` | `Int -> a -> a` | `k` items of `v`, each drawn afresh (with replacement) |
| `r:u_niform! n` | `Int -> Float` | `n` Floats, each as likely anywhere in `[0, 1)` |
| `r:n_ormal! n` | `Int -> Float` | `n` Floats from the standard normal distribution |
| `w r:w_eighted! k` | `Num a => a -> Int -> Int` | `k` positions of `w`, each with probability proportional to its weight |

## Examples

From `../tests/basics.xtl` (with `--seed 1`):

```
      r:s_huffle! r_ange 10
10 2 8 5 7 1 3 4 6 9
      6 r:d_eal! 49
11 5 31 1 48 37
      3 r_eshape r:u_niform! 3
0.511642707 0.233985982 0.308409173
      1 1 8 r:w_eighted! 12
3 3 1 3 3 3 3 1 3 3 3 3
```

`../tests/checks.xtl` checks with the Check library, on 20000 draws:
a shuffle is a permutation, a deal has no repeats and stays in range,
uniform draws lie in `[0, 1)` with mean near 1/2, normal draws have
mean near 0 and variance near 1, and weights 1 2 7 pick the third
about 70% of the time.

## Demos

- [`demos/dice.xtl`](../demos/dice.xtl): two dice thrown 6000 times,
  each total's count beside the expected count and a bar of stars
  (`just demo Random`).

## Limits

- A uniform draw has a resolution of 1e-9 (one `r_oll!` of a billion).
- `r:s_huffle!` sorts random keys from `1..1e9`; a tie (rare) keeps the
  original order of the tied items.
- `r:w_eighted!` counts, for each draw, the cumulative weights at or
  below it: work proportional to draws times weights.

## Provenance

| Function | After |
| -------- | ----- |
| `d_eal!` | APL's deal (`?` dyadic) |
| `s_huffle!` | APL's idiom of grading random numbers |
| `c_hoice!`, `s_ample!` | APL's roll (`?` monadic) used as an index |
| `n_ormal!` | the Box-Muller transform |
| `w_eighted!` | the cumulative-sum and interval-index idiom (Dyalog's interval index) |
| `u_niform!` | BQN's `random` namespace (`Range` behavior) |
