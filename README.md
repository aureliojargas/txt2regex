## txt2regex — The console regular expression wizard

![](https://aurelio.net/projects/txt2regex/img/screenshot.png)

- Author: [Aurelio Jargas](https://aurelio.net/about.html)
- License: GPL
- First release: 2001-02-23
- Requires: Bash >= 3.0
- Website: https://aurelio.net/projects/txt2regex/

Txt2regex is a regular expression wizard that converts human sentences
to regexes. In a simple interactive console interface, the user answer
questions and the program builds the regexes for more than 20 programs
like grep, Vim, Emacs, JavaScript, PHP, Python, PostgreSQL. It is a
Shell Script 100% written with Bash builtin commands. No compilation or
extra commands are needed, just download it and run.

See [tests/cmdline.md](tests/cmdline.md) for a complete list of all the
available command line options and examples on using them.


## Install and run

Txt2regex is a stand-alone Bash script, it doesn't need to be installed.
Just run it:

    bash txt2regex.sh

Making it an executable file, you can run it directly:

    chmod +x txt2regex.sh
    ./txt2regex.sh

If you want it in another language besides English, use the `make`
command to properly install it in your system:

    make install BINDIR=. LOCALEDIR=po
    ./txt2regex

> Play with `BINDIR`, `LOCALEDIR` and `DESTDIR` variables to change the
default install paths.


## Regex tester to gather "real life" data

Txt2regex needs to know regex-related information for each program it
supports. For example:

- which metacharacters are supported?
- how to escape a metacharacter to match it literally?
- are POSIX character classes supported?

Instead of relying in documentation to get that information, the
[tests/regex-tester.sh](tests/regex-tester.sh) script calls the real
programs with specially crafted regexes and sample texts, verifying how
those programs behave in "real life".

To have a trackable and public record, the output of this tester is also
saved to this repository, in a readable and grepable plain text file:
[tests/regex-tester.txt](tests/regex-tester.txt). Future changes in
behavior can be easily detected.


## Tested versions

```console
$ grep version: tests/regex-tester.txt | cut -d : -f 2-
 awk version 20121220
 CHICKEN 4.12.0
 GNU Ed 1.10
 grep (GNU grep) 3.1
 GNU Emacs 25.2.2
 expect version 5.45.4
 find (GNU findutils) 4.7.0-git
 GNU Awk 4.1.4
 grep (GNU grep) 3.1
 node v8.10.0
 flex 2.6.4
 mawk 1.3.3 Nov 1996
 mysql  Ver 14.14 Distrib 5.7.29
 perl v5.26.1
 PHP 7.2.24-0ubuntu0.18.04.4
 psql (PostgreSQL) 10.12
 procmail v3.23pre 2001/09/13
 Python 3.6.9
 sed (GNU sed) 4.4
 tcl 8.6
 VIM - Vi IMproved 8.0 (2016 Sep 12)
 nvi 1.81.6-13
$
```


## Translators

    ca       Catalan       Carles (ChAoS)
    de_DE    German        Jan Parthey
    es_ES    Spanish       Diego Moya
    fr_FR    French        wwp
    id_ID    Indonesian    Muhamad Faizal
    it_IT    Italian       Daniele Pizzolli
    ja       Japanese      Hajime Dei
    pl_PL    Polish        Chris Piechowicz
    pt_BR    Portuguese    Aurelio Jargas
    ro_RO    Romanian      Robert Claudiu Gheorghe
    tr       Turkish       erayalakese

To translate txt2regex to your language:

- translate the [po/txt2regex.pot][potfile] file (in the `msgstr` lines)
- save it as `po/XX.po` (where XX is the [two-letter code][iso639] for
  your language)
- submit this new `.po` file in a pull request

Check the [current translations][pos] for reference.

[potfile]: https://github.com/aureliojargas/txt2regex/blob/master/po/txt2regex.pot
[iso639]: https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
[pos]: https://github.com/aureliojargas/txt2regex/tree/master/po


## FAQ

### Why?

- To try to make simple regexes less painful for the beginners.
- To have a reliable source for regexes differences between programs.
- To have coding fun :)

### What is that `<TAB>` that appears in the regex?

That `<TAB>` represents a literal tab character. When using the regex in
the desired external program, remember to change that to a literal tab.
This is required by programs that do not support using `\t` as a
shortcut for the tab character.

### Why my terminal size (lines/columns) is not detected?

Txt2regex uses the environment variables `$LINES` and `$COLUMNS` to get
the current terminal size. Make sure you have them exported, otherwise
the default 80x25 size will be assumed.

To check if the variables are exported, run:

```bash
bash -c 'echo $COLUMNS $LINES'
```

If no numbers are shown in the output, a quick fix is running:

```bash
export COLUMNS LINES
```

As a permanent fix, add the previous `export` command to a Bash
configuration file, such as `~/.bashrc`.
