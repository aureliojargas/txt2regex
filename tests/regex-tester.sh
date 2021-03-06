#!/bin/bash
# regex-tester.sh
#
# Txt2regex needs to know regex-related information for each program it
# supports. For example: the list of metacharacters, how to escape a
# metacharacter to match it literally, availability of POSIX character
# classes.
#
# Instead of relying in documentation to get that information, this
# script calls the real programs with specially crafted regexes and
# sample texts, verifying how those programs behave in "real life".
#
# The version information for each program is also extracted, so we can
# have a record of how it behaved in that specific version.
#
# To have a permanent record, the output of this script is also saved to
# this repository. This way we can detect changes in behavior when a
# program version is updated.
#
# To avoid having to install specific software in the developer machine,
# a Docker image is used to isolate all the necessary software and this
# script is run inside that image.
#
# To run this script, use `make test-regex`.

# Run this script in Bash "strict mode"
set -e -u -o pipefail

# Lots of glob-like chars here, let's avoid headaches
set -o noglob

# Set to 1 when debugging
debug=0

# Always prefer the "replace" type when the program supports both
# name, test_type
program_data='
awk             replace
chicken         replace
ed              replace
egrep           match
emacs           replace
expect          match
find            match
gawk            replace
grep            match
javascript      replace
lex             match
mawk            replace
mysql           match
perl            replace
php             replace
postgres        replace
procmail        match
python          replace
sed             replace
tcl             replace
vi              replace
vim             replace
'

# shellcheck disable=SC2016
# txt2regex-id, regex, matches
test_data='
# Tests for metacharacters: . [] ? * + {}
-           ^a.$              ab
-           ^[a]b$            ab
-           ^[^b]b$           ab
# False positive: "b\\?" matches "b" followed by zero "\", so we use "bx\\?"
S2          ^abx?$            ab
S2          ^abx\?$           ab
S2          ^abx\\?$          ab
# False positive: "b\\*" matches "b" followed by zero "\", so we use "bx\\*"
S2          ^abx*$            ab
S2          ^abx\*$           ab
S2          ^abx\\*$          ab
S2          ^ab+$             abb
S2          ^ab\+$            abb
S2          ^ab\\+$           abb
S2          ^ab{1}$           ab
S2          ^ab\{1}$          ab
S2          ^ab\{1\}$         ab
S2          ^ab\\{1\\}$       ab
S2          ^ab{1,}$          abb
S2          ^ab\{1,}$         abb
S2          ^ab\{1,\}$        abb
S2          ^ab\\{1,\\}$      abb
S2          ^ab{1,2}$         abb
S2          ^ab\{1,2}$        abb
S2          ^ab\{1,2\}$       abb
S2          ^ab\\{1,2\\}$     abb

# Tests for ax_*[1,2,3] values: ( ) |
ax123       ^a(b)$            ab
ax123       ^a\(b\)$          ab
ax123       ^a\\(b\\)$        ab
ax123       ^(x|ab)$          ab
ax123       ^\(x\|ab\)$       ab
ax123       ^\\(x\\|ab\\)$    ab

# Test for ax_*[5] values: escaping metacharacters to match them literally
# Avoid \b since it is special in most tools, use \_ instead
ax5         ^a\_$             a\_
ax5         ^a\\_$            a\_
ax5         ^a\\\\_$          a\_
ax5         ^a\.b$            a.b
ax5         ^a\\.b$           a.b
ax5         ^a*b$             a*b
ax5         ^a\*b$            a*b
ax5         ^a\\*b$           a*b
ax5         ^a[b$             a[b
ax5         ^a\[b$            a[b
ax5         ^a\\[b$           a[b
ax5         ^a]b$             a]b
ax5         ^a\]b$            a]b
ax5         ^a\\]b$           a]b
ax5         ^a{b$             a{b
ax5         ^a\{b$            a{b
ax5         ^a\\{b$           a{b
ax5         ^a}b$             a}b
ax5         ^a\}b$            a}b
ax5         ^a\\}b$           a}b
# Extra tests for { and } together, which may give different results
ax5         ^a{5}b$           a{5}b
ax5         ^a\{5\}b$         a{5}b
ax5         ^a\\{5\\}b$       a{5}b
ax5         ^a(b$             a(b
ax5         ^a\(b$            a(b
ax5         ^a\\(b$           a(b
ax5         ^a)b$             a)b
ax5         ^a\)b$            a)b
ax5         ^a\\)b$           a)b
# Grouping because ^a|b matches ^a partially when test_type=match
ax5         ^(a|b)$           (a|b)
ax5         ^\(a\|b\)$        (a|b)
ax5         ^\\(a\\|b\\)$     (a|b)
ax5         ^a+b$             a+b
ax5         ^a\+b$            a+b
ax5         ^a\\+b$           a+b
ax5         ^a?b$             a?b
ax5         ^a\?b$            a?b
ax5         ^a\\?b$           a?b
# Test ^ and $ being in the middle
ax5         ^a^b$             a^b
ax5         ^a\^b$            a^b
ax5         ^a\\^b$           a^b
ax5         ^a$b$             a$b
ax5         ^a\$b$            a$b
ax5         ^a\\$b$           a$b

