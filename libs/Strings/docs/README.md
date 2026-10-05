# Strings

Text functions: case, trimming, words, split and join, search,
replace, padding.

```
"t:" u_se< "Strings"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `t:` is the recommended alias.

A string is a Char vector; a list of strings is a nested vector,
`Box Char`, as the strand `"ab" "cde"` is. As with X_eTaL's built-ins,
what controls the function (a pattern, a separator, a width) goes on
the left and the text on the right: `"," t:s_plit "a,b"`. Searching
and splitting work on any vector, not only text: `0 t:s_plit 1 2 0 3`.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `t:u_pper t` | `Char -> Char` | letters to upper case (ASCII letters; others unchanged) |
| `t:l_ower t` | `Char -> Char` | letters to lower case |
| `t:t_rim t` | `Char -> Char` | blanks (space, tab, newline) off both ends |
| `t:t_rimStart t` | `Char -> Char` | blanks off the start |
| `t:t_rimEnd t` | `Char -> Char` | blanks off the end |
| `t:w_ords t` | `Char -> Box Char` | the words, split at runs of blanks |
| `t:s_queeze t` | `Char -> Char` | the words one space apart |
| `sep t:j_oin list` | `Char -> Box Char -> Char` | the strings of a list with `sep` between them |
| `sep t:s_plit t` | `Eq a => a -> a -> Box a` | the pieces between separators of any length; empty pieces kept |
| `t:l_ines t` | `Char -> Box Char` | the lines (a final newline makes no empty line) |
| `p t:f_ind t` | `Eq a => a -> a -> Int` | where the pattern starts, overlaps included |
| `p t:o_ccurrences t` | `Eq a => a -> a -> Int` | how many times it occurs, without overlaps |
| `old new t:r_eplace t` | `Box Char -> Char -> Char` | every `old` replaced by `new`, left to right, without overlaps |
| `p t:p_refix? t` | `(Eq a, Truthy b) => a -> a -> b` | whether `t` begins with `p` |
| `p t:s_uffix? t` | `(Eq a, Truthy b) => a -> a -> b` | whether `t` ends with `p` |
| `p t:i_nfix? t` | `(Eq a, Truthy b) => a -> a -> b` | whether `p` occurs in `t` |
| `n t:p_adLeft t` | `Int -> a -> a` | right-aligned in a field `n` wide |
| `n t:p_adRight t` | `Int -> a -> a` | left-aligned in a field `n` wide |
| `n t:c_enter t` | `Int -> a -> a` | centered in a field `n` wide (extra space on the right) |
| `n t:r_epeat t` | `Int -> a -> a` | `t`, `n` times over |
| `t:m_ix list` | `Box a -> a` | the texts of a list as a character matrix, one per row, padded to the longest (APL2's mix) |

Padding keeps a text longer than the field whole. The old and new
strings of `t:r_eplace` are a strand, so the call reads `"cat" "dog"
t:r_eplace text`.

## Examples

From `../tests/basics.xtl` and `../tests/search.xtl`
(nested results drawn as `xetal --ascii` draws them):

```
      t:u_pper "Hello, World 42"
HELLO, WORLD 42
      "[" c_at (t:t_rim "  two words \t\n") c_at "]"
[two words]
      t:s_queeze "  the quick  brown fox "
the quick brown fox
      "[" c_at (8 t:c_enter "abc") c_at "]"
[  abc   ]
      "ana" t:f_ind "bananas"
2 4
      "ana" t:o_ccurrences "bananas"
1
      "," t:s_plit "a,b,,c"
.>----------------.
| .>. .>. .O. .>. |
| |a| |b| | | |c| |
| '-' '-' '~' '-' |
'e----------------'
      "-" t:j_oin t:w_ords "join these words"
join-these-words
      "cat" "dog" t:r_eplace "the cat saw a cat"
the dog saw a dog
      "aa" "b" t:r_eplace "aaaaa"
bba
      "abcd" t:p_refix? "abc"
0
      0 t:s_plit 1 2 0 3 0 0 4
.>------------------.
| .>--. .>. .O. .>. |
| |1 2| |3| | | |4| |
| '~--' '~' '~' '~' |
'e------------------'
```

The empty piece of a text is drawn with the numbers mark `~`; that is
an X_eTaL display bug (ask X5), not a number in the result.

`../tests/checks.xtl` checks properties with the Check library:
splitting then joining gives the text back, trimming twice is
trimming once, replacing and replacing back is the identity.

## Demos

- [`demos/word-count.xtl`](../demos/word-count.xtl): the five most frequent words of a text, with their counts (`just demo Strings`).

## Limits

- Case covers the ASCII letters only: X_eTaL has no character codes
  yet (`[]U_CS`, ask X4), so the library maps through two alphabet
  strings.
- Every function is whole-array except the non-overlapping scan behind
  `o_ccurrences`, `s_plit` and `r_eplace`, which steps through the
  matches (one recursion per match).

## Provenance

Ported (reimplemented from their documented behavior):

| Function | After |
| -------- | ----- |
| `t_rim`, `t_rimStart`, `t_rimEnd` | J strings addon `dltb`, `dlb`, `dtb`; dfns `dlb`/`dtb` |
| `s_queeze` | J strings addon `deb` |
| `w_ords` | dfns `words`; APL2's partition idiom |
| `s_plit`, `j_oin`, `l_ines` | BQN bqn-libs `strings.bqn` (Split, Join), J `splitstring`, `joinstring` |
| `f_ind`, `o_ccurrences`, `r_eplace` | APL's find (Dyalog's epsilon-underbar); dfns `ss` |
| `p_refix?`, `s_uffix?`, `i_nfix?` | APL idioms (the prefix and suffix as take, match) |
| `u_pper`, `l_ower` | J `toupper`, `tolower`; dfns `case` |
| `p_adLeft`, `p_adRight`, `c_enter`, `r_epeat` | APL overtake and reshape idioms |
| `m_ix` | APL2's disclose of a list (mix), Dyalog's `mix` |
