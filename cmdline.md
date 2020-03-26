# Command line tests for txt2regex

This is file is both documentation and a test file, showing the available command line options for txt2regex and the expected result when using them.

The [clitest](https://github.com/aureliojargas/clitest) tool can identify and run all the commands listed here and check if their actual output matches the expected one. Just run `clitest cmdline.md`.

## Setup

Make sure all the commands use the same Bash version and the same txt2regex file.

```console
$ alias txt2regex="bash ./txt2regex.sh"
$
```

## Options -h, --help

```console
$ txt2regex --help | tee help.txt
usage: txt2regex [ --nocolor | --whitebg ] [ --all | --prog PROGRAMS ]
       txt2regex --showmeta
       txt2regex --showinfo PROGRAM [ --nocolor ]
       txt2regex --history VALUE [ --all | --prog PROGRAMS ]
       txt2regex --make LABEL [ --all | --prog PROGRAMS ]

OPTIONS (they are default OFF):

  --all               Works with all registered programs
  --nocolor           Don't use colors
  --whitebg           Colors adjusted for white background terminals
  --prog PROGRAMS     Choose which programs to use, separated by commas

  --showmeta          Prints a metacharacters table with all programs
  --showinfo PROGRAM  Prints regex info about the specified program
  --history VALUE     Prints a regex from the given history data
  --make LABEL        Prints the default regex for the specified label

  -V, --version       Prints the program version and quit
  -h, --help          Prints the help message and quit

Please read the program Man Page for more information.
$ txt2regex -h > h.txt
$ diff help.txt h.txt
$ rm help.txt h.txt
$
```

## Options -V, --version

```console
$ txt2regex --version
txt2regex v0
$ txt2regex -V
txt2regex v0
$
```

The original code always shows version zero. The real version is set only when using `make install`.

## Option --showmeta

A handy table showing all the metacharacters for all the programs txt2regex knows about. Nice for comparisons or for a quick memory refresh.

```console
$ txt2regex --showmeta

       awk       +       ?               |      ()
        ed      \+      \?    \{\}      \|    \(\)
     egrep       +       ?      {}       |      ()
     emacs       +       ?              \|    \(\)
    expect       +       ?               |      ()
      find       +       ?              \|    \(\)
      gawk       +       ?      {}       |      ()
      grep      \+      \?    \{\}      \|    \(\)
javascript       +       ?      {}       |      ()
       lex       +       ?      {}       |      ()
      lisp       +       ?             \\|  \\(\\)
      mawk       +       ?               |      ()
     mysql       +       ?      {}       |      ()
       ooo       +       ?      {}       |      ()
      perl       +       ?      {}       |      ()
       php       +       ?      {}       |      ()
  postgres       +       ?      {}       |      ()
  procmail       +       ?               |      ()
    python       +       ?      {}       |      ()
       sed      \+      \?    \{\}      \|    \(\)
       tcl       +       ?               |      ()
  vbscript       +       ?      {}       |      ()
        vi   \{1\}  \{01\}    \{\}            \(\)
       vim      \+      \=     \{}      \|    \(\)

NOTE: . [] [^] and * are the same on all programs.

$
```

## Option --showinfo

Shows additional regex-related information about a specific program.

```console
$ txt2regex --showinfo sed --nocolor

   program : sed: GNU sed version 3.02.80
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
 Regex ed        : ^a\+b\{5\}.*
 Regex egrep     : ^a+b{5}.*
 Regex emacs     : ^a+b!!.*
 Regex expect    : ^a+b!!.*
 Regex find      : ^a+b!!.*
 Regex gawk      : ^a+b{5}.*
 Regex grep      : ^a\+b\{5\}.*
 Regex javascript: ^a+b{5}.*
 Regex lex       : ^a+b{5}.*
 Regex lisp      : ^a+b!!.*
 Regex mawk      : ^a+b!!.*
 Regex mysql     : ^a+b{5}.*
 Regex ooo       : ^a+b{5}.*
 Regex perl      : ^a+b{5}.*
 Regex php       : ^a+b{5}.*
 Regex postgres  : ^a+b{5}.*
 Regex procmail  : ^a+b!!.*
 Regex python    : ^a+b{5}.*
 Regex sed       : ^a\+b\{5\}.*
 Regex tcl       : ^a+b!!.*
 Regex vbscript  : ^a+b{5}.*
 Regex vi        : ^a\{1,\}b\{5\}.*
 Regex vim       : ^a\+b\{5}.*

$
```

Stress test using all the available menu options:

```console
$ txt2regex --history '111223445566778(9|9)3¤a¤bc¤de¤fg¤5¤:012345¤6¤:01234567¤7' --prog sed,vim,egrep,python,emacs
 Regex sed   : ^.a\?bc[de]\+[^fg]\{5\}[A-Za-z0-9_ \t]\{1,6\}[[:alpha:][:lower:][:upper:][:digit:][:alnum:][:xdigit:][:blank:][:graph:]]\{7,\}\(.*\|.*\)*
 Regex vim   : ^.a\=bc[de]\+[^fg]\{5}[A-Za-z0-9_ \t]\{1,6}[[:alpha:][:lower:][:upper:][:digit:][:alnum:][:xdigit:][:blank:][:graph:]]\{7,}\(.*\|.*\)*
 Regex egrep : ^.a?bc[de]+[^fg]{5}[A-Za-z0-9_ <TAB>]{1,6}[[:alpha:][:lower:][:upper:][:digit:][:alnum:][:xdigit:][:blank:][:graph:]]{7,}(.*|.*)*
 Regex python: ^.a?bc[de]+[^fg]{5}[A-Za-z0-9_ \t]{1,6}!!{7,}(.*|.*)*
 Regex emacs : ^.a?bc[de]+[^fg]!![A-Za-z0-9_ <TAB>]!!!!!!\(.*\|.*\)*

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
 Regex ed        : [+-]\?[0-9]\+\(\.[0-9]\{2\}\)\?
 Regex egrep     : [+-]?[0-9]+(\.[0-9]{2})?
 Regex emacs     : [+-]?[0-9]+\(\.[0-9]!!\)?
 Regex expect    : [+-]?[0-9]+(\.[0-9]!!)?
 Regex find      : [+-]?[0-9]+\(\.[0-9]!!\)?
 Regex gawk      : [+-]?[0-9]+(\.[0-9]{2})?
 Regex grep      : [+-]\?[0-9]\+\(\.[0-9]\{2\}\)\?
 Regex javascript: [+-]?[0-9]+(\.[0-9]{2})?
 Regex lex       : [+-]?[0-9]+(\.[0-9]{2})?
 Regex lisp      : [+-]?[0-9]+\\(\\.[0-9]!!\\)?
 Regex mawk      : [+-]?[0-9]+(\.[0-9]!!)?
 Regex mysql     : [+-]?[0-9]+(\\.[0-9]{2})?
 Regex ooo       : [+-]?[0-9]+(\.[0-9]{2})?
 Regex perl      : [+-]?[0-9]+(\.[0-9]{2})?
 Regex php       : [+-]?[0-9]+(\.[0-9]{2})?
 Regex postgres  : [+-]?[0-9]+(\\.[0-9]{2})?
 Regex procmail  : [+-]?[0-9]+(\.[0-9]!!)?
 Regex python    : [+-]?[0-9]+(\.[0-9]{2})?
 Regex sed       : [+-]\?[0-9]\+\(\.[0-9]\{2\}\)\?
 Regex tcl       : [+-]?[0-9]+(\.[0-9]!!)?
 Regex vbscript  : [+-]?[0-9]+(\.[0-9]{2})?
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
valid names are: date date2 date3 hour hour2 hour3 number number2 number3
$ txt2regex --make foo
ERROR: --make: "foo": invalid argument
valid names are: date date2 date3 hour hour2 hour3 number number2 number3
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

## On quit, show --history and regex textual description

This is the same stress test used in the previous `--history` test, but this time feeding the commands via STDIN (simulating the user interaction) and checking only the last 3 lines of the final result.

```console
$ user_input='1112a23bc\n4de\n45fg\n55\n6abcdef.66\n7abcdefgh.77\n8(9|9)3..'
$ printf "$user_input" | txt2regex --nocolor | tail -n 3 | sed '1 s/.*txt2/txt2/'
txt2regex --history '111223445566778(9|9)3¤a¤bc¤de¤fg¤5¤:012345¤6¤:01234567¤7'

start to match on the line beginning, followed by any character, repeated one times, followed by a specific character, repeated zero or one times, followed by a literal string {bc}, followed by an allowed characters list, repeated one or more times, followed by a forbidden characters list, repeated exactly 5 times, followed by a special combination {uppercase letters, lowercase letters, numbers, underscore, space, TAB}, repeated up to 6 times, followed by a POSIX combination {letters, lowercase letters, uppercase letters, numbers, letters and numbers, hexadecimal numbers, whitespaces, graphic chars}, repeated at least 7 times, followed by a ready regex {} (, followed by anything |, followed by anything ), repeated zero or more times.
$
```
