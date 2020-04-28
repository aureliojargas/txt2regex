## txt2regex — The console regular expression wizard

![](https://aurelio.net/projects/txt2regex/img/screenshot.png)

- Author: [Aurelio Jargas](https://aurelio.net/about.html)
- License: GPL
- First release: 2001-02-23
- Requires: Bash >= 2.05
- Website: https://aurelio.net/projects/txt2regex/

Txt2regex is a regular expression wizard that converts human sentences
to regexes. In a simple interactive console interface, the user answer
questions and the program builds the regexes for more than 20 programs
like Vim, Emacs, Perl, PHP, Python, Procmail and OpenOffice. It is a
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


## Tested programs versions

All the regexes and rules were extensively tested by hand or by the
`regex-tester.sh` script. When the program couldn't be executed on my
machine, the rules were taken:

- from the program own documentation, or
- from the "Mastering Regular Expressions" O'Reilly book, or
- from the Internet (oh no!)

Programs I've tested here:

- **ed**: GNU ed version 0.2
- **mawk**: mawk 1.3.3 Nov 1996
- **gawk**: GNU Awk 3.0.6
- **grep**: grep (GNU grep) 2.4.2
- **egrep**: egrep (GNU grep) 2.4.2
- **find**: GNU find version 4.1
- **javascript**: netscape-4.77
- **mysql**: Ver 11.13 Distrib 3.23.36
- **ooo**: OpenOffice.org 1.1.0
- **perl**: v5.6.0 built for i386-linux
- **php**: 4.0.6
- **postgres**: psql (PostgreSQL) 7.1.2
- **procmail**: procmail v3.15.1 2001/01/08
- **python**: Python 2.1
- **sed**: GNU sed version 3.02.80
- **tcl**: 8.3
- **vi**: Nvi 1.79 (10/23/96)
- **vim**: VIM - Vi IMproved 5.8 (2001 May 31)


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
