# Equations

Sums as printed in papers: the valid 2-D cross-correlation of a CNN
layer, as array code.

```
"e:" u_se< "Equations"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `e:` is the
recommended alias.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `X e:c_orrelate W` | `Num a => a -> a -> a` | the valid cross-correlation of pictures `X` (channels, height, width) with filters `W` (outputs, channels, kernel height, kernel width): `Y[o,h,w]` is the sum over `c`, `r`, `s` of `X[c,h+r,w+s] * W[o,c,r,s]`, shape outputs, `H - Kh + 1`, `Wd - Kw + 1` |

As CNN layers compute it: no kernel flip (a convolution would turn
the kernel around), stride 1, no padding.

## Examples

From `../tests/oracle.xtl`: all ones, so every output is the number of
products summed, 2 channels times a 2 by 2 kernel:

```
      (2 4 4 r_eshape 1) e:c_orrelate 1 2 2 2 r_eshape 1
8 8 8
8 8 8
8 8 8
```

Two pictures of 1 to 32 and a filter of 1 to 8:

```
      (2 4 4 r_eshape r_ange 32) e:c_orrelate 1 2 2 2 r_eshape r_ange 8
560 596 632
704 740 776
848 884 920
```

## Demos

- [`demos/cnn.xtl`](../demos/cnn.xtl): one CNN layer by hand, two 4
  by 4 channels through one 2 by 2 by 2 filter.

## Provenance

Written for X_eTaL-libraries; the cross-correlation is the textbook
definition used by CNN layers (for example PyTorch's `Conv2d`, which
documents it as cross-correlation). The numbers in the tests were
also checked by a direct four-loop computation outside X_eTaL.
