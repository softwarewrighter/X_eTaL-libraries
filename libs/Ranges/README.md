# Ranges

a list of stepped ranges written as a paper would, each bound to a name: `for i:=0..10 by 2`

```
"rg:" u_se< "Ranges"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the macro library, `Ranges.xtlm` (`rg:f_or<`); no functions |
| [`docs/`](docs/README.md) | the reference: the macro, its grammar, what is checked and when |
| [`demos/`](demos/) | programs that use it: `sampled.xtl`, every third reading of a sensor log |
| [`tests/`](tests/) | reg-rs baselines: the test programs, their expansions, the macro's types (`types.rgt`) and the demos (`demo-*.rgt`); five rejections, one per mistake |

```bash
just demo Ranges         # run its demos
just run Ranges          # run its test programs
just test-lib Ranges     # check every baseline
```

[`libs/Parsing/docs/guide.md`](../Parsing/docs/guide.md) builds this
exact macro step by step, as a worked example of writing a notation
macro with [`libs/Parsing`](../Parsing).
