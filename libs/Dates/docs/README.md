# Dates

Dates: day numbers from calendar dates and back, weekdays, leap
years, month lengths, ISO text, month calendars.

```
"d:" u_se< "Dates"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `d:` is the
recommended alias. Dates imports Strings.

A date is three numbers, year month day (`2026 10 3`), or a 3-row
matrix of them, one date per column. A day number counts days from
1970-01-01 (day 0), so dates subtract and add as numbers: the days
between two dates are a difference of day numbers. The calendar is
the proleptic Gregorian one, for any year, and every function works
on whole arrays of dates at once.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `d:d_ays ymd` | `Int -> Int` | the day number of each date |
| `d:c_ivil n` | `Int -> Int` | the date of each day number: three numbers for one, a 3-row matrix for several |
| `d:w_eekday n` | `Int -> Int` | the day of the week, 1 Monday to 7 Sunday (ISO 8601) |
| `d:l_eap? y` | `Truthy a => Int -> a` | whether each year is a leap year |
| `y d:d_aysIn m` | `(Num a, Truthy a) => Int -> Int -> a` | the days in month `m` of year `y` |
| `d:i_so n` | `Int -> Box Char` | each day number as ISO text, `2026-10-03` |
| `y d:c_alendar m` | `Int -> Int -> Int` | the month as a 6 by 7 matrix of days, Monday first, 0 where there is no day |
| `y d:m_onth m` | `Int -> Int -> Char` | the month as text: a header and a line per week |

## Examples

From `../tests/basics.xtl`:

```
      d:d_ays 2026 10 3
20729
      d:c_ivil 0 -1 365 11016
1970 1969 1971 2000
   1   12    1    2
   1   31    1   29
      d:w_eekday d:d_ays 2026 10 3
6
      d:l_eap? 1900 2000 2023 2024
0 1 0 1
      (d:d_ays 2026 12 25) - d:d_ays 2026 10 3
83
      2026 d:m_onth 10
Mo Tu We Th Fr Sa Su
          1  2  3  4
 5  6  7  8  9 10 11
12 13 14 15 16 17 18
19 20 21 22 23 24 25
```

`../tests/checks.xtl` checks with the Check library, over every 13th
day from 1570 to 2370 (22476 dates at once): converting to dates and
back is the identity, months run 1 to 12 and days stay within their
month; and 400 years hold 97 leap days and 146097 days, weekdays
cycle, day 0 is 1970-01-01, a calendar holds its month's days.

## Demos

- [`demos/calendar.xtl`](../demos/calendar.xtl): this month's
  calendar, every Friday the 13th of 2026 found at once, the days
  since the first moon landing (`just demo Dates`).

## Macros

`src/Dates.xtlm` beside the functions holds one macro, imported with
them under the same alias. It solves a problem a function cannot:

| Macro | Call | What it does when the program is compiled |
| ----- | ---- | ---------------------------------------- |
| `d:d_ate<` | `@ d:d_ate< "2026-10-03"` | checks the date and writes its day number, `20729`, in place of the call |

A date written as a literal is checked before the program runs: an
impossible one (`"2026-02-30"`) stops the compiler at the call
(`error[bad-date]: 2026-02-30 is not a date of the calendar`) and
nothing runs; a function
parsing the text could only fail when the program reached it. The
program holds the plain number, so nothing parses dates at run time.
`xetal expand` shows it:

```
landing := @ d:d_ate< "1969-07-20"
```

becomes `landing := (-165)`. Nothing goes on its left: `@`. The
macro imports this library's own functions by path (`Dates.xtl`) and
works out the day number with `d_ays`. The demo
[`demos/literals.xtl`](../demos/literals.xtl) uses it (`just demo Dates
literals`, or in the live demo, where Expand shows what it becomes);
`../tests/impossible.xtl` shows the compile-time error.

## Limits

- A month outside 1 to 12 stops with a message (`error[panic]:
  months run 1 to 12, not 13`; test `panic-month`).
- There is no "today": X_eTaL's time stamp `[]TS` is decided but not
  implemented yet (ask X4).
- No time zones or times of day: a date is a whole day.

## Provenance

| Function | After |
| -------- | ----- |
| `d_ays`, `c_ivil` | Howard Hinnant's `days_from_civil` and `civil_from_days` (public domain algorithms), written whole-array |
| `w_eekday`, `l_eap?`, `d_aysIn` | the Gregorian rules |
| `c_alendar`, `m_onth` | APL's `cal`-style month matrix, as Unix `cal` lays it out (Monday first, ISO) |
