# Command line tests for txt2regex

This is file is both documentation and a test file, showing the available command line options for txt2regex and the expected result when using them.

The [clitest](https://github.com/aureliojargas/clitest) tool can identify and run all the commands listed here and check if their actual output matches the expected one. Just run `clitest cmdline.md`.

## Setup

Make sure all the commands use the same Bash version and the same txt2regex file.

```console
$ alias txt2regex="bash ./txt2regex.sh"
$
```

## Option --help

```console
$ txt2regex --help
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

  --version           Prints the program version and quit
  --help              Prints the help message and quit

Please read the program Man Page for more information.
$
```

## Option --version

```console
$ txt2regex --version
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
unknown program: 'foo'
$
```

## Option --history

Every time you quit txt2regex, it shows a history string that you can inform to `--history` to replay that same regex again.

```console
$ txt2regex --history '124259¤a¤b¤5'
 RegEx perl    : ^a+b{5}.*
 RegEx php     : ^a+b{5}.*
 RegEx postgres: ^a+b{5}.*
 RegEx python  : ^a+b{5}.*
 RegEx sed     : ^a\+b\{5\}.*
 RegEx vim     : ^a\+b\{5}.*

$
```

Note that you can also inform `--prog` to specify the list of programs (separated by a comma) to appear in the output.

```console
$ txt2regex --history '124259¤a¤b¤5' --prog sed,python,sed
 RegEx sed   : ^a\+b\{5\}.*
 RegEx python: ^a+b{5}.*
 RegEx sed   : ^a\+b\{5\}.*

$
```

Another alternative is using `--all` to show your regex in the syntax of every program txt2regex knows about:

```console
$ txt2regex --history '124259¤a¤b¤5' --all
 RegEx awk       : ^a+b!!.*
 RegEx ed        : ^a\+b\{5\}.*
 RegEx egrep     : ^a+b{5}.*
 RegEx emacs     : ^a+b!!.*
 RegEx expect    : ^a+b!!.*
 RegEx find      : ^a+b!!.*
 RegEx gawk      : ^a+b{5}.*
 RegEx grep      : ^a\+b\{5\}.*
 RegEx javascript: ^a+b{5}.*
 RegEx lex       : ^a+b{5}.*
 RegEx lisp      : ^a+b!!.*
 RegEx mawk      : ^a+b!!.*
 RegEx mysql     : ^a+b{5}.*
 RegEx ooo       : ^a+b{5}.*
 RegEx perl      : ^a+b{5}.*
 RegEx php       : ^a+b{5}.*
 RegEx postgres  : ^a+b{5}.*
 RegEx procmail  : ^a+b!!.*
 RegEx python    : ^a+b{5}.*
 RegEx sed       : ^a\+b\{5\}.*
 RegEx tcl       : ^a+b!!.*
 RegEx vbscript  : ^a+b{5}.*
 RegEx vi        : ^a\{1,\}b\{5\}.*
 RegEx vim       : ^a\+b\{5}.*

$
```

Error handling:

```console
$ txt2regex --history | sed 1q | cut -d : -f 1
usage
$ txt2regex --history invalid --prog sed | sed 's/ $//'
 RegEx sed:

$ txt2regex --history '124259¤a¤b¤5' --prog foo
ERROR: --prog: "foo": invalid argument
$
```

## Option --make

There are some already made regexes that txt2regex can show, use `--make` to inform which one do you want to see.

```console
$ txt2regex --make date

### date LEVEL 1: mm/dd/yyyy: matches from 00/00/0000 to 99/99/9999

 RegEx perl    : [0-9]{2}/[0-9]{2}/[0-9]{4}
 RegEx php     : [0-9]{2}/[0-9]{2}/[0-9]{4}
 RegEx postgres: [0-9]{2}/[0-9]{2}/[0-9]{4}
 RegEx python  : [0-9]{2}/[0-9]{2}/[0-9]{4}
 RegEx sed     : [0-9]\{2\}/[0-9]\{2\}/[0-9]\{4\}
 RegEx vim     : [0-9]\{2}/[0-9]\{2}/[0-9]\{4}

$
```

Adding `--prog` you can specify the exact list of programs to you want to be shown in the output:

```console
$ txt2regex --make date --prog sed,python,sed

### date LEVEL 1: mm/dd/yyyy: matches from 00/00/0000 to 99/99/9999

 RegEx sed   : [0-9]\{2\}/[0-9]\{2\}/[0-9]\{4\}
 RegEx python: [0-9]{2}/[0-9]{2}/[0-9]{4}
 RegEx sed   : [0-9]\{2\}/[0-9]\{2\}/[0-9]\{4\}

$
```

Another alternative is using `--all` to show the regex in the syntax of every program txt2regex knows about:

```console
$ txt2regex --make number2 --all

### number LEVEL 2: level 1 plus optional float point

 RegEx awk       : [+-]?[0-9]+(\.[0-9]!!)?
 RegEx ed        : [+-]\?[0-9]\+\(\.[0-9]\{2\}\)\?
 RegEx egrep     : [+-]?[0-9]+(\.[0-9]{2})?
 RegEx emacs     : [+-]?[0-9]+\(\.[0-9]!!\)?
 RegEx expect    : [+-]?[0-9]+(\.[0-9]!!)?
 RegEx find      : [+-]?[0-9]+\(\.[0-9]!!\)?
 RegEx gawk      : [+-]?[0-9]+(\.[0-9]{2})?
 RegEx grep      : [+-]\?[0-9]\+\(\.[0-9]\{2\}\)\?
 RegEx javascript: [+-]?[0-9]+(\.[0-9]{2})?
 RegEx lex       : [+-]?[0-9]+(\.[0-9]{2})?
 RegEx lisp      : [+-]?[0-9]+\\(\\.[0-9]!!\\)?
 RegEx mawk      : [+-]?[0-9]+(\.[0-9]!!)?
 RegEx mysql     : [+-]?[0-9]+(\\.[0-9]{2})?
 RegEx ooo       : [+-]?[0-9]+(\.[0-9]{2})?
 RegEx perl      : [+-]?[0-9]+(\.[0-9]{2})?
 RegEx php       : [+-]?[0-9]+(\.[0-9]{2})?
 RegEx postgres  : [+-]?[0-9]+(\\.[0-9]{2})?
 RegEx procmail  : [+-]?[0-9]+(\.[0-9]!!)?
 RegEx python    : [+-]?[0-9]+(\.[0-9]{2})?
 RegEx sed       : [+-]\?[0-9]\+\(\.[0-9]\{2\}\)\?
 RegEx tcl       : [+-]?[0-9]+(\.[0-9]!!)?
 RegEx vbscript  : [+-]?[0-9]+(\.[0-9]{2})?
 RegEx vi        : [+-]\{0,1\}[0-9]\{1,\}\(\.[0-9]\{2\}\)\{0,1\}
 RegEx vim       : [+-]\=[0-9]\+\(\.[0-9]\{2}\)\=

$
```

Available regexes to match dates: `date`, `date2` and `date3`:

```console
$ for x in date date2 date3; do txt2regex --make $x --prog python; done

### date LEVEL 1: mm/dd/yyyy: matches from 00/00/0000 to 99/99/9999

 RegEx python: [0-9]{2}/[0-9]{2}/[0-9]{4}


### date LEVEL 2: mm/dd/yyyy: matches from 00/00/1000 to 19/39/2999

 RegEx python: [01][0-9]/[0123][0-9]/[12][0-9]{3}


### date LEVEL 3: mm/dd/yyyy: matches from 00/00/1000 to 12/31/2999

 RegEx python: (0[0-9]|1[012])/(0[0-9]|[12][0-9]|3[01])/[12][0-9]{3}

$
```

Available regexes to match time: `hour`, `hour2` and `hour3`:

```console
$ for x in hour hour2 hour3; do txt2regex --make $x --prog python; done

### hour LEVEL 1: hh:mm: matches from 00:00 to 99:99

 RegEx python: [0-9]{2}:[0-9]{2}


### hour LEVEL 2: hh:mm: matches from 00:00 to 29:59

 RegEx python: [012][0-9]:[012345][0-9]


### hour LEVEL 3: hh:mm: matches from 00:00 to 23:59

 RegEx python: ([01][0-9]|2[0123]):[012345][0-9]

$
```

Available regexes to match numbers: `number`, `number2` and `number3`:

```console
$ for x in number number2 number3; do txt2regex --make $x --prog python; done

### number LEVEL 1: integer, positive and negative

 RegEx python: [+-]?[0-9]+


### number LEVEL 2: level 1 plus optional float point

 RegEx python: [+-]?[0-9]+(\.[0-9]{2})?


### number LEVEL 3: level 2 plus optional commas, like: 34,412,069.90

 RegEx python: [+-]?[0-9]{1,3}(,[0-9]{3})*(\.[0-9]{2})?

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

ERROR: --prog: "foo": invalid argument
$
```
