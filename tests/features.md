# Feature tests for txt2regex

This is file is both documentation and a test file, showing how some txt2regex features work in practice, with the command line options required to trigger them and their expected result.

The [clitest](https://github.com/aureliojargas/clitest) tool can identify and run all the commands listed here and check if their actual output matches the expected one. Just run `clitest tests/features.md`.

## Setup

Make sure all the commands use the same Bash version and the same txt2regex file.

```console
$ txt2regex() { bash ./txt2regex.sh "$@"; }
$
```

## User input: Numbers — getNumber()

When informing numbers and non-numbers (`a5!6` in this test) when prompted for a number, the non-numbers are silently removed.

```console
$ txt2regex --prog egrep --history '215¤a5!6'
 Regex egrep: .{56}

$
```

## User input: Rearrange [] special elements — getCharList()

When informing literal characters to be put inside a `[]` list, some special cases have to be handled:

- `^` must not be the first char, otherwise it would mean a negated list
- `-` must not be between two other chars, otherwise it would mean a range.
- `]` must be the very first char, otherwise it would end the list prematurely.
- `[` is not special since the list is already opened, nothing to be done in this case.

```console
$ txt2regex --prog egrep --history '24¤^abc'  # move ^ to the last position
 Regex egrep: [abc^]

$ txt2regex --prog egrep --history '24¤a^bc'  # ^ is not special in the 2nd position
 Regex egrep: [a^bc]

$ txt2regex --prog egrep --history '24¤a-bc'  # move - to the last position
 Regex egrep: [abc-]

$ txt2regex --prog egrep --history '24¤-abc'  # - is not special in the 1st position
 Regex egrep: [-abc]

$ txt2regex --prog egrep --history '24¤a]bc'  # move ] to the 1st position
 Regex egrep: []abc]

$ txt2regex --prog egrep --history '24¤a[bc'  # [ is not special
 Regex egrep: [a[bc]

$ txt2regex --prog egrep --history '24¤^a[b-c]'  # everything together
 Regex egrep: []a[bc^-]

$
```

## User input: Escape \ when inside [] — escCharList()

In some programs, it's required to escape the '\' character when using it inside `[]` lists, making it `\\` or even `\\\\`.

```console
$ txt2regex --all --history '241¤\'
 Regex awk       : [\\]
 Regex chicken   : [\\\\]
 Regex ed        : [\]
 Regex egrep     : [\]
 Regex emacs     : [\\\\]
 Regex expect    : [\\]
 Regex find      : [\]
 Regex gawk      : [\\]
 Regex grep      : [\]
 Regex javascript: [\\]
 Regex lex       : [\\]
 Regex mawk      : [\\]
 Regex mysql     : [\\\\]
 Regex perl      : [\\]
 Regex php       : [\\\\]
 Regex postgres  : [\\\\]
 Regex procmail  : [\]
 Regex python    : [\\]
 Regex sed       : [\]
 Regex tcl       : [\\]
 Regex vi        : [\]
 Regex vim       : [\\]

$
```

## User input: Escape special chars — escChar()

The user has typed `.*+?[]{}()|^$\` as a literal string.

Every metacharacter should be escaped so it will match as a literal character.

```console
$ txt2regex --all --history '23¤.*+?[]{}()|^$\'
 Regex awk       : \.\*\+\?\[]{}\(\)\|\^\$\\
 Regex chicken   : \\.\\*\\+\\?\\[]{}\\(\\)\\|\\^\\$\\\
 Regex ed        : \.\*+?\[]{}()|^$\\
 Regex egrep     : \.\*\+\?\[]\{}\()\|\^\$\\
 Regex emacs     : \\.\\*\\+\\?\\[]{}()|^$\\\
 Regex expect    : \.\*\+\?\[]\{\}\(\)\|\^\$\\
 Regex find      : \.\*\+\?\[]\{}\()\|\^\$\\
 Regex gawk      : \.\*\+\?\[]{}\()\|\^\$\\
 Regex grep      : \.\*+?\[]{}()|^$\\
 Regex javascript: \.\*\+\?\[]{}\(\)\|\^\$\\
 Regex lex       : \.\*\+\?\[]\{\}\(\)\|^$\\
 Regex mawk      : \.\*\+\?\[]{}\(\)\|\^\$\\
 Regex mysql     : \\.\\*\\+\\?\\[]{}\\()\\|\\^\\$\\\
 Regex perl      : \.\*\+\?\[]\{}\(\)\|\^\$\\
 Regex php       : \\.\\*\\+\\?\\[]\\{}\\(\\)\\|\\^\\$\\\
 Regex postgres  : \\.\\*\\+\\?\\[]{}\\(\\)\\|\\^\\$\\\
 Regex procmail  : \.\*\+\?\[]{}\(\)\|\^\$\\
 Regex python    : \.\*\+\?\[]\{}\(\)\|\^\$\\
 Regex sed       : \.\*+?\[]{}()|^$\\
 Regex tcl       : \.\*\+\?\[]\{\}\(\)\|\^\$\\
 Regex vi        : \.\*+?\[]{}()|^$\\
 Regex vim       : \.\*+?\[]{}()|^$\\

$
```

Now try some Bash special chars to make sure nothing will break. Those chars should not be escaped since they are not metacharacters.

```console
$ txt2regex --prog egrep --history '23¤#!&;/`"%>'
 Regex egrep: #!&;/`"%>

$
```

## User input: Use all "special combination" options — getCombo()

Turn on all the options under the "a special combination" menu.

```console
$ txt2regex --prog sed --history '26¤:012345'
 Regex sed: [A-Za-z0-9_ \t]

$
```

## User input: Use all POSIX options — getPosix()

Turn on all the options under the "a POSIX combination (locale aware)" menu.

```console
$ txt2regex --prog egrep --history '27¤:01234567'
 Regex egrep: [[:alpha:][:lower:][:upper:][:digit:][:alnum:][:xdigit:][:blank:][:graph:]]

$
```

## POSIX support — getHasPosix()

If the program does not support POSIX character classes, a `!!` string is shown instead.

```console
$ txt2regex --all --history '27¤:0'
 Regex awk       : [[:alpha:]]
 Regex chicken   : [[:alpha:]]
 Regex ed        : [[:alpha:]]
 Regex egrep     : [[:alpha:]]
 Regex emacs     : [[:alpha:]]
 Regex expect    : [[:alpha:]]
 Regex find      : [[:alpha:]]
 Regex gawk      : [[:alpha:]]
 Regex grep      : [[:alpha:]]
 Regex javascript: !!
 Regex lex       : [[:alpha:]]
 Regex mawk      : !!
 Regex mysql     : [[:alpha:]]
 Regex perl      : [[:alpha:]]
 Regex php       : [[:alpha:]]
 Regex postgres  : [[:alpha:]]
 Regex procmail  : !!
 Regex python    : !!
 Regex sed       : [[:alpha:]]
 Regex tcl       : [[:alpha:]]
 Regex vi        : [[:alpha:]]
 Regex vim       : [[:alpha:]]

$
```

## Tab inside [] — getListTab()

If the program does not support using `\t` inside `[]` lists to represent a tab character, a `<TAB>` string is shown instead.

This is a reminder for the user that this string must be replaced by a literal tab to be able to use the regex.

```console
$ txt2regex --all --history '26¤:5'
 Regex awk       : [\t]
 Regex chicken   : [\t]
 Regex ed        : [<TAB>]
 Regex egrep     : [<TAB>]
 Regex emacs     : [\t]
 Regex expect    : [\t]
 Regex find      : [<TAB>]
 Regex gawk      : [\t]
 Regex grep      : [<TAB>]
 Regex javascript: [\t]
 Regex lex       : [\t]
 Regex mawk      : [\t]
 Regex mysql     : [\t]
 Regex perl      : [\t]
 Regex php       : [\t]
 Regex postgres  : [\t]
 Regex procmail  : [<TAB>]
 Regex python    : [\t]
 Regex sed       : [\t]
 Regex tcl       : [\t]
 Regex vi        : [<TAB>]
 Regex vim       : [\t]

$
```
