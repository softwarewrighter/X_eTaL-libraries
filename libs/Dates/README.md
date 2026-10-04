# Dates

dates -- day numbers from calendar dates and back, weekdays, leap years, month lengths, ISO text, month calendars.

```
"d:" u_se< "Dates"
```

| Directory | What |
| --------- | ---- |
| [`src/`](src/) | the library, `Dates.xtl`, and its macro library, `Dates.xtlm` (`d:d_ate<`) |
| [`docs/`](docs/README.md) | the reference: every function, its type, examples, provenance |
| [`demos/`](demos/) | programs that use it: `calendar.xtl`, a month, the Friday-the-13ths of 2026, days since the moon landing |
| [`tests/`](tests/) | reg-rs baselines: the test programs, the pinned export types (`types.rgt`) and the demos (`demo-*.rgt`) |

```bash
just demo Dates         # run its demos
just run Dates          # run its test programs
just test-lib Dates     # check every baseline
```
