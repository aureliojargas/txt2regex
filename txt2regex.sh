#!/bin/bash
# txt2regex.sh - Regular Expressions "wizard", all in bash2 builtins
#
# Website : https://aurelio.net/projects/txt2regex/
# Author  : Aurelio Jargas (verde@aurelio.net)
# License : GPL
# Requires: bash >= 2.05
#
# shellcheck disable=SC1117,SC1003,SC2034
#   SC1117 because it was obsoleted in shellcheck >0.5
#   SC1003 because it gets crazy when defining arrays (i.e. ax_sed)
#   SC2034 because it considers unused vars that I load with eval (ax_*)
#
# Please, read the README file.
#
# $STATUS:
#   0  beginning of the regex
#   1  defining regex
#   12 choosing subregex
#   2  defining quantifier
#   3  really quit?
#   4  choosing session programs
#   9  end of the regex
#
# 20001019 ** 1st version
# 20001026 ++ lots of changes and tests
# 20001028 ++ improvements, public release
# 20001107 ++ bash version check (thanks eliphas)
# 20001113 ++ php support, Progs command
# 20010223 ++ i18n, --all, freshmeat announce (oh no!)
# 20010223 v0.1
# 20010420 ++ id.po, \lfunction_name, s/regexp/regex/ig
# 20010423 ++ --nocolor, --history, Usage(), doNextHist{,Args}()
#          ++ flags: interactive, color, allprogs
#          ++ .oO(¤user parameters history)
# 20010424 v0.2
# 20010606 ++ option --whitebg
#          -- grep from $progs to fit on 24 lines by default
# 20010608 -- clear command (not bash), ++ Clear()
#          -- stty command (not bash), ++ $LINES
#          -- *Progs*(), ++ Choice(), ChoiceRefresh()
#          ++ POSIX character classes [[:abc:]]
#          ++ special combinations inside []
#          ++ $HUMAN improved with getString, getNumber, Choice
#          ++ detailed --help, moved to sourceforge
# 20010613 v0.3
# 20010620 -- seq command (not bash), ++ sek()
# 20010613 v0.3.1
# 20010731 ++ Reset: "RegEx prog  :" with automatic length
#          ++ new progs: postgres, javascript, vbscript, procmail
#          ++ ax_prog: new item: escape char - escape is ok now
#          ++ improved meta knowledge on perl, tcl and gawk
# 20010802 v0.4
# 20010821 ++ ShowMeta(), new option: --showmeta
# 20010824 ++ getMeta(), ShowInfo(), new option: --showinfo, $cR color
# 20010828 ++ getItemIndex(), getLargestItem()
#          <> Clear(): using \033c, ALL: using for((;;)) ksh syntax
#          <> vi == Nvi
# 20010828 v0.5
# 20010831 ++ group & or support- cool!, clearN()
#          ++ nice groups balance check -> ((2)), use $COLUMNS
#          <> TopTitle(): BLOAT, 3 lines, smart, arrays
#          <> Menu(): s/stupid recursion/while/
#          ++ Z status to handle 0,menu,0 situation
#          <> s/eval/${!var}/
# 20010903 <> Choice: fixed outrange answers
#          ++ trapping ^c do clearEnd, ++ new prog: mysql
#          ++ history now works with Choice() menus
#          ++ history appears when quitting
# 20010905 v0.6
# 20020225 ++ "really quit?" message, ++ --version
# 20020304 <> --history just shows final RE on STDOUT
#          ++ --make, --prog, printError()
#          ++ groups are now quantifiable
#          ++ ready_(date[123], hour[123], number[123])
# 20020304 v0.7
# 20040928 <> bash version test (works in 3.x and newer)
# 20040928 v0.8
# 20040929 <> --help split into individual messages (helps i18n)
# 20051229 <> fixed bug on bash3 for eval contents (thanks Marcus Habermehl)
# 20121221 ** moved to GitHub, please see the Git history from now on

# Every command in this script is a Bash builtin. This is by design.
# Make sure we don't break that rule in future code by strictly
# disallowing any system command.
export PATH=

TEXTDOMAIN=txt2regex
TEXTDOMAINDIR=po
VERSION=0

printError(){
    printf '%s: ' $"ERROR"
    # shellcheck disable=SC2059
    printf "$@"
    exit 1
}

case "$BASH_VERSION" in
    2.0[5-9]*|2.[1-9]*|[3-9].*)
        :  # do nothing
    ;;
    *)
        printError 'Bash version >=2.05 required, but you have %s\n' "$BASH_VERSION"
    ;;
esac

Usage(){
    # Ugly code, but isolates in $"..." only the strings that need
    # translation and tries to keep the option descriptions aligned even
    # when long words are used as meta vars.
    printf '%s txt2regex [--nocolor|--whitebg] [--all|--prog %s]\n' \
                $"usage:" $"PROGRAMS"
    printf '%s txt2regex --showmeta\n' \
                $"usage:"
    printf '%s txt2regex --showinfo %s [--nocolor]\n' \
                $"usage:" $"PROGRAM"
    printf '%s txt2regex --history %s [--all|--prog %s]\n' \
                $"usage:" $"VALUE" $"PROGRAMS"
    printf '%s txt2regex --make %s [--all|--prog %s]\n' \
                $"usage:" $"LABEL" $"PROGRAMS"
    printf '\n'
    printf '%s\n' $"Options:"
    printf '  %-22s%s\n' '--all' \
                        $"Select all the available programs"
    printf '  %-22s%s\n' '--nocolor' \
                        $"Do not use colors"
    printf '  %-22s%s\n' '--whitebg' \
                        $"Adjust colors for white background terminals"
    printf '  %-22s%s\n' '--prog '$"PROGRAMS" \
                        $"Specify which programs to use, separated by commas"
    printf '\n'
    printf '  %-22s%s\n' '--showmeta' \
                        $"Print a metacharacters table featuring all the programs"
    printf '  %-22s%s\n' '--showinfo '$"PROGRAM" \
                        $"Print regex-related info about the specified program"
    printf '  %-22s%s\n' '--history '$"VALUE" \
                        $"Print a regex from the given history data"
    printf '  %-22s%s\n' '--make '$"LABEL" \
                        $"Print a ready regex for the specified label"
    printf '\n'
    printf '  %-22s%s\n' '-V, --version' \
                        $"Print the program version and quit"
    printf '  %-22s%s\n' '-h, --help' \
                        $"Print the help message and quit"
    printf '\n'
    exit "${1:-0}"  # $1 is the exit code (default is 0)
}