# Test for ax_*[6] values: must escape \ inside [] to match it literally?
# Avoid \b since it is special in most tools, use \_ instead
ax6         ^a[\]_$           a\_
ax6         ^a[\\]_$          a\_
ax6         ^a[\\\\]_$        a\_

# Test for ax_*[7] values: POSIX support
ax7         ^a[[:alpha:]]$    ab

# Test for ax_*[8] values: \t inside [] matches a tab?
# Note that <tab> will be replaced by a real tab character later
ax8         ^a[\t]b$          a<tab>b
'

escape() { # a\b\c -> a\\b\\c
    printf '%s' "${1//\\/\\\\}"
}

# General tips for writing test_<program> functions
#
# - Avoid creating temporary files.
# - The output must be only one line, even in case of errors.
# - Always use printf, not echo.
# - When test_type=replace, the regex must be replaced by a single "x"
#   and the result is returned as the output.
# - When test_type=match, the original "string" argument should be
#   returned as the output when there's a match.
# - Always use raw strings (think Python's r"...") for the "string"
#   argument so things like "a\t" won't have the "\t" part expanded to a
#   tab, for example.
# - When raw strings are not available, use escape("$2") to make sure
#   the program will get the correct "string" argument. For example,
#   "a\t" will turn into "a\\t", which means "a", "\" and "t".
# - Check the program's most common way of specifying regexes: as a
#   string, as a raw string, inside slashes /.../, etc. The idea here is
#   testing the exact regex that the user will normally type, in the
#   most common way of doing it.
# - Be careful on shell escaping, quoting and expansion. Using stdin is
#   the safest (example: printf ... | program), since the shell will not
#   touch the text coming from stdin. The second preferred form are
#   inline arguments (example: program "..."). In both cases, pay
#   attention to the "string" argument, which may require a call to
#   escape() when there's no raw string support.
# - The worst case is nested inlining, when a tool calls another and the
#   argument may be processed twice. Avoid that, otherwise escape it.
#   No: su -c "psql -A -t -c \"SELECT ...\"" postgres
#   Yes: printf "SELECT ..." | su -c "psql -A -t" postgres

test_awk() { # regex string
    printf '%s\n' "$2" |
        original-awk "{ sub(/$1/, \"x\") ; print }" 2>&1 |
        head -n 1
}

test_chicken() { # regex string
    # No raw strings, this matches: (irregex-replace "a.b" "a\tb" "x")
    printf '(print (irregex-replace "%s" "%s" "x"))' "$1" "$(escape "$2")" |
        csi -quiet -R irregex 2>&1 |
        grep -E '^Error:|^Warning:|^x$' |
        head -n 1
}

test_ed() { # regex string
    # Open empty file, insert the string, replace, print, quit
    printf '%s\n' 0a "$2" . "1s/$1/x/" 1p Q |
        ed -s 2>&1 |
        head -n 1
}

test_emacs() { # regex string
    # No raw strings, this matches: (replace-regexp-in-string "a.b" "x" "a\tb")
    emacs -Q -batch --eval \
        "(message (replace-regexp-in-string \"$1\" \"x\" \"$(escape "$2")\"))"
}

test_expect() { # regex string
    # https://stackoverflow.com/q/37252842/
    printf '%s' "$2" | # Important: no \n here so ab$ will match
        expect -c "expect -re {$1} {puts \$expect_out(0,string)}" 2>&1 |
        head -n 1
}

test_egrep() { # regex string
    printf '%s\n' "$2" | grep -E -o "$1"
}

test_find() { # regex string
    mkdir tmp.find.$$
    cd tmp.find.$$
    touch "$2"
    # It's always a full line (path) match, so add ./ and remove ^ anchor
    find . -regextype posix-extended -regex "^\./${1#^}" 2>&1 |
        sed 's,.*/,,'
    cd ..
    rm -rf tmp.find.$$
}

test_gawk() { # regex string
    printf '%s\n' "$2" |
        gawk "{ sub(/$1/, \"x\") ; print }" 2>&1 |
        head -n 1
}

test_grep() { # regex string
    printf '%s\n' "$2" | grep -o "$1"
}

