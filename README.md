## txt2regex — Regular expression wizard for the command line

![](https://aurelio.net/projects/txt2regex/img/demo.gif)

- Author: [Aurelio Jargas](https://aurelio.net/about.html)
- License: GPLv2
- First release: 2001-02-23 ([all releases](https://github.com/aureliojargas/txt2regex/releases))
- Requires: Bash >= 3.0
- Website: https://aurelio.net/projects/txt2regex/

Txt2regex is a regular expression wizard for the command line.

Users with little or no knowledge of regular expressions can quickly
create hairy regexes by answering questions in a simple text-based
interactive interface.

Txt2regex is aware of the particular notation and caveats of many
different regular expression flavors, generating valid regexes for more
than 20 targets, including grep, sed, Vim, Emacs, JavaScript, Python,
PHP, PostgreSQL.

Txt2regex is a one-file shell script made 100% with Bash builtin
commands. The only requirement is Bash itself, since no grep, find, sed
or any other system command is used.

See [tests/cmdline.md](tests/cmdline.md) for a list of all the
available command line options and examples on using them.

See [tests/features.md](tests/features.md) for some of the special
features txt2regex has to handle user input and compose proper regexes.


## Running

Txt2regex is a stand-alone Bash script, it doesn't need to be installed.
Just run it:

    bash txt2regex.sh

Making it an executable file, you can run it directly:

    chmod +x txt2regex.sh
    ./txt2regex.sh

If you want it in [another language][pos] besides English:

    make install BINDIR=. LOCALEDIR=po
    LANG=es_ES ./txt2regex


## Supported flavors

```console
$ bash txt2regex.sh --showmeta

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


## Regex tester to gather "real life" data

Txt2regex needs to know regex-related information for each flavor it
supports. For example:

- Which metacharacters are supported?
- How to escape a metacharacter to match it literally?
- Are POSIX character classes supported?

Instead of relying in documentation to get that information, the
[tests/regex-tester.sh](tests/regex-tester.sh) script calls the real
programs with specially crafted regexes and sample texts, verifying how
those programs behave in "real life".

To have a trackable and public record, the output of this tester is also
saved to this repository, in a readable and grepable plain text file:
[tests/regex-tester.txt](tests/regex-tester.txt). Future changes in
behavior can be easily detected.


## Testing

- `make test` — to run all the tests in the current Bash version on your
  machine.

- `make test-bash` — to run all the tests in all the released Bash
  versions since 3.0 (requires Docker).

- `make test-regex` — to run the regex tester (requires Docker).

Check the [Makefile](Makefile) for the details on what gets executed.


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

- To try to make simple regexes less painful for beginners.
- To have a reliable source for the specific regex syntax and rules from
  different flavors.
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
