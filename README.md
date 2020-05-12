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

Better yet, make it an executable file, so you can run it directly:

    chmod +x txt2regex.sh
    ./txt2regex.sh

If you want it in another language besides English, use the `make`
command to properly install it in your system:

    make install BINDIR=. LOCALEDIR=po
    ./txt2regex

**Note 1:** Play with `BINDIR`, `LOCALEDIR` and `DESTDIR` variables to
change the default install paths.


## Regex tester to gather "real life" data

Txt2regex needs to know regex-related information for each program it
supports. For example: the list of metacharacters, how to escape a
metacharacter to match it literally and the availability of POSIX
character classes.

Instead of relying in documentation to get that information, the
[tests/regex-tester.sh](tests/regex-tester.sh) script calls the real
programs with specially crafted regexes and sample texts, verifying how
those programs behave in "real life".

To have a trackable and public record, the output of this tester is also
saved to this repository, in a readable and grepable plain text file:
[tests/regex-tester.txt](tests/regex-tester.txt). Future changes in
behavior can be easily detected.


## The current tested versions

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


## Translations maintainers

    ca             Catalan           Carles (ChAoS)
    de_DE          German            Jan Parthey
    en             English           Aurelio Jargas
    es_ES          Spanish           Diego Moya
    fr_FR          French            wwp
    id_ID     Bahasa Indonesian      Muhamad Faizal
    it_IT          Italian           Daniele Pizzolli
    ja            Japanese           Hajime Dei
    pl_PL          Polish            Chris Piechowicz
    pt_BR    Brazilian Portuguese    Aurelio Jargas
    ro_RO         Romanian           Robert Claudiu Gheorghe
    tr             Turkish           erayalakese

A nice way to contribute with the project, is to translate its
messages to your own language. Just get the `po/txt2regex.pot`
file and translate it, on the `msgstr` lines. In doubt, ask.


## FAQ

### Q: Why?

A: To try to make simple regexes less painful for the beginners.

A: To have a reliable source for regexes differences between programs.

A: To have coding fun &:)

### Q: Why bash2?

A: Basically, for me to learn the new bash2 concepts as arrays, i18n
and advanced variable expansion. They rule!

### Q: Why it's not detecting the correct number of lines or columns in my terminal?

A: The program do use the Bash environment variables `$LINES` and
`$COLUMNS` to get the actual screen size. Those **MUST** be exported
variables, or you'll be stuck at the default 80x25 size. Try:

    /bin/bash -c 'echo $COLUMNS $LINES'

If you don't get the screen size, do:

    echo export COLUMNS LINES >> ~/.bash_profile

### Q: Why my bash version is not recognized correctly?

A: The program uses the `$BASH_VERSION`
environment variable, that is available in all Bash versions,
to detect your current version.

If some alien has possessed your machine and your environment
don't have this variable, try to set it by hand. Check with

    echo $BASH_VERSION

If this variable is ok, but `bash --version` returns another
version, check if your Bash is really `/bin/bash`:

    which bash

If it's not `/bin/bash`, you **MUST** change the first line
of the script to your Bash's actual path. For example, if you
have the `bash` binary in your `$HOME`, inside the `bin`
directory, just change the first line of the program to:

    #!/home/YOU/bin/bash

As a last resort, you can always call it with Bash:

    bash ./txt2regex.sh

### Q: What is that `<TAB>` that appears when I choose TAB on the "special combination" menu?

A: Inside lists `[]`, the `<TAB>` string is a visual representation of
a literal tab character, for programs that don't support `[\t]`.

--

The End.
