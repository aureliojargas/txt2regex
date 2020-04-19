# Feature tests for txt2regex

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
  - FIXME: txt2regex currently always move it to end, even if it is not the first char.
- `-` must not be between two other chars, otherwise it would mean a range.
  - FIXME: txt2regex currently always move it to end, even if it is the first char (which is a valid position to be a literal).
- `]` must be the very first char, otherwise it would end the list prematurely.
- `[` shouldn't be a problem anywhere, but txt2regex moves it to the start (or as the second char when `]` is the first).
  - FIXME: This handling can be removed.

```console
$ txt2regex --prog egrep --history '24¤^abc'
 Regex egrep: [abc^]

$ txt2regex --prog egrep --history '24¤a^bc'
 Regex egrep: [abc^]

$ txt2regex --prog egrep --history '24¤a-bc'
 Regex egrep: [abc-]

$ txt2regex --prog egrep --history '24¤-abc'
 Regex egrep: [abc-]

$ txt2regex --prog egrep --history '24¤a]bc'
 Regex egrep: []abc]

$ txt2regex --prog egrep --history '24¤a[bc'
 Regex egrep: [[abc]

$ txt2regex --prog egrep --history '24¤a[]bc'
 Regex egrep: [][abc]

$
```

## User input: Escape \ when inside [] — escCharList()

In some programs, it's required to escape the '\' character when using it inside `[]` lists, making it `\\` or even `\\\\`.

FIXME: This feature is currently broken :(

```console
$ txt2regex --all --history '241¤\'
 Regex awk       : [\]
 Regex ed        : [\]
 Regex egrep     : [\]
 Regex emacs     : [\]
 Regex expect    : [\]
 Regex find      : [\]
 Regex gawk      : [\]
 Regex grep      : [\]
 Regex javascript: [\]
 Regex lex       : [\]
 Regex lisp      : [\]
 Regex mawk      : [\]
 Regex mysql     : [\]
 Regex ooo       : [\]
 Regex perl      : [\]
 Regex php       : [\]
 Regex postgres  : [\]
 Regex procmail  : [\]
 Regex python    : [\]
 Regex sed       : [\]
 Regex tcl       : [\]
 Regex vbscript  : [\]
 Regex vi        : [\]
 Regex vim       : [\]

$
```

## User input: Escape special chars — escChar()

The user has typed `.*+?[]{}()|^$\` as a literal string.

Every metacharacter should be escaped so it will match as a literal character.

```console
$ txt2regex --all --history '23¤.*+?[]{}()|^$\'
 Regex awk       : \.\*\+\?\[]{}\()\|^$\\
 Regex ed        : \.\*+?\[]{}()|^$\\
 Regex egrep     : \.\*\+\?\[]\{}\(\)\|\^\$\\
 Regex emacs     : \.\*\+\?\[]{}()|^$\\
 Regex expect    : \.\*\+\?\[]{}\()\|^$\\
 Regex find      : \.\*\+\?\[]{}()|^$\\
 Regex gawk      : \.\*\+\?\[]{}\()\|\^\$\\
 Regex grep      : \.\*+?\[]{}()|^$\\
 Regex javascript: \.\*\+\?\[]\{}\()\|\^\$\\
 Regex lex       : \.\*\+\?\[]\{}\()\|^$\\
 Regex lisp      : \\.\\*\\+\\?\\[]{}()|^$\\\
 Regex mawk      : \.\*\+\?\[]{}\(\)\|\^\$\\
 Regex mysql     : \\.\\*\\+\\?\\[]{}\\()\\|\\^\\$\\\
 Regex ooo       : \.\*\+\?\[]{}\(\)\|\^\$\\
 Regex perl      : \.\*\+\?\[]{}\(\)\|\^\$\\
 Regex php       : \.\*\+\?\[]\{}\()\|\^\$\\
 Regex postgres  : \\.\\*\\+\\?\\[]{}\\()\\|\\^\\$\\\
 Regex procmail  : \.\*\+\?\[]{}\(\)\|^$\\
 Regex python    : \.\*\+\?\[]\{}\(\)\|\^\$\\
 Regex sed       : \.\*+?\[]{}()|^$\\
 Regex tcl       : \.\*\+\?\[]\{}\(\)\|\^\$\\
 Regex vbscript  : \.\*\+\?\[]\{}\()\|^$\\
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
 Regex awk       : !!
 Regex ed        : [[:alpha:]]
 Regex egrep     : [[:alpha:]]
 Regex emacs     : !!
 Regex expect    : [[:alpha:]]
 Regex find      : !!
 Regex gawk      : [[:alpha:]]
 Regex grep      : [[:alpha:]]
 Regex javascript: !!
 Regex lex       : [[:alpha:]]
 Regex lisp      : !!
 Regex mawk      : !!
 Regex mysql     : [[:alpha:]]
 Regex ooo       : !!
 Regex perl      : [[:alpha:]]
 Regex php       : [[:alpha:]]
 Regex postgres  : [[:alpha:]]
 Regex procmail  : !!
 Regex python    : !!
 Regex sed       : [[:alpha:]]
 Regex tcl       : !!
 Regex vbscript  : [[:alpha:]]
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
 Regex ed        : [<TAB>]
 Regex egrep     : [<TAB>]
 Regex emacs     : [<TAB>]
 Regex expect    : [<TAB>]
 Regex find      : [<TAB>]
 Regex gawk      : [\t]
 Regex grep      : [<TAB>]
 Regex javascript: [\t]
 Regex lex       : [<TAB>]
 Regex lisp      : [<TAB>]
 Regex mawk      : [\t]
 Regex mysql     : [\t]
 Regex ooo       : [<TAB>]
 Regex perl      : [\t]
 Regex php       : [\t]
 Regex postgres  : [\t]
 Regex procmail  : [<TAB>]
 Regex python    : [\t]
 Regex sed       : [\t]
 Regex tcl       : [\t]
 Regex vbscript  : [\t]
 Regex vi        : [<TAB>]
 Regex vim       : [\t]

$
```
