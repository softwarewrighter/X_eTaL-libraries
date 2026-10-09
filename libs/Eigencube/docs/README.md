# Eigencube

A Rubik's cube as rotation matrices: each of the 26 cubelets is the
integer point c of {-1, 0, 1}^3 where it sits in the solved cube and
carries a 3-by-3 rotation matrix R, so that it sits now at R c. A
quarter turn picks the cubelets on its side with a dot product
(v . R c > 0 for the face's outward normal v) and multiplies their
matrices by one rotation matrix; the stickers are read back by one
more product (a sticker shows the face it faced when solved, R^T v).
A batch of cubes is one array, n by 26 by 3 by 3, so every turn of
every cube is two matrix products.

```
"ec:" u_se< "Eigencube"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `ec:` is the
recommended alias.

A cube is a batch of one, shape 1 26 3 3 (`ec:solved`); the turning
functions take any batch. Moves are numbered 1 to 12: move 2f-1 turns
face f clockwise as seen facing it, move 2f counterclockwise, the
faces in the order of `ec:faces`, `"UDFBRL"` (up is +z, front +x,
right +y). `ec:n_ame` writes moves in the usual notation and
`ec:p_arse` reads it, so programs that number moves another way meet
this one by name.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `ec:solved` | `Int` | the solved cube: 26 identity matrices, shape 1 26 3 3 |
| `ec:faces` | `Char` | the face letters, `UDFBRL`, in the order of the moves |
| `m ec:t_urn S` | `Int -> Int -> Int` | move m applied to every cube of the batch S |
| `ms ec:d_o S` | `Int -> Int -> Int` | the moves ms applied in order to every cube of S |
| `ec:i_nverse m` | `Int -> Int` | the move that undoes m |
| `ec:s_tickers S` | `Int -> Int` | the cube's colors as 6 by 9: a row per face (U D F B R L), its cells row by row as a cube net shows it, each the face its color belongs on (1 to 6) |
| `ec:s_olved? S` | `Truthy a => Int -> a` | whether every cubelet is solved (a center may be turned about its own axis, which no sticker shows) |
| `hybrid ec:s_olve S` | `Num a => a -> Int -> (Int, Int, Int)` | a solution: the moves, each of the 29 search stages' length, and the endgame's length |
| `ec:n_ame ms` | `Int -> Char` | moves in the usual notation, `U`, `U'`, `D`, ... separated by spaces |
| `ec:p_arse t` | `Char -> Int` | moves read from the usual notation (the inverse of `ec:n_ame`) |

## How it solves

`ec:s_olve` follows eigencube.py's stages: the top and middle layers a
cubelet at a time (17 searches), the bottom edges (8) and the bottom
corners' places (4), each an A* search whose goals and heuristic are
matrix products over sets of cubelets (counts of solved cubelets, and
the sum of square roots of each cubelet's distance from home, the
p-norm with p = 1/2), then eigencube.py's corner twist, (L' U' L U)
twice, for the endgame. The search runs on the cube's 24 rotations and
their Cayley table, made from the matrices once, and on only the
cubelets a stage looks at (each cubelet moves by its own position
alone).

With `hybrid` 1 the middle and bottom stages search over macros
instead of single turns: D turns and the sequences a person solving by
hand knows (an edge inserted into each middle slot, a bottom edge
flip, Sune and its mirror, a corner 3-cycle and its inverse), each
keeping the top layer whole. A scramble then solves in a few seconds.
With `hybrid` 0 every stage searches the twelve turns, eigencube.py's
search alone: correct, but the bottom layer takes minutes to hours,
since its maneuvers break the solved layers for ten moves or more,
which the heuristic cannot see. The solutions are long (a layer
method, and macros joined as they are).

## Examples

From `../tests/basics.xtl`:

```
      ec:n_ame 1 2 9 10 12
U U' R R' L'
      ec:p_arse "F' B L"
6 7 11
      ec:s_tickers ec:solved
1 1 1 1 1 1 1 1 1
2 2 2 2 2 2 2 2 2
3 3 3 3 3 3 3 3 3
4 4 4 4 4 4 4 4 4
5 5 5 5 5 5 5 5 5
6 6 6 6 6 6 6 6 6
```

and, with `x` a scrambled cube, `(ms, lens, e) := 1 ec:s_olve x`
then `ec:s_olved? ms ec:d_o x` is 1.

## Demos

- [`demos/solve.xtl`](../demos/solve.xtl): a random scramble, its
  stickers, a solution and the solved cube.

## Provenance

A port of Steffen Smolka's eigencube.py
([github.com/smolkaj/eigencube](https://github.com/smolkaj/eigencube),
MIT): its model (cubelets as points carrying rotation matrices, turns
by hyperplane dot products), its stages, goals and heuristics, and its
endgame routine, reimplemented in X_eTaL from that program's
documented behavior. The macros for the middle and bottom layers are
the standard beginner's-method sequences, written for this cube's
orientation. First written as the X_eTaL-demos demo `eigencube`.