# The defaults
is_interactive=1
use_colors=1
has_white_background=0
has_not_supported=0
mode_show_meta=0
mode_show_info=0
GRP1=0
GRP2=0


# Here's the default list of programs shown.
# Edit here or use --prog to overwrite it.
progs=(python egrep grep sed vim)


### IMPORTANT DATA ###
allprogs=(
    awk
    ed
    egrep
    emacs
    expect
    find
    gawk
    grep
    javascript
    lex
    lisp
    mawk
    mysql
    ooo
    perl
    php
    postgres
    procmail
    python
    sed
    tcl
    vbscript
    vi
    vim
)
allversions=(
    ''  # awk
    'GNU ed version 0.2'
    'egrep (GNU grep) 2.4.2'
    ''  # emacs
    ''  # expect
    'GNU find version 4.1'
    'GNU Awk 3.0.6'
    'grep (GNU grep) 2.4.2'
    'netscape-4.77'  #javascript
    ''  # lex
    ''  #lisp
    'mawk 1.3.3 Nov 1996'
    'Ver 11.13 Distrib 3.23.36'  # mysql
    'OpenOffice.org 1.1.0'
    'v5.6.0 built for i386-linux'  # perl
    '4.0.6'  # php
    'psql (PostgreSQL) 7.1.2'
    'procmail v3.15.1 2001/01/08'
    'Python 2.1'
    'GNU sed version 3.02.80'
    '8.3'  # tcl
    ''  # vbscript
    'Nvi 1.79 (10/23/96)'
    'VIM - Vi IMproved 5.8 (2001 May 31)'
)

label_names=(
    date
    date2
    date3

    hour
    hour2
    hour3

    number
    number2
    number3
)
label_descriptions=(
    'date LEVEL 1: mm/dd/yyyy: matches from 00/00/0000 to 99/99/9999'
    'date LEVEL 2: mm/dd/yyyy: matches from 00/00/1000 to 19/39/2999'
    'date LEVEL 3: mm/dd/yyyy: matches from 00/00/1000 to 12/31/2999'

    'hour LEVEL 1: hh:mm: matches from 00:00 to 99:99'
    'hour LEVEL 2: hh:mm: matches from 00:00 to 29:59'
    'hour LEVEL 3: hh:mm: matches from 00:00 to 23:59'

    'number LEVEL 1: integer, positive and negative'
    'number LEVEL 2: level 1 plus optional float point'
    'number LEVEL 3: level 2 plus optional commas, like: 34,412,069.90'
)
label_data=(
    # date
    '26521652165¤:2¤2¤/¤:2¤2¤/¤:2¤4'
    '24161214161214165¤01¤:2¤/¤0123¤:2¤/¤12¤:2¤3'
    '2(2161|2141)121(2161|4161|2141)1214165¤0¤:2¤1¤012¤/¤0¤:2¤12¤:2¤3¤01¤/¤12¤:2¤3'
    # hour
    '2652165¤:2¤2¤:¤:2¤2'
    '24161214161¤012¤:2¤:¤012345¤:2'
    '2(4161|2141)1214161¤01¤:2¤2¤0123¤:¤012345¤:2'
    # number
    '24264¤-+¤:2'
    '24264(2165)2¤-+¤:2¤.¤:2¤2'
    '24266(2165)3(2165)2¤-+¤:2¤3¤,¤:2¤3¤.¤:2¤2'
)
#date3  : perl: (0[0-9]|1[012])/(0[0-9]|[12][0-9]|3[01])/[12][0-9]{3}
#hour3  : perl: ([01][0-9]|2[0123]):[012345][0-9]
#number3: perl: [+-]?[0-9]{1,3}(,[0-9]{3})*(\.[0-9]{2})?
### -- ###

getItemIndex(){  # array tool
    local i=0 item="$1"
    shift
    while [ -n "$1" ]
    do
        [ "$1" == "$item" ] && printf '%d\n' "$i" && return
        i=$((i + 1))
        shift
    done
}

validateProgramNames(){
    local name
    for name in "$@"
    do
        [ -z "$(getItemIndex "$name" "${allprogs[@]}")" ] &&
            printError '%s: %s\n' $"unknown program" "$name"
    done
}

# Parse command line options
while [ $# -gt 0 ]
do
    case "$1" in
        --history)
            [ -z "$2" ] && Usage 1
            history="$2"
            shift
            is_interactive=0
            use_colors=0

            hists="0${history%%¤*}"
            histargs="¤${history#*¤}"
            [ "${hists#0}" == "${histargs#¤}" ] && unset histargs
        ;;
        --make)
            shift
            is_interactive=0
            use_colors=0
            label_name="${1%1}"  # final 1 is optional (date1 == date)
            label_index=$(getItemIndex "$label_name" "${label_names[@]}")

            # Sanity check
            [ -z "$label_index" ] &&
                printError '%s: "%s": %s\n%s %s\n' \
                    '--make' "$1" $"invalid argument" \
                    $"valid names:" "${label_names[*]}"

            # Set history data
            hist="${label_data[$label_index]}"
            hists="0${hist%%¤*}"
            histargs="¤${hist#*¤}"

            printf '\n### %s\n\n' "${label_descriptions[$label_index]}"
        ;;
        --prog)
            [ -z "$2" ] && Usage 1
            shift
            eval "progs=(${1//,/ })"
            validateProgramNames "${progs[@]}"
        ;;
        --nocolor)
            use_colors=0
        ;;
        --whitebg)
            has_white_background=1
        ;;
        --showmeta)
            mode_show_meta=1
        ;;
        --showinfo)
            [ -z "$2" ] && Usage 1
            infoprog="$2"
            shift
            mode_show_info=1
            validateProgramNames "$infoprog"
        ;;
        --all)
            progs=("${allprogs[@]}")
        ;;
        -V | --version)
            printf 'txt2regex v%s\n' "$VERSION"
            exit 0
        ;;
        -h | --help)
            Usage 0
        ;;
        *)
            printf '%s: %s\n\n' "$1" $"invalid option"
            Usage 1
        ;;
    esac
    shift
