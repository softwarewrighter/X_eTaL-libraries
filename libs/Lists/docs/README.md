# Lists

List functions: differences, windows, moving means, run lengths,
chunks, shifts, interleaving, binary search, raze.

```
"q:" u_se< "Lists"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `q:` is the
recommended alias.

Counts and sizes go on the left, the list on the right, as for the
built-ins: `3 q:w_indows v`. Most functions work on lists of any type.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `q:d_eltas v` | `Num a => a -> a` | each item minus the one before (one fewer item) |
| `n q:w_indows v` | `Int -> a -> a` | every run of `n` consecutive items, one per row |
| `n q:m_ovingMean v` | `Num a => Int -> a -> Float` | the mean of each window of `n` |
| `q:r_unValues v` | `Eq a => a -> a` | the item of each run of equal items |
| `q:r_unLengths v` | `Eq a => a -> Int` | the length of each run |
| `n q:c_hunks v` | `Int -> a -> Box a` | `v` cut into pieces of `n` (the last may be shorter) |
| `q:r_aze list` | `Box a -> a` | a list of lists joined into one list |
| `n q:s_hift v` | `Int -> a -> a` | `v` moved `n` places toward the front (back for negative `n`), without wrapping, the empty places filled (0 or a space) |
| `a q:i_nterleave b` | `a -> a -> a` | `a1 b1 a2 b2 ...` |
| `v q:b_search x` | `Ord a => a -> a -> Int` | in a sorted list `v`, how many items are at most each item of `x`: where `x` goes, after its equals |

`q:r_unLengths v` replicating `q:r_unValues v` rebuilds `v` (run-length
encoding and decoding). `q:s_hift` is the built-in rotate `o_-` without
the wrap-around.

## Examples

From `../tests/basics.xtl`, with `v := 3 1 4 1 5 9 2 6`:

```
      q:d_eltas v
-2 3 -3 4 4 -7 4
      3 q:w_indows 3 1 4 1 5
3 1 4
1 4 1
4 1 5
      q:r_unValues "aaabccdddd"
abcd
      q:r_unLengths "aaabccdddd"
3 1 2 4
      q:r_aze "ab" "c" "def"
abcdef
      -2 q:s_hift v
0 0 3 1 4 1 5 9
      1 2 3 q:i_nterleave 10 20 30
1 10 2 20 3 30
      10 20 20 30 40 q:b_search 5 10 20 25 40 99
0 1 3 3 5 5
```

`../tests/checks.xtl` checks with the Check library: runs rebuild the
list, the deltas sum to last minus first and a running sum undoes
them, chunks raze back, a window of 1 is the list, binary search
agrees with counting, a shift and its opposite leave fill behind.

## Demos

- [`demos/temperatures.xtl`](../demos/temperatures.xtl): a fortnight
  of temperatures: day-to-day changes, a 3-day moving mean, the
  longest warming streak, a binary search in the sorted readings
  (`just demo Lists`).

## Limits

- `q:r_aze` of an empty list stops with a message (`error[panic]`):
  with no item there is no fill to make an empty result of the right
  type. `q:w_indows` and `q:c_hunks` of a size below 1 stop the same
  way (test `panic-raze`, `panic-window`, `panic-chunk`).
- `q:b_search` searches each item of `x` separately (a recursion per
  halving); for a few lookups that beats counting, for many the
  whole-array count `'{ t_ally w_here v <= _r } e_ach x` is as good.

## Provenance

| Function | After |
| -------- | ----- |
| `d_eltas` | APL's pairwise difference (`2 -/` in Dyalog, reversed), J's `2 -~/\ ` |
| `w_indows`, `m_ovingMean` | APL's n-wise reduce (Dyalog's `n +/`), BQN's windows |
| `r_unValues`, `r_unLengths` | the APL run-length idiom (partition at changes), X_eTaL's classics run-length demo |
| `c_hunks`, `r_aze` | APL2's partition and enlist |
| `s_hift` | Dyalog's shift idioms (overtake after drop) |
| `b_search` | dfns `bsearch` |
| `i_nterleave` | the reshape-and-ravel-by-columns idiom |
