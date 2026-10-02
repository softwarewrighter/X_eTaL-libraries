# Sets

Vectors as sets: union, intersection, difference, subset and
equality as sets, and how often each item occurs.

```
"se:" u_se< "Sets"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `se:` is the recommended alias (`s:` is
the usual letter for the standard `Stats`).

A set is a vector of any type with equality: numbers, characters,
boxes (so a list of strings is a set of strings). Results have no
repeats and keep the order in which items are first seen, left
argument first.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `a se:u_nion b` | `Eq a => a -> a -> a` | the items of either |
| `a se:i_ntersect b` | `Eq a => a -> a -> a` | the items of `a` also in `b` |
| `a se:d_ifference b` | `Eq a => a -> a -> a` | the items of `a` not in `b` |
| `a se:s_ymmetric b` | `Eq a => a -> a -> a` | the items in one but not both |
| `a se:s_ubset? b` | `(Eq a, Truthy b) => a -> a -> b` | whether every item of `a` is in `b` |
| `a se:s_ame? b` | `(Eq a, Truthy b) => a -> a -> b` | whether they hold the same items, ignoring order and repeats |
| `a se:d_isjoint? b` | `(Eq a, Truthy b) => a -> a -> b` | whether no item is in both |
| `se:c_ounts v` | `Eq a => a -> Int` | how often each item of `u_nique v` occurs, in that order |
| `se:m_ode v` | `Eq a => a -> a` | the items that occur most often |

The built-ins do the rest: `u_nique v` is the set of a vector's items,
`x m_ember? s` tests membership item by item.

## Examples

From `../tests/basics.xtl`, with `a := 1 2 3 4 2` and
`b := 3 4 5 6`:

```
      a se:u_nion b
1 2 3 4 5 6
      a se:i_ntersect b
3 4
      a se:d_ifference b
1 2
      a se:s_ymmetric b
1 2 5 6
      (3 1 2 1) se:s_ame? 1 2 3
1
      u_nique "mississippi"
misp
      se:c_ounts "mississippi"
1 4 4 2
      se:m_ode "mississippi"
is
```

`../tests/checks.xtl` checks the laws of sets with the Check
library: union commutes and holds both sides, difference and
intersection partition a set, the symmetric difference is the union
minus the intersection, the empty set is a subset of every set, the
counts add up to the length.

## Demos

- [`demos/clubs.xtl`](../demos/clubs.xtl): club memberships: who is in two clubs, in exactly one, everywhere, and how many clubs each (`just demo Sets`).

## Provenance

The APL idioms behind each: union as unique of the catenation,
intersection and difference as membership and compress (Dyalog's
union and intersection functions, dfns' set functions), counts as
the key-and-tally idiom (Dyalog's key operator; X_eTaL has no key
yet). Written for X_eTaL-libraries.
