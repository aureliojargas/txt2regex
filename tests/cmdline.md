# Command line tests for txt2regex

This is file is both documentation and a test file, showing the available command line options for txt2regex and the expected result when using them.

The [clitest](https://github.com/aureliojargas/clitest) tool can identify and run all the commands listed here and check if their actual output matches the expected one. Just run `clitest tests/cmdline.md`.

## Setup

Make sure all the commands use the same Bash version and the same txt2regex file.

```console
$ txt2regex() { bash ./txt2regex.sh "$@"; }
$
```

## Options -h, --help

```console
$ txt2regex --help | tee help.txt
usage: txt2regex [--nocolor|--whitebg] [--all|--prog PROGRAMS]
usage: txt2regex --showmeta
usage: txt2regex --showinfo PROGRAM [--nocolor]
usage: txt2regex --history VALUE [--all|--prog PROGRAMS]
usage: txt2regex --make LABEL [--all|--prog PROGRAMS]

Options:
  --all                 Select all the available programs
  --nocolor             Do not use colors
  --whitebg             Adjust colors for white background terminals
  --prog PROGRAMS       Specify which programs to use, separated by commas

  --showmeta            Print a metacharacters table featuring all the programs
  --showinfo PROGRAM    Print regex-related info about the specified program
  --history VALUE       Print a regex from the given history data
  --make LABEL          Print a ready regex for the specified label

  -V, --version         Print the program version and quit
  -h, --help            Print the help message and quit

$ txt2regex -h > h.txt
$ diff help.txt h.txt
$ rm help.txt h.txt
$
```

## Options -V, --version

```console
$ txt2regex --version
txt2regex 0.10b
$ txt2regex -V
txt2regex 0.10b
$
```

## Option --showmeta

A handy table showing all the metacharacters for all the programs txt2regex knows about. Nice for comparisons or for a quick memory refresh.

```console
$ txt2regex --showmeta

awk             +      ?             |      ()    awk version 20121220
chicken         +      ?     {}      |      ()    CHICKEN 4.12.0
ed             \+     \?   \{\}     \|    \(\)    GNU Ed 1.10
egrep           +      ?     {}      |      ()    grep (GNU grep) 3.1
emacs           +      ? \\{\\}    \\|  \\(\\)    GNU Emacs 25.2.2
expect          +      ?     {}      |      ()    expect version 5.45.4
find            +      ?     {}      |      ()    find (GNU findutils) 4.7.0-git
gawk            +      ?     {}      |      ()    GNU Awk 4.1.4
grep           \+     \?   \{\}     \|    \(\)    grep (GNU grep) 3.1
javascript      +      ?     {}      |      ()    node v8.10.0
lex             +      ?     {}      |      ()    flex 2.6.4
mawk            +      ?             |      ()    mawk 1.3.3 Nov 1996
mysql           +      ?     {}      |      ()    mysql  Ver 14.14 Distrib 5.7.29
perl            +      ?     {}      |      ()    perl v5.26.1
php             +      ?     {}      |      ()    PHP 7.2.24-0ubuntu0.18.04.4
postgres        +      ?     {}      |      ()    psql (PostgreSQL) 10.12
procmail        +      ?             |      ()    procmail v3.23pre 2001/09/13
python          +      ?     {}      |      ()    Python 3.6.9
sed            \+     \?   \{\}     \|    \(\)    sed (GNU sed) 4.4
tcl             +      ?     {}      |      ()    tcl 8.6
vi                         \{\}           \(\)    nvi 1.81.6-13
vim            \+     \=    \{}     \|    \(\)    VIM - Vi IMproved 8.0 (2016 Sep 12)

NOTE: . [] [^] and * are the same on all programs.

$
```

## Option --showinfo

Shows additional regex-related information about a specific program.

```console
$ txt2regex --showinfo sed --nocolor

   program : sed: sed (GNU sed) 4.4
     metas : . [] [^] * \+ \? \{\} \| \(\)
  esc meta : \
  need esc : \.*[
  \t in [] : YES
 [:POSIX:] : YES

$
```

Error handling:

```console
$ txt2regex --showinfo | sed 1q | cut -d : -f 1
usage
$ txt2regex --showinfo foo
ERROR: unknown program: foo
$ txt2regex --showinfo sed,python
ERROR: unknown program: sed,python
$
```

## Option --history

Every time you quit txt2regex, it shows a history string that you can inform to `--history` to replay that same regex again.

```console
$ txt2regex --history '124259¤a¤b¤5'
 Regex python: ^a+b{5}.*
 Regex egrep : ^a+b{5}.*
 Regex grep  : ^a\+b\{5\}.*
 Regex sed   : ^a\+b\{5\}.*
 Regex vim   : ^a\+b\{5}.*
 Regex emacs : ^a+b\\{5\\}.*

$
```

Note that you can also inform `--prog` to specify the list of programs (separated by a comma) to appear in the output.

```console
$ txt2regex --history '124259¤a¤b¤5' --prog sed,python,sed
 Regex sed   : ^a\+b\{5\}.*
 Regex python: ^a+b{5}.*
 Regex sed   : ^a\+b\{5\}.*

$
```

Another alternative is using `--all` to show your regex in the syntax of every program txt2regex knows about:

```console
$ txt2regex --history '124259¤a¤b¤5' --all
 Regex awk       : ^a+b!!.*
 Regex chicken   : ^a+b{5}.*
 Regex ed        : ^a\+b\{5\}.*
 Regex egrep     : ^a+b{5}.*
 Regex emacs     : ^a+b\\{5\\}.*
 Regex expect    : ^a+b{5}.*
 Regex find      : ^a+b{5}.*
 Regex gawk      : ^a+b{5}.*
 Regex grep      : ^a\+b\{5\}.*
 Regex javascript: ^a+b{5}.*
 Regex lex       : ^a+b{5}.*
 Regex mawk      : ^a+b!!.*
 Regex mysql     : ^a+b{5}.*
 Regex perl      : ^a+b{5}.*
 Regex php       : ^a+b{5}.*
 Regex postgres  : ^a+b{5}.*
 Regex procmail  : ^a+b!!.*
 Regex python    : ^a+b{5}.*
 Regex sed       : ^a\+b\{5\}.*
 Regex tcl       : ^a+b{5}.*
 Regex vi        : ^a\{1,\}b\{5\}.*
 Regex vim       : ^a\+b\{5}.*

$
```

Stress test using all the available menu options:

```console
$ txt2regex --history '111223445566778(9|9)3¤a¤bc¤de¤fg¤5¤:012345¤6¤:01234567¤7' --prog sed,vim,egrep,python,procmail
 Regex sed     : ^.a\?bc[de]\+[^fg]\{5\}[A-Za-z0-9_ \t]\{1,6\}[[:alpha:][:lower:][:upper:][:digit:][:alnum:][:xdigit:][:blank:][:graph:]]\{7,\}\(.*\|.*\)*
 Regex vim     : ^.a\=bc[de]\+[^fg]\{5}[A-Za-z0-9_ \t]\{1,6}[[:alpha:][:lower:][:upper:][:digit:][:alnum:][:xdigit:][:blank:][:graph:]]\{7,}\(.*\|.*\)*
 Regex egrep   : ^.a?bc[de]+[^fg]{5}[A-Za-z0-9_ <TAB>]{1,6}[[:alpha:][:lower:][:upper:][:digit:][:alnum:][:xdigit:][:blank:][:graph:]]{7,}(.*|.*)*
 Regex python  : ^.a?bc[de]+[^fg]{5}[A-Za-z0-9_ \t]{1,6}!!{7,}(.*|.*)*
 Regex procmail: ^.a?bc[de]+[^fg]!![A-Za-z0-9_ <TAB>]!!!!!!(.*|.*)*

$
```

Error handling:

```console
$ txt2regex --history | sed 1q | cut -d : -f 1
usage
$ txt2regex --history invalid --prog sed | sed 's/ $//'
 Regex sed:

$ txt2regex --history 2 --prog sed | sed 's/ $//'
 Regex sed:

$ txt2regex --history '1¤unused¤arguments' --prog sed | sed 's/ $//'
 Regex sed: ^

$ txt2regex --history 11 --prog sed | sed 's/ $//'  # missing repetition argument
 Regex sed: ^.

$ txt2regex --history 12 --prog sed | sed 's/ $//'  # missing char argument
 Regex sed: ^

$ txt2regex --history 13 --prog sed | sed 's/ $//'  # missing string argument
 Regex sed: ^

$ txt2regex --history 14 --prog sed | sed 's/ $//'  # missing list string argument
 Regex sed: ^[]

$ txt2regex --history 16 --prog sed | sed 's/ $//'  # missing list choice argument
 Regex sed: ^[]

$ txt2regex --history '16¤:' --prog sed | sed 's/ $//'  # empty list choice argument
 Regex sed: ^[]

$ txt2regex --history '16¤:9' --prog sed | sed 's/ $//'  # out-of-range list choice argument
 Regex sed: ^[]

$ txt2regex --history '124259¤a¤b¤5' --prog foo
ERROR: unknown program: foo
$
```

## Option --make

There are some already made regexes that txt2regex can show, use `--make` to inform which one do you want to see.

```console
$ txt2regex --make date

### date LEVEL 1: mm/dd/yyyy: matches from 00/00/0000 to 99/99/9999

 Regex python: [0-9]{2}/[0-9]{2}/[0-9]{4}
 Regex egrep : [0-9]{2}/[0-9]{2}/[0-9]{4}
 Regex grep  : [0-9]\{2\}/[0-9]\{2\}/[0-9]\{4\}
 Regex sed   : [0-9]\{2\}/[0-9]\{2\}/[0-9]\{4\}
 Regex vim   : [0-9]\{2}/[0-9]\{2}/[0-9]\{4}
 Regex emacs : [0-9]\\{2\\}/[0-9]\\{2\\}/[0-9]\\{4\\}

$
```

Adding `--prog` you can specify the exact list of programs to you want to be shown in the output:

```console
$ txt2regex --make date --prog sed,python,sed

### date LEVEL 1: mm/dd/yyyy: matches from 00/00/0000 to 99/99/9999

 Regex sed   : [0-9]\{2\}/[0-9]\{2\}/[0-9]\{4\}
 Regex python: [0-9]{2}/[0-9]{2}/[0-9]{4}
 Regex sed   : [0-9]\{2\}/[0-9]\{2\}/[0-9]\{4\}

$
```

Another alternative is using `--all` to show the regex in the syntax of every program txt2regex knows about:

```console
$ txt2regex --make number2 --all

### number LEVEL 2: level 1 plus optional float point

 Regex awk       : [+-]?[0-9]+(\.[0-9]!!)?
 Regex chicken   : [+-]?[0-9]+(\\.[0-9]{2})?
 Regex ed        : [+-]\?[0-9]\+\(\.[0-9]\{2\}\)\?
 Regex egrep     : [+-]?[0-9]+(\.[0-9]{2})?
 Regex emacs     : [+-]?[0-9]+\\(\\.[0-9]\\{2\\}\\)?
 Regex expect    : [+-]?[0-9]+(\.[0-9]{2})?
 Regex find      : [+-]?[0-9]+(\.[0-9]{2})?
 Regex gawk      : [+-]?[0-9]+(\.[0-9]{2})?
 Regex grep      : [+-]\?[0-9]\+\(\.[0-9]\{2\}\)\?
 Regex javascript: [+-]?[0-9]+(\.[0-9]{2})?
 Regex lex       : [+-]?[0-9]+(\.[0-9]{2})?
 Regex mawk      : [+-]?[0-9]+(\.[0-9]!!)?
 Regex mysql     : [+-]?[0-9]+(\\.[0-9]{2})?
 Regex perl      : [+-]?[0-9]+(\.[0-9]{2})?
 Regex php       : [+-]?[0-9]+(\\.[0-9]{2})?
 Regex postgres  : [+-]?[0-9]+(\.[0-9]{2})?
 Regex procmail  : [+-]?[0-9]+(\.[0-9]!!)?
 Regex python    : [+-]?[0-9]+(\.[0-9]{2})?
 Regex sed       : [+-]\?[0-9]\+\(\.[0-9]\{2\}\)\?
 Regex tcl       : [+-]?[0-9]+(\.[0-9]{2})?
 Regex vi        : [+-]\{0,1\}[0-9]\{1,\}\(\.[0-9]\{2\}\)\{0,1\}
 Regex vim       : [+-]\=[0-9]\+\(\.[0-9]\{2}\)\=

$
```

Available regexes to match dates: `date`, `date2` and `date3`:

```console
$ for x in date date2 date3; do txt2regex --make $x --prog python; done

### date LEVEL 1: mm/dd/yyyy: matches from 00/00/0000 to 99/99/9999

 Regex python: [0-9]{2}/[0-9]{2}/[0-9]{4}


### date LEVEL 2: mm/dd/yyyy: matches from 00/00/1000 to 19/39/2999

 Regex python: [01][0-9]/[0123][0-9]/[12][0-9]{3}


### date LEVEL 3: mm/dd/yyyy: matches from 00/00/1000 to 12/31/2999

 Regex python: (0[0-9]|1[012])/(0[0-9]|[12][0-9]|3[01])/[12][0-9]{3}

$
```

Available regexes to match time: `hour`, `hour2` and `hour3`:

```console
$ for x in hour hour2 hour3; do txt2regex --make $x --prog python; done

### hour LEVEL 1: hh:mm: matches from 00:00 to 99:99

 Regex python: [0-9]{2}:[0-9]{2}


### hour LEVEL 2: hh:mm: matches from 00:00 to 29:59

 Regex python: [012][0-9]:[012345][0-9]


### hour LEVEL 3: hh:mm: matches from 00:00 to 23:59

 Regex python: ([01][0-9]|2[0123]):[012345][0-9]

$
```

Available regexes to match numbers: `number`, `number2` and `number3`:

```console
$ for x in number number2 number3; do txt2regex --make $x --prog python; done

### number LEVEL 1: integer, positive and negative

 Regex python: [+-]?[0-9]+


### number LEVEL 2: level 1 plus optional float point

 Regex python: [+-]?[0-9]+(\.[0-9]{2})?


### number LEVEL 3: level 2 plus optional commas, like: 34,412,069.90

 Regex python: [+-]?[0-9]{1,3}(,[0-9]{3})*(\.[0-9]{2})?

$
```

Error handling:

```console
$ txt2regex --make
ERROR: --make: "": invalid argument
valid names: date date2 date3 hour hour2 hour3 number number2 number3
$ txt2regex --make foo
ERROR: --make: "foo": invalid argument
valid names: date date2 date3 hour hour2 hour3 number number2 number3
$ txt2regex --make date --prog foo

### date LEVEL 1: mm/dd/yyyy: matches from 00/00/0000 to 99/99/9999

ERROR: unknown program: foo
$
```

## Invalid option

```console
$ txt2regex --foo | head -n 3 | sed '3 s/:.*//'
--foo: invalid option

usage
$
```

## Not enough lines to draw the UI

```console
$ LINES=10 txt2regex --all | tail -n 3 | sed '1s/ [0-9][0-9]* / NN /g'
Your terminal has NN lines, but txt2regex needs at least NN lines.
Increase the number of lines or select less programs using --prog.
If this line number detection is incorrect, export the LINES variable.
$
```

## On quit, show --history and regex textual description

This is the same stress test used in the previous `--history` test, but this time feeding the commands via STDIN (simulating the user interaction) and checking only the last 3 lines of the final result.

```console
$ user_input='1112a23bc\n4de\n45fg\n55\n6abcdef.66\n7abcdefgh.77\n8(9|9)3..'
$ printf "$user_input" | txt2regex --nocolor | tail -n 3 | sed '1 s/.*txt2/txt2/'
txt2regex --history '111223445566778(9|9)3¤a¤bc¤de¤fg¤5¤:012345¤6¤:01234567¤7'

start to match on the line beginning, followed by any character, repeated one times, followed by a specific character, repeated zero or one times, followed by a literal string {bc}, followed by an allowed characters list, repeated one or more times, followed by a forbidden characters list, repeated exactly 5 times, followed by a special combination {uppercase letters, lowercase letters, numbers, underscore, space, TAB}, repeated up to 6 times, followed by a POSIX combination {letters, lowercase letters, uppercase letters, numbers, letters and numbers, hexadecimal numbers, whitespaces, graphic chars}, repeated at least 7 times, followed by a ready regex {} (, followed by anything |, followed by anything ), repeated zero or more times.
$
```
