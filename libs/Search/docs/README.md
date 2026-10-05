# Search

Searching and ranking: positions in sorted lists, merges, the `k`
largest, ranks with ties, nearest items, order statistics, ranges.

```
"sr:" u_se< "Search"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `sr:` is the
recommended alias. Search imports Lists, whose `q:b_search` is the
binary search (how many items of a sorted list are at most each
value).

Positions count from 1, as everywhere in X_eTaL.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `s sr:p_osition x` | `Ord a => a -> a -> Int` | where each `x` is in the sorted list `s` (its first place), 0 where absent |
| `a sr:m_erge b` | `Ord a => a -> a -> a` | two sorted lists as one sorted list |
| `k sr:t_opAt v` | `Num a => Int -> a -> Int` | the positions of the `k` largest items, largest first |
| `k sr:t_op v` | `Num a => Int -> a -> a` | the `k` largest items, largest first |
| `k sr:k_th v` | `Ord a => Int -> a -> a` | the `k`-th smallest item |
| `sr:r_ank v` | `Ord a => a -> Float` | each item's rank, 1 for the least, ties sharing the mean of their places |
| `sr:d_enseRank v` | `Ord a => a -> Int` | each item's rank among the distinct values |
| `v sr:n_earest x` | `(Num a, Num b) => a -> b -> Int` | for each `x`, the position of the closest item of `v` |
| `range sr:b_etween v` | `(Ord a, Truthy b) => a -> a -> b` | whether each item lies from `lo` to `hi` (`range` is `lo hi`), both included |

Rank the other way (1 for the greatest) by ranking the negated list:
`sr:r_ank n_eg v`.

## Examples

From `../tests/basics.xtl`:

```
      s := 10 20 20 30 40
      s sr:p_osition 20 25 10 40 5
2 0 1 5 0
      3 sr:t_op 5 1 9 7 9 2
9 9 7
      sr:r_ank 10 20 20 30
1.0 2.5 2.5 4.0
      sr:d_enseRank 10 20 20 30
1 2 2 3
      0 10 20 30 sr:n_earest 4 16 26 100
1 3 4 4
```

`../tests/checks.xtl` checks with the Check library, against sorting:
positions find every item, the `k`-th smallest is the sorted `k`-th,
the top three are the last three sorted, ranks sum to `n(n+1)/2`,
dense ranks rise by 0 or 1, a merge is sorted, an item's nearest is
itself.

## Demos

- [`demos/exam.xtl`](../demos/exam.xtl): exam results: the top three,
  ranks with ties, letter grades by binary search among the
  boundaries, the middle band (`just demo Search`).

## Limits

- Asking for more largest items than there are (`sr:t_op`), or a
  k-th smallest outside 1 to the count (`sr:k_th`), stops with a
  message (`error[panic]`; tests `panic-top`, `panic-kth`).
- `sr:r_ank` compares every item with every other (a table), fine for
  lists of a few thousand.
- `sr:p_osition` needs `s` sorted; it is not checked.

## Provenance

| Function | After |
| -------- | ----- |
| `p_osition` | binary search (Lists), APL's interval index (Dyalog's `iota-underbar` behavior) |
| `t_op`, `t_opAt`, `k_th`, `m_erge` | the APL grade idioms |
| `r_ank`, `d_enseRank` | statistics' fractional and dense ranking (R's `rank` with ties averaged, SQL's `DENSE_RANK`) |
| `n_earest`, `b_etween` | whole-array comparisons |
