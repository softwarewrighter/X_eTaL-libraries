# Grouping

Grouping by key: the groups, and counts, sums, means, least and
greatest per key, or any function per key.

```
"gr:" u_se< "Grouping"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `gr:` is the
recommended alias.

Keys and values are lists of one length: item `i` of the values
belongs to key `i`. Keys may be numbers, characters or texts. Every
result has one item per distinct key, in the order of `u_nique keys`
(first seen first), as APL's key operator gives them; X_eTaL has no
key yet (it is on its wish list), so this library is it for now.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `keys gr:g_roups values` | `Eq a => a -> b -> Box b` | the values of each key, a list per key |
| `keys 'f gr:b_y values` | `Eq c => (a -> b) -> c -> a -> b` | `f` applied to each key's values (one number per group) |
| `gr:c_ount keys` | `Eq a => a -> Int` | how many items each key has |
| `keys gr:s_um values` | `(Eq a, Num b) => a -> b -> b` | the sum per key |
| `keys gr:m_ean values` | `(Eq a, Num b) => a -> b -> Float` | the mean per key |
| `keys gr:l_east values` | `(Eq a, Num b) => a -> b -> b` | the least per key |
| `keys gr:g_reatest values` | `(Eq a, Num b) => a -> b -> b` | the greatest per key |

`gr:b_y` takes its function as a quoted operand, like the built-in
`'+ r_/`: `keys '{ t_ally u_nique _r } gr:b_y values` counts the
distinct values per key.

## Examples

From `../tests/basics.xtl`, with `k := "a" "b" "a" "c" "b" "a"` and
`v := 1 2 3 4 5 6`:

```
      gr:c_ount k
3 2 1
      k gr:s_um v
10 7 4
      k gr:m_ean v
3.3333333333333335 3.5 4.0
      k gr:g_reatest v
6 5 4
      "mississippi" gr:s_um 1 + o_ffsets 11
1 26 20 19
```

`../tests/checks.xtl` checks with the Check library: counts add to
the length and sums to the total, the groups hold every value, the
mean is the sum over the count, the least is at most the greatest,
`gr:b_y` with a sum is `gr:s_um`, one key gives the whole.

## Demos

- [`demos/sales.xtl`](../demos/sales.xtl): a month of sales by region:
  a table of counts, totals, averages and best sales (with Format),
  and the totals as bars (with Plot) (`just demo Grouping`).

## Limits

- Each key's group is found by comparing every key with it: work is
  the number of items times the number of distinct keys, fine for
  thousands of items and tens of keys.
- `gr:b_y`'s function gives one number per group (`e_ach`); for a
  list per group use `gr:g_roups` and `m_ap`.

## Provenance

| Function | After |
| -------- | ----- |
| `b_y`, `g_roups`, `c_ount` | Dyalog APL's key operator, BQN's group, J's key (`/.`) |
| `s_um`, `m_ean`, `l_east`, `g_reatest` | SQL's GROUP BY aggregates, as key with a reduce |
