# Graphs

Graphs as adjacency matrices: built from edges, degrees,
reachability, shortest paths, breadth-first levels, connected
components.

```
"g:" u_se< "Graphs"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `g:` is the
recommended alias.

A graph of `n` nodes, numbered 1 to `n`, is an `n` by `n` matrix: item
`i j` is 1 when there is an edge from `i` to `j` (or, for weighted
graphs, the edge's length, 0 meaning none). Walking the graph is
matrix arithmetic: the inner product `m '| '& i_nner m` takes a step
from every node at once, and `d 'm_in '+ i_nner d` finds the shortest
ways through one more node. X_eTaL's transpose `o_\` reverses every
edge.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `n g:a_djacency edges` | `(Num a, Truthy a) => Int -> Int -> a` | the matrix of the edges, given as 2 rows, from over to (directed) |
| `n g:w_eighted edges` | `Int -> Int -> Int` | the matrix of edge lengths, given as 3 rows, from over to over length |
| `g:u_ndirected m` | `(Truthy a, Truthy b) => a -> b` | every edge going both ways |
| `g:o_utDegree m` | `Num a => a -> a` | how many edges leave each node |
| `g:i_nDegree m` | `Num a => a -> a` | how many edges reach each node |
| `g:r_each m` | `(Num a, Truthy b) => a -> b` | item `i j` is 1 when `j` can be reached from `i` by one or more edges |
| `g:s_hortest w` | `Num a => a -> Float` | the shortest path's length from each node to each, -1 where there is none |
| `m g:l_evels s` | `Int -> Int -> Int` | how many edges from node `s` to each node, -1 where unreachable |
| `g:c_omponents m` | `Truthy a => a -> Int` | each node's component (edges taken both ways), numbered in order of their least node |

## Examples

From `../tests/basics.xtl`, a cycle 1 to 2 to 3 to 1, an edge 3 to
4, and node 5 on its own:

```
      m := 5 g:a_djacency 2 4 r_eshape 1 2 3 3 2 3 1 4
      g:o_utDegree m
1 1 2 0 0
      m g:l_evels 1
0 1 2 3 -1
      g:c_omponents m
1 1 1 1 2
      w := 4 4 r_eshape 0 3 8 0 0 0 2 7 0 0 0 1 4 0 0 0
      g:s_hortest w
0.0 3.0 5.0 6.0
7.0 0.0 2.0 3.0
5.0 8.0 0.0 1.0
4.0 7.0 9.0 0.0
```

`../tests/checks.xtl` checks with the Check library, on a ring and a
chain of six: a ring reaches everything, one edge leaves each node,
levels go round the ring, a chain does not reach back, components are
counted, shortest paths with unit lengths are the levels, and the
in-degrees are the out-degrees of the reversed graph.

## Demos

- [`demos/subway.xtl`](../demos/subway.xtl): a subway map of eight
  stations: minutes from the airport to everywhere, stops from the
  centre, and what closing the centre cuts off (`just demo Graphs`).

## Limits

- Matrices are dense: `n` nodes take `n * n` items and each product
  `n ^ 3` work, which suits graphs of tens or hundreds of nodes.
- `g:s_hortest` repeats min-plus products until the lengths settle
  (about `log2 n` of them); lengths are taken as given, so negative
  lengths are not supported.

## Provenance

| Function | After |
| -------- | ----- |
| `r_each` | Warshall's transitive closure, written as Boolean matrix products (the APL idiom `M <- M or M or.and M`), as in X_eTaL's classics |
| `s_hortest` | Floyd-Warshall as repeated min-plus products (APL's `min.+`) |
| `l_evels` | breadth-first search, a whole frontier per step |
| `c_omponents` | reachability of the undirected graph, labelled by the least node |
| `a_djacency`, `w_eighted` | the ravel-index idiom for scattering edges into a matrix |
