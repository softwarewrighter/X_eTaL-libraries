# Bits

Bits: binary digits and back, popcount, and, or and xor on whole
numbers, shifts, single bits, Gray codes.

```
"b:" u_se< "Bits"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `b:` is the
recommended alias.

Numbers are whole and at least 0 (up to `2^62`); bit 0 is the lowest.
Every function works on all items at once: the numbers are taken
apart into bits with `e_ncode`, combined with the built-in `&`, `|`
and `!=`, and put back together with `d_ecode`. On vectors of bits
those built-ins are the logic already.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `n b:b_its x` | `Int -> Int -> Int` | the low `n` bits of each number, most significant first: a vector for one, a row per number for several |
| `b:v_alue bits` | `Int -> Int` | the number each row of bits (or the vector) stands for |
| `b:p_opcount x` | `Int -> Int` | how many 1 bits each number has |
| `a b:a_nd b` | `Int -> Int -> Int` | bitwise and, item by item |
| `a b:o_r b` | `Int -> Int -> Int` | bitwise or |
| `a b:x_or b` | `Int -> Int -> Int` | bitwise exclusive or |
| `n b:s_hl x` | `Num a => a -> a -> a` | each number shifted `n` bits left (times `2^n`) |
| `n b:s_hr x` | `Int -> Int -> Int` | each number shifted `n` bits right (the bits shifted out dropped) |
| `i b:b_it? x` | `Truthy a => Int -> Int -> a` | whether bit `i` of each number is 1 |
| `b:m_ask n` | `Num a => a -> a` | the number whose low `n` bits are 1 |
| `b:g_ray x` | `Int -> Int` | the Gray code of each number: neighbours differ in one bit |
| `b:u_ngray g` | `Int -> Int` | the number of each Gray code |

A single number on either side of `b:a_nd`, `b:o_r` and `b:x_or`
goes with every item of the other.

## Examples

From `../tests/basics.xtl`:

```
      8 b:b_its 5
0 0 0 0 0 1 0 1
      b:v_alue 1 0 1 1
11
      b:p_opcount 0 1 7 255 1023
0 1 3 8 10
      12 b:x_or 10
6
      0 1 2 3 b:b_it? 5
1 0 1 0
      b:g_ray o_ffsets 8
0 1 3 2 6 7 5 4
```

`../tests/checks.xtl` checks with the Check library: xor twice is the
identity, and plus or is the sum, xor is or minus and, bits convert
back, a mask's popcount is its width, shifts undo, Gray neighbours
differ in exactly one bit (all 256 of them), Gray codes undo.

## Demos

- [`demos/nim.xtl`](../demos/nim.xtl): the winning move in Nim by the
  xor of the heaps, for every heap at once (`just demo Bits`).

## Limits

- Negative numbers are not supported (no two's complement).
- 63 bits are taken from each number, so the logic works on numbers
  below `2^62`; shifting left past 64 bits overflows (ask X6).

## Provenance

| Function | After |
| -------- | ----- |
| `b_its`, `v_alue`, `p_opcount` | APL's encode and decode in base 2 |
| `a_nd`, `o_r`, `x_or` | Dyalog's bitwise idiom: encode, a Boolean function, decode |
| `g_ray`, `u_ngray` | Frank Gray's reflected binary code; ungray by an xor scan |