done

set -o noglob


### The Regex show

S0_txt=(
    $"start to match"
    $"on the line beginning"
    $"in any part of the line"
)
S0_re=(
    ''
    '^'
    ''
)

S1_txt=(
    $"followed by"
    $"any character"
    $"a specific character"
    $"a literal string"
    $"an allowed characters list"
    $"a forbidden characters list"
    $"a special combination"
    $"a POSIX combination (locale aware)"
    $"a ready regex (not implemented)"
    $"anything"
)
S1_re=(
    ''
    '.'
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    '.*'
)

S2_txt=(
    $"how many times (repetition)"
    $"one"
    $"zero or one (optional)"
    $"zero or more"
    $"one or more"
    $"exactly N"
    $"up to N"
    $"at least N"
)

# COMBO
combo_txt=(
    $"uppercase letters"
    $"lowercase letters"
    $"numbers"
    $"underscore"
    $"space"
    $"TAB"
)
combo_re=(
    'A-Z'
    'a-z'
    '0-9'
    '_'
    ' '
    '@'
)

#TODO use all posix components?
posix_txt=(
    $"letters"
    $"lowercase letters"
    $"uppercase letters"
    $"numbers"
    $"letters and numbers"
    $"hexadecimal numbers"
    $"whitespaces (space and TAB)"
    $"graphic chars (not-whitespace)"
)
posix_re=(
    'alpha'
    'lower'
    'upper'
    'digit'
    'alnum'
    'xdigit'
    'blank'
    'graph'
)

# Title (line 1)
tit1_txt=(
    $"quit"
    $"reset"
    $"color"
    $"programs"
    ''
    ''
    ''
    ''
    ''
    '^txt2regex$'
)
tit1_cmd=(
    '.'
    '0'
    '*'
    '/'
    ''
    ''
    ''
    ''
    ''
    ''
)

# Title (line 2-3)
tit2_txt=(
    $"or"
    $"open group"
    $"close group"
    ''
    ''
    ''
    ''
    ''
    ''
    $"not supported"
)
tit2_cmd=(
    '|'
    '('
    ')'
    ''
    ''
    ''
    ''
    ''
    ''
    '!!'
)

# Here's all the quantifiers
S2_sed=(       '' '' '\?' '*' '\+' '\{@\}' '\{1,@\}' '\{@,\}')
S2_ed=(        '' '' '\?' '*' '\+' '\{@\}' '\{1,@\}' '\{@,\}')
S2_grep=(      '' '' '\?' '*' '\+' '\{@\}' '\{1,@\}' '\{@,\}')
S2_vim=(       '' '' '\=' '*' '\+' '\{@}'  '\{1,@}'  '\{@,}' )
S2_egrep=(     '' ''  '?' '*'  '+'  '{@}'   '{1,@}'   '{@,}' )
S2_php=(       '' ''  '?' '*'  '+'  '{@}'   '{1,@}'   '{@,}' )
S2_python=(    '' ''  '?' '*'  '+'  '{@}'   '{1,@}'   '{@,}' )
S2_lex=(       '' ''  '?' '*'  '+'  '{@}'   '{1,@}'   '{@,}' )
S2_perl=(      '' ''  '?' '*'  '+'  '{@}'   '{1,@}'   '{@,}' )
S2_postgres=(  '' ''  '?' '*'  '+'  '{@}'   '{1,@}'   '{@,}' )
S2_javascript=('' ''  '?' '*'  '+'  '{@}'   '{1,@}'   '{@,}' )
S2_vbscript=(  '' ''  '?' '*'  '+'  '{@}'   '{1,@}'   '{@,}' )
S2_gawk=(      '' ''  '?' '*'  '+'  '{@}'   '{1,@}'   '{@,}' )
S2_mysql=(     '' ''  '?' '*'  '+'  '{@}'   '{1,@}'   '{@,}' )
S2_ooo=(       '' ''  '?' '*'  '+'  '{@}'   '{1,@}'   '{@,}' )
S2_procmail=(  '' ''  '?' '*'  '+'  '!!'    '!!'      '!!'   )
S2_mawk=(      '' ''  '?' '*'  '+'  '!!'    '!!'      '!!'   )
S2_awk=(       '' ''  '?' '*'  '+'  '!!'    '!!'      '!!'   )
S2_find=(      '' ''  '?' '*'  '+'  '!!'    '!!'      '!!'   )
S2_emacs=(     '' ''  '?' '*'  '+'  '!!'    '!!'      '!!'   )
S2_lisp=(      '' ''  '?' '*'  '+'  '!!'    '!!'      '!!'   )
S2_tcl=(       '' ''  '?' '*'  '+'  '!!'    '!!'      '!!'   )
S2_expect=(    '' ''  '?' '*'  '+'  '!!'    '!!'      '!!'   )
S2_vi=(   '' '' '\{0,1\}' '*' '\{1,\}' '\{@\}' '\{1,@\}' '\{@,\}')
#63# cause on table 6-1 it seems that the vi part is wrong

### Mastering Regular Expressions pages:
# egrep 29 1-3
# .* 182 6-1
# grep 183 6-2
# *awk 184 6-3
# tcl 189 6-4
# emacs 194 6-7
# perl 201 7-1
### Other:
# php 4.0.3pl1 docs (POSIX 1003.2 extended regular expressions)


# tst: \/_$[]{}()|+?^_/p , [gm]awk=egrep, lisp=emacs
# [[:abc:]]: Invalid character class name
#details,grouping,alternatives,escape meta,escape normal,escape inside [],[:POSIX:],TAB inside []
#                              \.*[]{}()|+?^$   ,=tested  space=pending