test_javascript() { # regex string
    node --eval "String.raw\`$2\`.replace(/$1/, 'x')" --print 2>&1 |
        head -n 1
}

# http://matt.might.net/articles/standalone-lexers-with-lex/
test_lex() { # regex string
    {
        # lex commands to just print the matched text
        # Got from: https://en.wikipedia.org/wiki/Lex_(software)
        printf '%s\n' '%{'
        printf '%s\n' '#include <stdio.h>'
        printf '%s\n' '%}'
        printf '%s\n' '%option noyywrap'
        printf '%s\n' '%%'
        printf '%s %s\n' "$1" '{printf("%s\n", yytext);}'
        printf '%s\n' '.|\n {}'
        printf '%s\n' '%%'
        printf '%s\n' 'int main(void){ yylex(); return 0; }'
    } > tmp.lex.$$.l
    {
        flex -o tmp.lex.$$.yy.c tmp.lex.$$.l &&
            gcc -o tmp.lex.$$.run tmp.lex.$$.yy.c &&
            printf '%s\n' "$2" | ./tmp.lex.$$.run
    } 2>&1 | head -n 1
    rm -f tmp.lex.$$.*
}

test_mawk() { # regex string
    printf '%s\n' "$2" |
        mawk "{ sub(/$1/, \"x\") ; print }" 2>&1 |
        head -n 1
}

test_mysql() { # regex string
    local result

    # Using match because replace is only supported in MySQL 8.0+
    # https://stackoverflow.com/a/49925597/
    # Strings are not raw, this matches: SELECT 'a\tb' REGEXP 'a.b'
    result=$(mysql --silent --execute "SELECT '$(escape "$2")' REGEXP '$1'")

    case "$result" in
        1)
            # Matched, show the original string (test_type=match)
            printf '%s\n' "$2"
            ;;
        *)
            printf '%s\n' "$result"
            ;;
    esac
}

test_perl() { # regex string
    printf '%s\n' "$2" | perl -pe "s/$1/x/"
}

test_php() { # regex string
    # Single quotes are not raw in PHP (\' and \\ are special)
    # https://www.php.net/manual/en/language.types.string.php
    printf "<?php echo preg_replace('/%s/', 'x', '%s'); ?>" \
        "$1" "$(escape "$2")" |
        php
}

test_postgres() { # regex string
    # Strings are raw, this matches: SELECT 'a\tb' ~ 'a..b'
    printf "SELECT regexp_replace('%s', '%s', 'x');" "$2" "$1" |
        su -c "psql -A -t" postgres
}

test_procmail() { # regex string
    local result

    {
        printf '%s\n' 'VERBOSE=y'    # show results of regex matching
        printf '%s\n' 'LOGFILE=/etc' # force error, log goes to STDERR
        printf '%s\n' ':0'           # start of a new recipe
        printf '* %s\n' "$1"         # the regex to match
        printf '%s\n' '/dev/null'    # avoid writing any file to disk
    } > tmp.procmail.$$

    # Sample output when the regex is matched:
    #
    # procmail: [20] Mon Apr 13 00:44:48 2020
    # procmail: Assigning "LOGFILE=/etc"
    # procmail: Opening "/etc"
    # procmail: Error while writing to "/etc"
    # procmail: Match on "^a"
    # procmail: Assigning "LASTFOLDER=/dev/null"
    # procmail: Opening "/dev/null"
    #   Folder: /dev/null
    result=$(
        printf '%s\n' "$2" |
            procmail ./tmp.procmail.$$ 2>&1 |
            grep -E '^procmail: (Match|No match|Invalid regexp)' |
            sed 's/^procmail: //' |
            head -n 1
    )

    case "$result" in
        Match*)
            # Matched, show the original string (test_type=match)
            printf '%s\n' "$2"
            ;;
        *)
            printf '%s\n' "$result"
            ;;
    esac

    rm tmp.procmail.$$
}

test_python() { # regex string
    printf '%s\n%s\n%s\n' \
        'import re' \
        "try: print(re.sub(r'$1', 'x', r'$2'))" \
        'except Exception as e: print(e)' | python3
}

test_sed() { # regex string
    printf '%s\n' "$2" | sed -e "s/$1/x/"
}

test_tcl() { # regex string
    # shellcheck disable=SC2016
    printf 'regsub -all {%s} "%s" "x" res; puts $res\n' "$1" "$(escape "$2")" |
        tclsh 2>&1 |
        head -n 1
}

test_vi() { # regex string
    # Open empty file, insert the string, replace, print, quit
    printf '%s\n' 0a "$2" . "1s/$1/x/" 1p q! |
        nvi -e -s |
        head -n 1
}

