# Tags

tags -- names for choices and for the parts of a tagged tuple, written by macros when the program is compiled.

```
"tg:" u_se< "Tags"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the macro library, `Tags.xtlm` (`tg:e_num<`, `tg:p_arts<`); no functions |
| [`docs/`](docs/README.md) | the reference: both macros, what they write, what is checked and when |
| [`demos/`](demos/) | programs that use it: `turtle.xtl`, a heading as a choice and a turtle as a tagged tuple; `scores.xtl`, a table as columns |
| [`tests/`](tests/) | reg-rs baselines: the test programs, their expansions, the macros' types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Tags         # run its demos
just run Tags          # run its test programs
just test-lib Tags     # check every baseline
```
