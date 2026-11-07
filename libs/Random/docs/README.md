# Random

Randomness: shuffles, deals, choices, uniform and normal samples,
weighted picks.

```
"r:" u_se< "Random"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `r:` is the
recommended alias.

The legacy draws below use `r_oll!`, so `xetal run --seed N` (or
`XETAL_SEED`) makes them repeatable; the tests run with `--seed 1`.
Those names end in `!`. The pure counter API below has explicit seeds
and identities and does not depend on effect order.

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

- Dealing more different numbers than there are (`r:d_eal! 5 3`),
  or choosing or sampling from an empty list, stops with a message
  (`error[panic]`; tests `panic-*`) rather than padding with zeros.
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

## Pure counter sampling

The `!` functions retain their effect-order behavior. The following pure
functions use explicit arrays, suitable for identical CPU/GPU sample data.
They do not consume `r_oll!` or depend on its seed or call order. Bits is
an additional dependency for the counter generator's integer XOR.

| Function | Contract |
| -------- | -------- |
| `key r:p_hilox counters` | two-word key and N by 4 counters, all unsigned 32-bit words in Int64 arrays; N by 4 Philox4x32-10 words |
| `seed r:s_ampleKeys identities` | scalar uint32 seed and N by 4 [pixel,sample,interaction,dimension] to N Int output words |
| `seed r:s_amples identities` | same identity to N Float canonical uniform midpoints |
| `r:d_isk square` | finite N by 2 unit-square samples to N by 2 uniform unit-disk coordinates |

Words lie in 0..4294967295. Shapes, ranges and Int types are checked;
seed is scalar, and arrays can be empty. `r:s_ampleKeys` uses Philox key
[seed,0], takes the first output word, and never combines identities by
floating-point arithmetic. Row permutation and chunking preserve words.
The four counter columns are ordered exactly as shown; they are words,
not an endian-dependent byte string. Zero-based pixel/sample IDs are the
rendering convention; each coordinate has its own full uint32 word.

Each of ten rounds multiplies counter words 1 and 3 by 3528531795 and
3449720151, producing high/low uint32 pairs. The next words are
[hi1 XOR c1 XOR k0, lo1, hi0 XOR c3 XOR k1, lo0], with c0..c3 zero-based.
Keys advance by [2654435769,3144134277] modulo 2^32 between rounds.
Products use 16-bit limbs, so every intermediate fits signed Int64;
there is no dependence on signed overflow or host integer width.

The Float conversion is (floor(word/512)+0.5)/8388608, using the high
23 bits. All outputs lie strictly inside (0,1) and are exactly
representable in both binary32 and binary64. Keep Int words when full
32-bit identity/output data is needed. GPU implementations can consume
the canonical arrays directly instead of regenerating them.

The rendering APIs reserve interaction 4294967295 for camera sampling:
dimensions 0/1 are film x/y and 2/3 are lens-disk square u/v. Transport
uses interaction 0..63, dimension 0 for lobe choice, and dimensions
2*j-1/2*j for emitter j (one-based). These domains do not overlap.

Disk sampling uses radius sqrt(u) and angle 2*pi*v, which is uniform in
area rather than radius. Square endpoints 0 and 1 are accepted. Known
axis samples, centered angular moments and mean squared radius 1/2 are
pinned, alongside the published zero/all-ones/pi Philox test vectors.
See the [keyed demo](../demos/keyed.xtl). This is a Monte Carlo sampler,
not a low-discrepancy sequence or a cryptographic interface.

The original arithmetic implementation follows the Philox equations and
known-answer vectors published by
[Random123](https://github.com/DEShawResearch/random123/blob/main/tests/kat_vectors).
No external implementation code is copied.