test_vim() { # regex string
    # Open empty file, insert the string, replace, print, quit
    printf '%s\n' 0a "$2" . "1s/$1/x/" 1p q! |
        vim --clean -n -e -s
}

test_program() {
    local program="$1"
    local test_type="$2"

    local expected
    local regex
    local result
    local string
    local tab=$'\t'

    # Special pre-tests tasks
    case "$program" in
        mysql)
            # https://github.com/moby/moby/issues/34390
            find /var/lib/mysql/mysql -exec touch -c -a {} +
            service mysql start > /dev/null
            ;;
        postgres)
            service postgresql start > /dev/null
            ;;
    esac

    printf '%s\n' "$test_data" | grep -v '^#' | grep . | while read -r id regex string; do
        printf '%-14s%-10s%-20s%-10s' "$program" "$id" "$regex" "$string"

        # Use a real tab character instead of the <tab> marker
        string="${string/<tab>/$tab}"

        case "$test_type" in
            match)
                expected="$string"
                ;;
            replace)
                # The test_* functions that perform replace operations
                # will always replace the matched regex to a single x
                # letter.
                expected="x"
                ;;
            *)
                printf 'test_program(): Unsupported test_type "%s"\n' "$test_type"
                exit 1
                ;;
        esac

        # Run the match test in $program
        case "$program" in
            vi)
                # Cannot redirect stderr when testing vi, otherwise it
                # raises the "inappropriate ioctl for device" error
                result=$("test_$program" "$regex" "$string" || true)
                ;;
            *)
                result=$("test_$program" "$regex" "$string" 2>&1 || true)
                ;;
        esac

        if test "$debug" -eq 1; then
            printf '"%s" = "%s" ' "$result" "$expected"
        fi

        if test "$result" = "$expected"; then
            printf 'OK\n'
        elif test -n "$result"; then
            printf 'FAIL %s\n' "$result"
        else
            printf 'FAIL\n'
        fi
    done

    # Special post-tests tasks
    case "$program" in
        mysql)
            service mysql stop > /dev/null
            ;;
        postgres)
            service postgresql stop > /dev/null
            ;;
    esac
}

show_version() {
    local program="$1"

    case "$program" in
        awk)
            original-awk --version
            ;;
        chicken)
            csi -release | sed 's/^/CHICKEN /'
            ;;
        ed)
            ed --version
            ;;
        egrep)
            grep -E --version
            ;;
        emacs)
            emacs --version | head -n 1
            ;;
        expect)
            expect -v
            ;;
        find)
            # shellcheck disable=SC2185
            find --version
            ;;
        lex)
            flex --version
            ;;
        gawk)
            gawk --version | sed 's/,.*//'
            ;;
        grep)
            grep --version
            ;;
        javascript)
            node --version | sed 's/^/node /'
            ;;
        mawk)
            mawk -W version 2>&1 | grep ^mawk | sed 's/,.*//'
            ;;
        mysql)
            mysql --version | sed 's/,.*//'
            ;;
        perl)
            perl --version | sed '2!d; s/).*//; s/.*(/perl /'
            ;;
        php)
            php -v | sed ' s/ (.*//'
            ;;
        procmail)
            procmail -v
            ;;
        postgres)
            psql --version | sed 's/ (Ubuntu.*//'
            ;;
        python)
            python3 --version
            ;;
        sed)
            sed --version
            ;;
        tcl)
            # shellcheck disable=SC2016
            printf 'puts $tcl_version' | tclsh | sed 's/^/tcl /'
            ;;
        vi)
            dpkg-query --showformat='${Package} ${Version}\n' --show nvi
            ;;
        vim)
            vim --version | sed 's/,.*/)/'
            ;;
        *)
            printf 'show_version(): Unknown program "%s"\n' "$program"
            exit 1
            ;;
    esac 2>&1 | head -n 1
}

main() {
    local program
    local skip=
    local test_type
    local user_program=

    while test $# -gt 0; do
        case "$1" in
            --skip)
                skip="$2"
                shift
                ;;
            *)
                user_program="$1"
                ;;
        esac
        shift
    done

    # Restrict the available programs to the user's choice
    test -n "$user_program" &&
        program_data=$(printf '%s\n' "$program_data" | grep "^$user_program ")

    # Show version and test results for all the available programs
    printf '%s\n' "$program_data" | grep . | while read -r program test_type; do

        test "$program" = "$skip" && continue

        printf '%s version: ' "$program"
        show_version "$program" || true

        test_program "$program" "$test_type"
        printf '%s\n' ----------------------------------------------------------
    done
}

main "$@"