ax_sed=(       ''  '\|'  '\(' '\)'  '\'  '\.*[,,,,,,,,,,' ',' 'P' '\t')
ax_ed=(        ''  '\|'  '\(' '\)'  '\'  '\.*[,,,,,,,,,,' ',' 'P' ',' )
ax_grep=(      ''  '\|'  '\(' '\)'  '\'  '\.*[,,,,,,,,,,' ',' 'P' ',' )
ax_vim=(       ''  '\|'  '\(' '\)'  '\'  '\.*[,,,,,,,,,,' '\' 'P' '\t')
ax_egrep=(     ''   '|'   '(' ')'   '\'  '\.*[,{,()|+?^$' ',' 'P' ',' )
ax_ooo=(       ''   '|'   '(' ')'   '\'  '\.*[,,,()|+?^$' ',' ',' ',' )
ax_php=(       ''   '|'   '(' ')'   '\'  '\.*[,{,(,|+?^$' ',' 'P' '\t')
ax_python=(    ''   '|'   '(' ')'   '\'  '\.*[,{,()|+?^$' '\' ',' '\t')
ax_lex=(       ''   '|'   '(' ')'   '\'  '\.*[ { ( |+?  ' ' ' ' ' ' ' )
ax_perl=(      ''   '|'   '(' ')'   '\'  '\.*[,,,()|+?^$' '\' 'P' '\t')
ax_postgres=(  ''   '|'   '(' ')'   '\\' '\.*[,,,(,|+?^$' '\' 'P' '\t')
ax_javascript=(''   '|'   '(' ')'   '\'  '\.*[,{,(,|+?^$' '\' ',' '\t')
ax_vbscript=(  ''   '|'   '(' ')'   '\'  '\.*[ { ( |+?  ' '\' ' ' '\t')
ax_gawk=(      ''   '|'   '(' ')'   '\'  '\.*[,,,(,|+?^$' '\' 'P' '\t')
ax_mysql=(     ''   '|'   '(' ')'   '\\' '\.*[,,,(,|+?^$' '\' 'P' '\t')
ax_procmail=(  ''   '|'   '(' ')'   '\'  '\.*[,,,()|+?,,' ',' ',' ',' )
ax_mawk=(      ''   '|'   '(' ')'   '\'  '\.*[,,,()|+?^$' '\' ',' '\t')
ax_awk=(       ''   '|'   '(' ')'   '\'  '\.*[   (,|+?  ' '\' ',' '\t')
ax_find=(      ''  '\|'  '\(' '\)'  '\'  '\.*[,,,,,,+?,,' ',' ',' ',' )
ax_emacs=(     ''  '\|'  '\(' '\)'  '\'  '\.*[      +?  ' ',' ',' ',' )
ax_lisp=(      '' '\\|' '\\(' '\\)' '\\' '\.*[      +?  ' ',' ',' ',' )
ax_tcl=(       ''   '|'   '(' ')'   '\'  '\.*[,{}()|+?^$' '\' ',' '\t')
ax_expect=(    ''   '|'   '(' ')'   '\'  '\.*[   ( |+?  ' ' ' ' ' ' ' )
ax_vi=(        ''  '!!'  '\(' '\)'  '\'  '\.*[          ' ',' 'P' ',' )
#194# emacs: a backslash ... it is not special
#78#  emacs: it uses \s for special "syntax classes"
#189# tcl: withing a class, a backslash is not special
# man procmailrc: does not support named character classes.


ColorOnOff(){
    # The colors: Normal, Prompt, Bold, Important
    [ "$use_colors" -eq 0 ] && return
    if [ -n "$cN" ]
    then
        unset cN cP cB cI cR
    elif [ "$has_white_background" -eq 0 ]
    then
        cN=$(printf '\033[m')      # normal
        cP=$(printf '\033[1;31m')  # red
        cB=$(printf '\033[1;37m')  # white
        cI=$(printf '\033[1;33m')  # yellow
        cR=$(printf '\033[7m')     # reverse
    else
        cN=$(printf '\033[m')      # normal
        cP=$(printf '\033[31m')    # red
        cB=$(printf '\033[32m')    # green
        cI=$(printf '\033[34m')    # blue
        cR=$(printf '\033[7m')     # reverse
    fi
}

sek(){
    local a=1 z=$1
    while [ "$a" -le "$z" ]
    do
        printf '%d\n' "$a"
        a=$((a + 1))
    done
}

getLargestItem(){
    local mjr
    while [ -n "$1" ]
    do
        [ ${#1} -gt ${#mjr} ] && mjr="$1"
        shift
    done
    printf '%s\n' "$mjr"
}

getMeta(){
    local m="$1[$2]"
    m=${!m}
    m=${m//[@!,_]/}

    # Remove when getting '?' or '+' for 'vi', since they are unsupported
    # and the current values are workarounds using '{}'
    [ "$1" == S2_vi ] && { [ "$2" -eq 2 ] || [ "$2" -eq 4 ]; } && m=""

    printf '%s\n' "$m"
}

ShowMeta(){
    local i g1 g2 prog progsize
    progsize=$(getLargestItem "${allprogs[@]}")
    for ((i=0; i<${#allprogs[@]}; i++))
    do
        prog=${allprogs[$i]}
        g1=$(getMeta "ax_$prog" 2)
        g2=$(getMeta "ax_$prog" 3)

        printf "\n%${#progsize}s" "$prog"       # name
        printf '%8s' "$(getMeta "S2_$prog" 4)"  # +
        printf '%8s' "$(getMeta "S2_$prog" 2)"  # ?
        printf '%8s' "$(getMeta "S2_$prog" 5)"  # {}
        printf '%8s' "$(getMeta "ax_$prog" 1)"  # |
        printf '%8s' "$g1$g2"                   # ()
        # printf ' %s: %s' "$prog" "${allversions[$i]}"  # DEBUG
    done
    printf '\n\n%s\n\n' $"NOTE: . [] [^] and * are the same on all programs."
}

ShowInfo(){
    local index ver posix=$"NO" tabinlist=$"NO" prog=$1
    local j t1 t2 t3 t4 t5 t6 txtsize escmeta needesc metas
    local -a data txt

    # Getting data
    index=$(getItemIndex "$prog" "${allprogs[@]}")
    ver="${allversions[$index]}"
    escmeta=$(getMeta "ax_$prog" 4)
    needesc=$(getMeta "ax_$prog" 5)
    [ "$(getMeta "ax_$prog" 7)" == 'P'  ] && posix=$"YES"
    [ "$(getMeta "ax_$prog" 8)" == '\t' ] && tabinlist=$"YES"

    # Metacharacters list
    # printf arguments: + ? {} | ( )
    metas="$(printf '. [] [^] * %s %s %s %s %s%s' \
        "$(getMeta "S2_$prog" 4)" \
        "$(getMeta "S2_$prog" 2)" \
        "$(getMeta "S2_$prog" 5)" \
        "$(getMeta "ax_$prog" 1)" \
        "$(getMeta "ax_$prog" 2)" \
        "$(getMeta "ax_$prog" 3)"
    )"

    # Populating cool i18n arrays
    txt=(
        $"program"
        $"metas"
        $"esc meta"
        $"need esc"
        $"\t in []"
        '[:POSIX:]'
    )
    data=(
        "$prog: $ver"
        "$metas"
        "$escmeta"
        "${needesc//[ ,]/}"
        "$tabinlist"
        "$posix"
    )

    # Show me! show me! show me!
    ColorOnOff
    printf '\n'
    txtsize=$(getLargestItem "${txt[@]}")
    for ((i=0; i<${#txt[@]}; i++))
    do
        printf "%s %${#txtsize}s %s %s\n" \
            "$cR" "${txt[$i]}" "${cN:-:}" "${data[$i]}"
    done
    printf '\n'
}


if [ "$mode_show_meta" -eq 1 ]
then
    ShowMeta
    exit 0
fi

if [ "$mode_show_info" -eq 1 ]
then
    ShowInfo "$infoprog"
    exit 0
fi


# Screen size/positioning issues
ScreenSize(){
    x_regex=1
    y_regex=4
    x_hist=3
    y_hist=$((y_regex + ${#progs[*]} + 1))
    x_prompt=3
    y_prompt=$((y_regex + ${#progs[*]} + 2))
    x_menu=3
    y_menu=$((y_prompt + 2))
    x_prompt2=15
    y_max=$((y_menu + ${#S1_txt[*]}))

    # The defaults case not exported
    : ${LINES:=25}
    : ${COLUMNS:=80}

    #TODO automatic check when selecting programs
    if [ "$is_interactive" -eq 1 ] && [ $LINES -lt "$y_max" ]
    then
        printError '\n%s\n%s\n%s\n' \
        "$(printf \
            $"Your terminal has %d lines, but txt2regex needs at least %d lines." \
            "$LINES" "$y_max" \
        )" \
        $"Increase the number of lines or select less programs using --prog." \
        $"If this line number detection is incorrect, export the LINES variable."
    fi
}


_eol=$(printf '\033[0K')  # clear trash until EOL

# The cool control chars functions
gotoxy(){   [ "$is_interactive" -eq 1 ] && printf '\033[%d;%dH' "$2" "$1"; }
clearEnd(){ [ "$is_interactive" -eq 1 ] && printf '\033[0J'; }
clearN(){   [ "$is_interactive" -eq 1 ] && printf '\033[%dX' "$1"; }
Clear(){    [ "$is_interactive" -eq 1 ] && printf '\033c'; }

# Ideas: tab between, $cR on cmd, yellow-white-yellow
printTitleCmd(){
    printf '[%s%s%s]%s  ' "$cI" "$1" "$cN" "$2"
}

TopTitle(){
    gotoxy 1 1
    local i j showme txt color
    [ "$is_interactive" -eq 0 ] && return

    # 1st line: aplication commands
    for ((i=0; i<10; i++))
    do
        showme=0
        txt=${tit1_txt[$i]}
        cmd=${tit1_cmd[$i]}
        case $i in
            [01])
                showme=1
            ;;
            2)
                [ "$use_colors" -eq 1 ] && showme=1
            ;;
            3)
                [ "$STATUS" -eq 0 ] && showme=1
            ;;
            9)
                gotoxy $((COLUMNS - ${#txt})) 1
                printf '%s\n' "$txt"
            ;;
        esac
        if [ $showme -eq 1 ]
        then
            printTitleCmd "$cmd" "$txt"
        else
            clearN $((${#txt} + 3))
        fi
    done

    # 2nd line: grouping and or
    if [ "$STATUS" -eq 0 ]
    then
        printf %s "$_eol"
    else
        if [ "$STATUS" -eq 1 ]
        then
            for i in 0 1 2
            do
                txt=${tit2_txt[$i]}
                cmd=${tit2_cmd[$i]}
                showme=1
                [ $i -eq 2 ] && [ $GRP1 -eq $GRP2 ] && showme=0
                if [ $showme -eq 1 ]
                then
                    printTitleCmd "$cmd" "$txt"
                else
                    clearN $((${#txt} + 3))
                fi
            done
        else  # delete commands only
            clearN $((${#tit2_txt[0]} + 5 + ${#tit2_txt[1]} + 5 + ${#tit2_txt[2]} + 5))
        fi

        # open groups
        gotoxy $((COLUMNS - GRP1 - GRP2 - ${#GRP1})) 2
        color="$cP"
        [ "$GRP1" -eq "$GRP2" ] && color="$cB"
        for ((j=0; j<GRP1; j++)); do printf '%s(%s' "$color" "$cN"; done
        [ $GRP1 -gt 0 ] && printf %s "$GRP1"
        for ((j=0; j<GRP2; j++)); do printf '%s)%s' "$color" "$cN"; done
    fi

    # 3rd line: legend
    txt=${tit2_txt[9]}
    cmd=${tit2_cmd[9]}
    gotoxy $((COLUMNS - ${#txt} - ${#cmd} - 1)) 3
    if [ "$has_not_supported" -eq 1 ]
    then
        printf '%s%s%s %s' "$cB" "$cmd" "$cN" "$txt"
    else
        clearN $((${#txt} + ${#cmd} + 1))
    fi
}

doMenu(){
    local -a Menui
    eval "Menui=(\"\${$1[@]}\")"
    menu_n=$((${#Menui[*]} - 1))  # ini

    if [ "$is_interactive" -eq 1 ]
    then

        # history
        gotoxy $x_hist $y_hist
        printf '   %s.oO(%s%s%s)%s%s(%s%s%s)%s%s\n' \
            "$cP" "$cN" "$REPLIES" "$cP" "$cN" \
            "$cP" "$cN" "$uins" "$cP" "$cN" \
            "$_eol"

        # title
        gotoxy $x_menu $y_menu
        printf '%s%s:%s%s\n' "$cI" "${Menui[0]}" "$cN" "$_eol"

        # itens
        for i in $(sek $menu_n)
        do
            printf '  %s%d%s) %s%s\n' "$cB" "$i" "$cN" "${Menui[$i]}" "$_eol"
            i=$((i + 1))
        done
        clearEnd

        # prompt
        gotoxy $x_prompt $y_prompt
        printf '%s[1-%d]:%s %s' "$cP" "$menu_n" "$cN" "$_eol"
        read -r -n 1
    else
        doNextHist
        REPLY=$hist
    fi
}

Menu(){
    local ok=0 name="$1"
    while [ $ok -eq 0 ]
    do
        doMenu "$name"
        case "$REPLY" in
            [1-9])
                [ "$REPLY" -gt "$menu_n" ] && continue
                ok=1
                REPLIES="$REPLIES$REPLY"
            ;;
            .)
                ok=1
                LASTSTATUS=$STATUS
                STATUS=3
            ;;
            0)
                ok=1
                STATUS=Z
            ;;
            \*)
                ColorOnOff
                TopTitle
            ;;
            [\(\)\|])
                [ "$STATUS" -ne 1 ] && continue
                [ "$REPLY" == ')' ] &&
                    { [ $GRP1 -gt 0 ] && [ $GRP1 -eq $GRP2 ] || [ $GRP1 -eq 0 ]; } &&
                    continue
                [ "$REPLY" == ')' ] && STATUS=2
                ok=1
                REPLIES="$REPLIES$REPLY"
            ;;
            /)
                ok=1
                STATUS=4
            ;;
        esac
    done
}

doNextHist(){
    hists=${hists#?}   # deleting previous item
    hist=${hists:0:1}
    : "${hist:=.}"       # if last, quit
}

doNextHistArg(){
    histargs=${histargs#*¤}
    histarg=${histargs%%¤*}
}

getChar(){
    gotoxy $x_prompt2 $y_prompt

    if [ "$is_interactive" -eq 1 ]
    then
        printf '%s%s%s ' "$cP" $"which one?" "$cN"
        read -n 1 -r USERINPUT
        uin="$USERINPUT"
    else
        doNextHistArg
        uin=$histarg
    fi

    uins="${uins}¤$uin"
    F_ESCCHAR=1
}


#TODO 1st of all, take out repeated chars
getCharList(){
    gotoxy $x_prompt2 $y_prompt

    if [ "$is_interactive" -eq 1 ]
    then
        printf '%s%s%s ' "$cP" $"which?" "$cN"
        read -r USERINPUT
        uin="$USERINPUT"
    else
        doNextHistArg
        uin=$histarg
    fi
    uins="${uins}¤$uin"

    # putting not special chars in not special places: [][^-]
    [ "${uin/^//}" != "$uin" ] && uin="${uin/^/}^"
    [ "${uin/-//}" != "$uin" ] && uin="${uin/-/}-"
    [ "${uin/[//}" != "$uin" ] && uin="[${uin/[/}"
    [ "${uin/]//}" != "$uin" ] && uin="]${uin/]/}"

    # if any $1, negated list
    [ -n "$1" ] && uin="^$uin"

    uin="[$uin]"
    F_ESCCHARLIST=1
}

getString(){
    gotoxy $x_prompt2 $y_prompt

    if [ "$is_interactive" -eq 1 ]
    then
        printf '%stxt:%s ' "$cP" "$cN"
        read -r USERINPUT
        uin="$USERINPUT"
    else
        doNextHistArg
        uin=$histarg
    fi

    uins="${uins}¤$uin"
    F_ESCCHAR=1
}

getNumber(){
    gotoxy $x_prompt2 $y_prompt

    if [ "$is_interactive" -eq 1 ]
    then
        printf '%sN=%s%s' "$cP" "$cN" "$_eol"
        read -r USERINPUT
        uin="$USERINPUT"
    else
        doNextHistArg
        uin=$histarg
    fi

    # Extracting !numbers
    uin="${uin//[^0-9]/}"

    # ee
    if [ "${uin/666/x}" == 'x' ]
    then
        gotoxy 36 1
        printf '%s]:|%s\n' "$cP" "$cN"
    fi

    if [ -n "$uin" ]
    then
        uins="${uins}¤$uin"
    else
        getNumber  # there _must_ be a number
    fi
}

getPosix(){
    local rpl psx=''
    unset SUBHUMAN

    if [ "$is_interactive" -eq 1 ]
    then
        Choice --reset "${posix_txt[@]}"
    else
        ChoiceAuto
    fi

    for rpl in $CHOICEREPLY
    do
        psx="${psx}[:${posix_re[$rpl]}:]"
        SUBHUMAN="$SUBHUMAN, ${posix_txt[$rpl]/ (*)/}"
    done

    SUBHUMAN=${SUBHUMAN#, }
    F_POSIX=1

    uin="[$psx]"
    uins="${uins}¤:${CHOICEREPLY// /}"
}

getCombo(){
    local rpl cmb=''
    unset SUBHUMAN

    if [ "$is_interactive" -eq 1 ]
    then
        Choice --reset "${combo_txt[@]}"
    else
        ChoiceAuto
    fi

    for rpl in $CHOICEREPLY
    do
        cmb="$cmb${combo_re[$rpl]}"
        SUBHUMAN="$SUBHUMAN, ${combo_txt[$rpl]/ (*)/}"
    done

    #TODO change this to if [ "$rpl" -eq 5 ]
    [ "$cmb" != "${cmb/@/}" ] && F_GETTAB=1

    SUBHUMAN=${SUBHUMAN#, }

    uin="[$cmb]"
    uins="${uins}¤:${CHOICEREPLY// /}"
}

#TODO all
getREady(){
    unset SUBHUMAN
    uin=''
}

# convert [@] -> [\t] or [<TAB>] based on ax_*[8] value
# TODO expand this to all "gettable" fields: @
getListTab(){
    local x="ax_${progs[$1]}[8]"

    x=${!x}
    { [ "$x" == ',' ] || [ "$x" == ' ' ]; } && x='<TAB>'
    uin="${uin/@/$x}"
}

getHasPosix(){
    # let's just unsupport the tested ones
    local x="ax_${progs[$1]}[7]"

    [ "${!x}" == ',' ] && uin='!!'
}

# escape userinput chars as .,*,[ and friends
escChar(){
    local c x x2 z i esc ui="$uin"

    # Get escape char
    esc="ax_${progs[$1]}[4]"
    esc=${!esc}

    # List of escapable chars
    x="ax_${progs[$1]}[5]"
    x=${!x}

    # , and space are trash
    x="${x//[, ]/}"

    # Test for speed up
    if [ "${ui/[\\\\$x]/}" != "$ui" ]
    then
        for ((i=0; i<${#ui}; i++))  # for each user char
        do
            c="${ui:$i:1}"
            # Disabling because of the } in the second case option
            # shellcheck disable=SC1083
            case "$c" in  # special bash chars
                [?*#%])
                    x2="${x/[$c]/}"
                ;;
                [/}])
                    x2="${x/\\$c/}"
                ;;
                [\\])
                    x2="${x/$c$c/}"
                ;;
                *)
                    x2="${x/$c/}"
                ;;
            esac

            # escaping
            [ "$x2" != "$x" ] && c="$esc$c"
            z="$z$c"
        done
        uin="$z"  # ah, the escaped string
    fi
}

escCharList(){
    local esc x

    # need escape on []
    x="ax_${progs[$1]}[6]"
    x=${!x}

    # escape char
    esc="ax_${progs[$1]}[4]"
    esc=${!esc}

    # escaping escape
    [ "$x" == '\' ] && uin="${uin/\\\\/$esc$esc}"
}

Reset(){
    gotoxy $x_regex $y_regex
    unset REPLIES uins HUMAN "Regex[*]"
    has_not_supported=0
    GRP1=0
    GRP2=0
    local p

    # global maxprogname
    maxprogname=$(getLargestItem "${progs[@]}")  # global var
    for p in ${progs[*]}
    do
        [ "$is_interactive" -eq 1 ] &&
            printf " Regex %-${#maxprogname}s: %s\n" "$p" "$_eol"
    done
}

showRegex(){
    gotoxy $x_regex $y_regex
    local i new_part save="$uin"

    # For each program
    for ((i=0; i<${#progs[@]}; i++))
    do
        [ "$F_ESCCHAR"     == 1 ] && escChar     $i
        [ "$F_ESCCHARLIST" == 1 ] && escCharList $i
        [ "$F_GETTAB"      == 1 ] && getListTab  $i
        [ "$F_POSIX"       == 1 ] && getHasPosix $i

        # Check status
        case "$1" in
            ax|S2)
                eval new_part="\${$1_${progs[$i]}[$REPLY]/@/$uin}"
                Regex[$i]="${Regex[$i]}$new_part"
                [ "$new_part" == '!!' ] && has_not_supported=1
            ;;
            S0)
                Regex[$i]="${Regex[$i]}${S0_re[$REPLY]}"
            ;;
            S1)
                Regex[$i]="${Regex[$i]}${uin:-${S1_re[$REPLY]}}"

                # When a program does not support POSIX character classes, $uin
                # will be set to !! by getHasPosix(). Also check $REPLY to avoid
                # a false positive when the user wants to match the !! string.
                [ "$REPLY" -eq 7 ] && [ "$uin" == '!!' ] && has_not_supported=1
            ;;
        esac

        [ "$is_interactive" -eq 1 ] &&
            printf " Regex %-${#maxprogname}s: %s\n" "${progs[$i]}" "${Regex[$i]}"
        uin="$save"
    done
    unset uin USERINPUT F_ESCCHAR F_ESCCHARLIST F_GETTAB F_POSIX
}


#
### And now the cool-smart-MSclippy choice menu/prompt
#
# number of items <= 10, 1 column
# number of items >  10, 2 columns
# maximum number of items = 26 (a-z)
#

# Just refresh the selected item on the screen
ChoiceRefresh(){
    local xy=$1 a=$2 stat=$3 opt=$4

    # colorizing case status is ON
    [ "$stat" == '+' ] && stat="$cI$stat$cN"

    gotoxy "${xy#*;}" "${xy%;*}"
    printf '  %s%s%s) %s%s ' "$cB" "$a" "$cN" "$stat" "$opt"
}

# --reset resets the stat array
Choice(){
    local choicereset=0
    [ "$1" == '--reset' ] && shift && choicereset=1

    local alpha opts optxy numopts=$#
    local lines cols line op alf rpl
    alpha=(a b c d e f g h i j k l m n o p q r s t u v w x y z)

    # Reading options and filling default status (off)
    i=0
    for opt in "$@"
    do
        opts[$i]="$opt"
        [ "$choicereset" -eq 1 ] && stat[$i]='-'
        i=$((i + 1))
    done

    # Checking our number of items limit
    [ "$numopts" -gt "${#alpha[*]}" ] &&
        printError 'too much itens (>%d)' "${#alpha[*]}"

    # The header
    Clear
    printTitleCmd '.' $"exit"
    printf '| %s' $"press the letters to (un)select the items"

    # We will need 2 columns?
    cols=1
    [ "$numopts" -gt 10 ] && cols=2

    # And how much lines? (remember: odd number of items, requires one more line)
    lines=$((numopts / cols))
    [ "$((numopts % cols))" -eq 1 ] && lines=$((lines + 1))

    # Filling the options screen's position array (+3 = header:2, sek:1)
    for ((line=0; line<lines; line++))
    do
        # Column 1
        optxy[$line]="$((line + 3));1"

        # Column 2
        [ "$cols" == 2 ] && optxy[$((line + lines))]="$((line + 3));40"
    done

    # Showing initial status for all options
    for ((op=0; op<numopts; op++))
    do
        ChoiceRefresh "${optxy[$op]}" "${alpha[$op]}" "${stat[$op]}" "${opts[$op]}"
    done

    # And now the cool invisible prompt
    while :
    do
        read -s -r -n 1 CHOICEREPLY

        case "$CHOICEREPLY" in
            [a-z])
                # Inverting the option status
                for ((alf=0; alf<numopts; alf++))
                do
                    if [ "${alpha[$alf]}" == "$CHOICEREPLY" ]
                    then
                        if [ "${stat[$alf]}" == '+' ]
                        then
                            stat[$alf]='-'
                        else
                            stat[$alf]='+'
                        fi
                        break
                    fi
                done

                # Showing the change
                [ -z "${opts[alf]}" ] && continue
                ChoiceRefresh "${optxy[$alf]}" "${alpha[$alf]}" \
                    "${stat[$alf]}" "${opts[$alf]}"
            ;;
            .)
                # Getting the user choices and exiting
                unset CHOICEREPLY
                for ((rpl=0; rpl<numopts; rpl++))
                do
                    [ "${stat[$rpl]}" == '+' ] && CHOICEREPLY="$CHOICEREPLY $rpl"
                done
                break
            ;;
        esac
    done
}

# Non-interative, just return the answers
ChoiceAuto(){
    local i z

    unset CHOICEREPLY
    doNextHistArg
    z=${histarg#:}  # marker

    for ((i=0; i<${#z}; i++))
    do
        CHOICEREPLY="$CHOICEREPLY ${z:$i:1}"
    done
}

# Fills the stat array with the actual active programs ON
statActiveProgs(){
    local p i=0 ps=" ${progs[*]} "

    # For each program
    for ((i=0; i<${#allprogs[@]}; i++))
    do
        # Default OFF
        p="${allprogs[$i]}"
        stat[$i]='-'

        # Case found, turn ON
        [ "${ps/ $p /}" != "$ps" ] && stat[$i]='+'
    done
}

###############################################################################
######################### ariel, ucla, vamos! #################################
###############################################################################

STATUS=0           # default status
Clear; ScreenSize  # screen things
ColorOnOff         # turning color ON
trap "clearEnd; echo; exit" SIGINT

while :
do
    case ${STATUS:=0} in
        0|Z)
            STATUS=${STATUS/Z/0}
            Reset
            TopTitle
            Menu S0_txt
            [ -z "${STATUS/[Z34]/}" ] && continue  # 0,3,4: escape status
            HUMAN="${S0_txt[0]} ${S0_txt[$REPLY]}"
            showRegex S0
            STATUS=1
        ;;
        1)
            TopTitle
            Menu S1_txt
            [ -z "${STATUS/[Z34]/}" ] && continue  # 0,3,4: escape status
            if [ -n "${REPLY/[1-9]/}" ]
            then
                HUMAN="$HUMAN $REPLY"
                if [ "$REPLY" == '|' ]
                then
                    REPLY=1
                elif [ "$REPLY" == '(' ]
                then
                    REPLY=2
                    GRP1=$((GRP1 + 1))
                elif [ "$REPLY" == ')' ]
                then
                    REPLY=3
                    GRP2=$((GRP2 + 1))
                else
                    printf '\n\n'
                    printError 'unknown reply type "%s"\n' "$REPLY"
                fi
                showRegex ax
            else
                HUMAN="$HUMAN, ${S1_txt[0]} ${S1_txt[$REPLY]/ (*)/}"
                case "$REPLY" in
                    1)
                        STATUS=2
                    ;;
                    2)
                        STATUS=2
                        getChar
                    ;;
                    3)
                        STATUS=1
                        getString
                        HUMAN="$HUMAN {$uin}"
                    ;;
                    4)
                        STATUS=2
                        getCharList
                    ;;
                    5)
                        STATUS=2
                        getCharList negated
                    ;;
                    [678])
                        STATUS=12
                        continue
                    ;;
                    9)
                        STATUS=1
                    ;;
                esac
                showRegex S1
            fi
        ;;
        12)
            [ "$REPLY" -eq 6  ] && STATUS=2 && getCombo
            [ "$REPLY" -eq 7  ] && STATUS=2 && getPosix
            [ "$REPLY" -eq 8  ] && STATUS=1 && getREady
            Clear
            TopTitle
            HUMAN="$HUMAN {$SUBHUMAN}"
            showRegex S1
        ;;
        2)
            TopTitle
            Menu S2_txt
            [ -z "${STATUS/[Z34]/}" ] && continue  # 0,3,4: escape status
            rep_middle=$"repeated"
            rep_txt="${S2_txt[$REPLY]}"
            rep_txtend=$"times"

            [ "$REPLY" -ge 5 ] && getNumber && rep_txt=${rep_txt/N/$uin}
            HUMAN="$HUMAN, $rep_middle ${rep_txt/ (*)/} $rep_txtend"
            showRegex S2
            STATUS=1
        ;;
        3)
            [ "$is_interactive" -eq 0 ] && STATUS=9 && continue
            warning=$"Really quit?"
            read -r -n 1 -p "..$cB $warning [.] $cN"
            STATUS=$LASTSTATUS
            [ "$REPLY" == '.' ] && STATUS=9
        ;;
        4)
            statActiveProgs
            Choice "${allprogs[@]}"
            i=0
            unset progs

            # Rewriting the progs array with the user choices
            for rpl in $CHOICEREPLY
            do
                progs[$i]=${allprogs[$rpl]}
                i=$((i + 1))
            done
            ScreenSize
            Clear
            STATUS=0
        ;;
        9)
            gotoxy $x_hist $y_hist
            clearEnd
            if [ "$is_interactive" -eq 1 ]
            then
                noregex_txt=$"no regex"
                printf "%stxt2regex --history '%s%s'%s\n\n" \
                    "$cB" "$REPLIES" "$uins" "$cN"
                printf '%s.\n' "${HUMAN:-$noregex_txt}"
            else
                for ((i=0; i<${#progs[@]}; i++))  # for each program
                do
                    printf " Regex %-${#maxprogname}s: %s\n" \
                        "${progs[$i]}" "${Regex[$i]}"
                done
                printf '\n'
            fi
            exit 0
        ;;
        *)
            printError 'STATUS = "%s"\n' "$STATUS"
        ;;
    esac
done
