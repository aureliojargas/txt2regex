#!/bin/bash
# txt2regex.sh - Regular Expressions "wizard", all in bash2 builtins
#
# Website : http://aurelio.net/projects/txt2regex/
# Author  : Aurelio Jargas (verde@aurelio.net)
# License : GPL
# Requires: bash >= 2.04
#
# Please, read the README file.
#
# $STATUS:
#   0  begining of the regex
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
#          ++ flags: interative, color, allprogs
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
#          ++ detailed --help, sorceforge'd
# 20010613 v0.3
# 20010620 -- seq command (not bash), ++ sek()
# 20010613 v0.3.1
# 20010731 ++ Reset: "RegEx prog  :" with automatically length
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
#          ++ history appears when quiting
# 20010905 v0.6
# 20011019 ** program's 1 year birthday!
# 20020225 ++ "really quit?" message, ++ --version
# 20020304 <> --history just shows final RE on STDOUT
#          ++ --make, --prog, printError()
#          ++ groups are now quantifiable
#          ++ ready_(date[123], hour[123], number[123])
# 20020304 v0.7
# 20021019 ** program's 2 year birthday!
# 20031019 ** program's 3 year birthday!
# 20040928 <> bash version test (works in 3.x and newer)
# 20040928 v0.8
# 20040929 <> --help splitted into individual messages (helps i18n)
# 20041019 ** program's 4 year birthday!
# 20051019 ** program's 5 year birthday!
# 20051229 <> fixed bug on bash3 for eval contents (thanks Marcus Habermehl)
# 20121221 ** debut in GitHub
#

# TODO \<borders\>
# TODO empty | check like ^| or (|)
# TODO ready_email (see guia_er)
# TODO negated POSIX|special combination (Choice hack)
# TODO add expr, oawk, nawk, MKS awk, flex
# TODO ~/.txt2regexrc: remember programs, last histories, name REs
# TODO LATER how to capture blanks on Get* (via menu)?
# TODO LATER user defined ranges on lists (prompt, validation)

TEXTDOMAIN=txt2regex
TEXTDOMAINDIR=po
VERSION=0

# We _need_ bash>=2.04
case "$BASH_VERSION" in
	2.0[4-9]*|2.[1-9]*|[3-9].*)
		:  # do nothing
	;;
	*)
		echo "bash version >=2.04 required, but you have $BASH_VERSION"
		exit 1
	;;
esac

Usage(){
	echo $"usage: txt2regex [ --nocolor | --whitebg ] [ --all | --prog PROGRAMS ]"
	echo $"       txt2regex --showmeta"
	echo $"       txt2regex --showinfo PROGRAM [ --nocolor ]"
	echo $"       txt2regex --history VALUE [ --all | --prog PROGRAMS ]"
	echo $"       txt2regex --make LABEL [ --all | --prog PROGRAMS ]"
	echo
	echo $"OPTIONS (they are default OFF):"
	echo
	echo $"  --all               Works with all registered programs"
	echo $"  --nocolor           Don't use colors"
	echo $"  --whitebg           Colors adjusted for white background terminals"
	echo $"  --prog PROGRAMS     Choose which programs to use, separated by commas"
	echo
	echo $"  --showmeta          Prints a metacharacters table with all programs"
	echo $"  --showinfo PROGRAM  Prints regex info about the specified program"
	echo $"  --history VALUE     Prints a regex from the given history data"
	echo $"  --make LABEL        Prints the default regex for the specified label"
	echo
	echo $"  --version           Prints the program version and quit"
	echo $"  --help              Prints the help message and quit"
	echo
	echo $"Please read the program Man Page for more information."
	exit 1
}

printError(){
	echo -e "\nERROR: $*\n"
	exit 1
}

# The defaults
f_i=1
f_color=1
f_whitebg=0
GRP1=0
GRP2=0


# Here's the default list of programs shown.
# Edit here or use --prog to overwrite it.
progs=(perl php postgres python sed vim)


### IMPORTANT DATA ###
allprogs=(awk ed egrep emacs expect find gawk grep javascript lex lisp mawk mysql ooo perl php postgres procmail python sed tcl vbscript vi vim)
allversions=('' 'GNU ed version 0.2' 'egrep (GNU grep) 2.4.2' '' '' 'GNU find version 4.1' 'GNU Awk 3.0.6' 'grep (GNU grep) 2.4.2' 'netscape-4.77' '' '' 'mawk 1.3.3 Nov 1996' 'Ver 11.13 Distrib 3.23.36' 'OpenOffice.org 1.1.0' 'v5.6.0 built for i386-linux' '4.0.6' 'psql (PostgreSQL) 7.1.2' 'procmail v3.15.1 2001/01/08' 'Python 2.1' 'GNU sed version 3.02.80' '8.3' '' 'Nvi 1.79 (10/23/96)' 'VIM - Vi IMproved 5.8 (2001 May 31)')
ready_date=('26521652165¤:2¤2¤/¤:2¤2¤/¤:2¤4' \
            'date LEVEL 1: mm/dd/yyyy: matches from 00/00/0000 to 99/99/9999')
ready_date2=('24161214161214165¤01¤:2¤/¤0123¤:2¤/¤12¤:2¤3' \
            'date LEVEL 2: mm/dd/yyyy: matches from 00/00/1000 to 19/39/2999')
ready_date3=('2(2161|2141)121(2161|4161|2141)1214165¤0¤:2¤1¤012¤/¤0¤:2¤12¤:2¤3¤01¤/¤12¤:2¤3' \
            'date LEVEL 3: mm/dd/yyyy: matches from 00/00/1000 to 12/31/2999')
ready_hour=('2652165¤:2¤2¤:¤:2¤2' \
            'hour LEVEL 1: hh:mm: matches from 00:00 to 99:99')
ready_hour2=('24161214161¤012¤:2¤:¤012345¤:2' \
            'hour LEVEL 2: hh:mm: matches from 00:00 to 29:59')
ready_hour3=('2(4161|2141)1214161¤01¤:2¤2¤0123¤:¤012345¤:2' \
            'hour LEVEL 3: hh:mm: matches from 00:00 to 23:59')
ready_number=('24264¤-+¤:2' \
            'number LEVEL 1: integer, positive and negative')
ready_number2=('24264(2165)2¤-+¤:2¤.¤:2¤2' \
            'number LEVEL 2: level 1 plus optional float point')
ready_number3=('24266(2165)3(2165)2¤-+¤:2¤3¤,¤:2¤3¤.¤:2¤2' \
            'number LEVEL 3: level 2 plus optional commas, like: 34,412,069.90')
#date3  : perl: (0[0-9]|1[012])/(0[0-9]|[12][0-9]|3[01])/[12][0-9]{3}            
#hour3  : perl: ([01][0-9]|2[0123]):[012345][0-9]
#number3: perl: [+-]?[0-9]{1,3}(,[0-9]{3})*(\.[0-9]{2})?
### -- ###

getItemIndex(){  # array tool
	local i=0 item="$1"
	shift
	while [ "$1" ]
	do
		[ "$1" == "$item" ] && {
			echo $i
			return
		}
		i=$((i+1))
		shift
	done
}

# Parse command line options
while [ $# -gt 0 ]
do
	case "$1" in
		--history)
			[ "$2" ] || Usage
			history="$2"
			shift
			f_i=0
			f_color=0

			hists="0${history%%¤*}"
			histargs="¤${history#*¤}"
			[ "${hists#0}" == "${histargs#¤}" ] && unset histargs
		;;
		--make)
			shift
			f_i=0
			f_color=0
			arg="${1%1}"  # final 1 is optional

			# Sanity check
			valid=${!ready_*}
			valid=" ${valid//ready_/} "
			[ "$valid" == "${valid#* $arg }" ] && \
				printError "--make: '$1':" $"invalid argument" \
					'\n' $"valid names are:" "$valid"

			# Data setting
			hist="ready_$arg[0]"
			hist=${!hist}

			txt="ready_$arg[1]"
			txt=${!txt}

			hists="0${hist%%¤*}"
			histargs="¤${hist#*¤}"

			echo -e "\n### $txt\n"
		;;
		--prog)
			[ "$2" ] || Usage
			shift

			# Sanity check
			for p in ${1//,/ }  # comma separated list
			do
				# Is valid?
				index=$(getItemIndex "$p" "${allprogs[@]}")
				[ "$index" ] || printError "--prog: '$p':" $"invalid argument"
			done
			eval "progs=(${1//,/ })"
		;;
		--nocolor)
			f_color=0
		;;
		--whitebg)
			f_whitebg=1
		;;
		--showmeta)
			f_showmeta=1
		;;
		--showinfo)
			[ "$2" ] || Usage
			infoprog="$2"
			shift
			f_showinfo=1
		;;
		--all)
			progs=(${allprogs[@]})
		;;
		--version)
			echo "txt2regex v$VERSION"
			exit 0
		;;
		--help)
			Usage
		;;
		*)
			echo "'$1':" $"invalid option"
			Usage
		;;
   esac
   shift
done

set -o noglob


### The RegEx show

# NOTE: texts on vars because i18n inside arrays is not possible (sux)

zz0=$"start to match"
zz1=$"on the line beginning"
zz2=$"in any part of the line"
S0_txt=("$zz0" "$zz1" "$zz2")
S0_re=('' '^' '')

zz0=$"followed by"
zz1=$"any character"
zz2=$"a specific character"
zz3=$"a literal string"
zz4=$"an allowed characters list"
zz5=$"a forbidden characters list"
zz6=$"a special combination"
zz7=$"a POSIX combination (locale aware)"
zz8=$"a ready regex (not implemented)"
zz9=$"anything"
S1_txt=("$zz0" "$zz1" "$zz2" "$zz3" "$zz4" "$zz5" "$zz6" "$zz7" "$zz8" "$zz9")
S1_re=('' '.' '' '' '' '' '' '' '' '.*')

zz0=$"how many times (repetition)"
zz1=$"one"
zz2=$"zero or one (optional)"
zz3=$"zero or more"
zz4=$"one or more"
zz5=$"exactly N"
zz6=$"up to N"
zz7=$"at least N"
S2_txt=("$zz0" "$zz1" "$zz2" "$zz3" "$zz4" "$zz5" "$zz6" "$zz7")

# COMBO
zz0=$"uppercase letters"
zz1=$"lowercase letters"
zz2=$"numbers"
zz3=$"underscore"
zz4=$"space"
zz5=$"TAB"
combo_txt=("$zz0" "$zz1" "$zz2" "$zz3" "$zz4" "$zz5")
combo_re=('A-Z' 'a-z' '0-9' '_' ' ' '@')

#TODO use all posix components?
zz0=$"letters"
zz1=$"lowercase letters"
zz2=$"uppercase letters"
zz3=$"numbers"
zz4=$"letters and numbers"
zz5=$"hexadecimal numbers"
zz6=$"whitespaces (space and TAB)"
zz7=$"graphic chars (not-whitespace)"
posix_txt=("$zz0" "$zz1" "$zz2" "$zz3" "$zz4" "$zz5" "$zz6" "$zz7")
posix_re=('alpha' 'lower' 'upper' 'digit' 'alnum' 'xdigit' 'blank' 'graph')

# Title (line 1)
zz0=$"quit"
zz1=$"reset"
zz2=$"color"
zz3=$"programs"
zz9='^txt2regex$'
tit1_txt=("$zz0" "$zz1" "$zz2" "$zz3" "" "" "" "" "" "$zz9")
tit1_cmd=('.' '0' '*' '/' '' '' '' '' '' '')

# Title (line 2-3)
zz0=$"or"
zz1=$"open group"
zz2=$"close group"
zz9=$"not supported"
tit2_txt=("$zz0" "$zz1" "$zz2" "" "" "" "" "" "" "$zz9")
tit2_cmd=('|' '(' ')' '' '' '' '' '' '' '!!')

# Remove all zz* temporary vars
unset ${!zz*}


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
#194# emacs: a backslash ... it is completely unspecial
#78#  emacs: it uses \s for special "syntax classes"
#189# tcl: withing a class, a backslash is completely unspecial
# man procmailrc: does not support named character classes.


ColorOnOff(){
	# The colors: Normal, Prompt, Bold, Important
	[ "$f_color" != 1 ] && return
	if [ "$cN" ]
	then
		unset cN cP cB cI cR
	elif [ "$f_whitebg" != 1 ]
	then
		cN=$(echo -ne "\033[m")      # normal
		cP=$(echo -ne "\033[1;31m")  # red
		cB=$(echo -ne "\033[1;37m")  # white
		cI=$(echo -ne "\033[1;33m")  # yellow
		cR=$(echo -ne "\033[7m")     # reverse
	else
		cN=$(echo -ne "\033[m")      # normal
		cP=$(echo -ne "\033[31m")    # red
		cB=$(echo -ne "\033[32m")    # green
		cI=$(echo -ne "\033[34m")    # blue
		cR=$(echo -ne "\033[7m")     # reverse
	fi
}

sek(){
	local H='<' s='++' a=1 z=$1
	[ "$2" ] && {
		a=$1
		z=$2
	}
	[ $a -gt $z ] && {
		H='>'
		s='--'
	}
	for ((i=$a; i$H=$z; i$s))
	do
		echo $i
	done
}

getLargestItem(){
	local mjr
	while [ "$1" ]
	do
		[ ${#1} -gt ${#mjr} ] && mjr="$1"
		shift
	done
	echo $mjr
}

getMeta(){
	local m="$1[$2]"
	m=${!m}
	m=${m//[@!,_]/}
	echo "${m//\\\\{[01]*}"  # needed for vi
}

ShowMeta(){
	local i j g1 g2 prog progsize=$(getLargestItem "${allprogs[@]}")
	for ((i=0; i<${#allprogs[@]}; i++))
	do
		prog=${allprogs[$i]}
		printf "\n%${#progsize}s" "$prog"

		for j in 4 2 5
		do
			printf "%8s" $(getMeta S2_$prog $j)
		done

		printf "%8s" $(getMeta ax_$prog 1)  # or

		g1=$(getMeta ax_$prog 2)
		g2=$(getMeta ax_$prog 3)
		printf "%8s" "$g1$g2"               # group
		# printf " $prog: ${allversions[$i]}" #DEBUG
	done
	printf "\n\n%s\n\n" $"NOTE: . [] [^] and * are the same on all programs."
}

ShowInfo(){
	local index ver posix=$"NO" tabinlist=$"NO" prog=$1
	local j t1 t2 t3 t4 t5 t6 txtsize escmeta needesc metas
	local -a data txt

	# Getting data
	index=$(getItemIndex "$prog" "${allprogs[@]}")
	ver="${allversions[$index]}"
	escmeta=$(getMeta ax_$prog 4)
	needesc=$(getMeta ax_$prog 5)
	[ "$needesc" ] || {
		printf "%s: '%s'\n" $"unknown program" "$prog"
		return
	}
	[ "$(getMeta ax_$prog 7)" == 'P'  ] && posix=$"YES"
	[ "$(getMeta ax_$prog 8)" == '\t' ] && tabinlist=$"YES"
	metas=$(for j in 4 2 5; do getMeta S2_$prog $j; done)
	metas="$metas $(getMeta ax_$prog 1; getMeta ax_$prog 2)"  #| (
	metas="$metas$(getMeta ax_$prog 3)"                       #)
	metas=". [] [^] * $(echo $metas)"

	# Populating cool i18n arrays
	t1=$"program"
	t2=$"metas"
	t3=$"esc meta"
	t4=$"need esc"
	t5=$"\t in []"
	t6=$"[:POSIX:]"
	data=("$prog: $ver" "$metas" "$escmeta" "${needesc//[ ,]/}" "$tabinlist" "$posix")
	txt=("$t1" "$t2" "$t3" "$t4" "$t5" "$t6")

	# Show me! show me! show me!
	ColorOnOff
	echo
	txtsize=$(getLargestItem "${txt[@]}")
	for ((i=0; i<${#txt[@]}; i++))
	do
		printf "$cR %${#txtsize}s ${cN:-:} %s\n" "${txt[$i]}" "${data[$i]}"
	done
	echo
}


if [ "$f_showmeta" ]
then
	ShowMeta
	exit 0
fi

if [ "$f_showinfo" ]
then
	ShowInfo "$infoprog"
	exit 0
fi


# Screen size/positioning issues
ScreenSize(){
	x_regex=1
	y_regex=4
	x_hist=3
	y_hist=$((y_regex+${#progs[*]}+1))
	x_prompt=3
	y_prompt=$((y_regex+${#progs[*]}+2))
	x_menu=3
	y_menu=$((y_prompt+2))
	x_prompt2=15
	y_max=$((y_menu+${#S1_txt[*]}))

	# The defaults case not exported
	: ${LINES:=25}
	: ${COLUMNS:=80}

	#TODO automatic check when selecting programs
	[ "$f_i" == 1 -a $LINES -lt "$y_max" ] && {
		printf $"error:
  your screen has %s lines and should have at least %s to this
  program fit on it. increase the number of lines or select
  less programs to show the regex.\n\n" "$LINES" "$y_max"
		exit 1
	}
}


_eol=$(echo -ne "\033[0K")  # clear trash until EOL

# The cool control chars functions
gotoxy(){   [ "$f_i" == 1 ] && echo -ne "\033[$2;$1H"; }
clearEnd(){ [ "$f_i" == 1 ] && echo -ne "\033[0J"; }
clearN(){   [ "$f_i" == 1 ] && echo -ne "\033[$1X"; }
Clear(){    [ "$f_i" == 1 ] && echo -ne "\033c"; }

# Ideas: tab between, $cR on cmd, yellow-white-yellow
printTitleCmd(){
	printf "[$cI%s$cN]%s  " "$1" "$2"
}

TopTitle(){
	gotoxy 1 1
	local i j showme txt color
	[ "$f_i" != 1 ] && return

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
				[ "$f_color" == 1 ] && showme=1
			;;
			3)
				[ $STATUS -eq 0 ] && showme=1
			;;
			9)
				gotoxy $((COLUMNS-${#txt})) 1
				echo "$txt"
			;;
		esac
		if [ $showme -eq 1 ]
		then
			printTitleCmd "$cmd" "$txt"
		else
			clearN $((${#txt}+3))
		fi
	done

	# 2nd line: grouping and or
	if [ $STATUS -eq 0 ]
	then
		echo -n $_eol
	else
		if [ $STATUS -eq 1 ]
		then
			for i in 0 1 2
			do
				txt=${tit2_txt[$i]}
				cmd=${tit2_cmd[$i]}
				showme=1
				[ $i -eq 2 -a $GRP1 -eq $GRP2 ] && showme=0
				if [ $showme -eq 1 ]
				then
					printTitleCmd "$cmd" "$txt"
				else
					clearN $((${#txt}+3))
				fi
			done
		else  # delete commands only
			clearN $((${#tit2_txt[0]}+5+${#tit2_txt[1]}+5+${#tit2_txt[2]}+5))
		fi

		# open groups
		gotoxy $((COLUMNS-$GRP1-$GRP2-${#GRP1})) 2
		color="$cP"
		[ "$GRP1" -eq "$GRP2" ] && color="$cB"
		for ((j=0 ;j<$GRP1;j++)); do echo -n "$color($cN"; done
		[ $GRP1 -gt 0 ] && echo -n $GRP1
		for ((j=0 ;j<$GRP2;j++)); do echo -n "$color)$cN"; done
	fi

	# 3rd line: legend
	txt=${tit2_txt[9]}
	cmd=${tit2_cmd[9]}
	gotoxy $((COLUMNS-${#txt}-${#cmd}-1)) 3
	printf "$cB%s$cN %s" "$cmd" "$txt"
}

doMenu(){
	local -a Menui
	eval "Menui=(\"\${$1[@]}\")"
	menu_n=$((${#Menui[*]}-1))  # ini

	if [ "$f_i" == 1 ]
	then

		# history
		gotoxy $x_hist $y_hist
		echo "   $cP.oO($cN$REPLIES$cP)$cN$cP($cN$uins$cP)$cN$_eol"

		# title
		gotoxy $x_menu $y_menu
		echo "$cI${Menui[0]}:$cN$_eol"

		# itens
		for i in $(sek $menu_n)
		do
			echo "  $cB$i$cN) ${Menui[$i]}$_eol"
			i=$((i+1))
		done
		clearEnd

		# prompt
		gotoxy $x_prompt $y_prompt
		echo -ne "$cP[1-$menu_n]:$cN $_eol"
		read -n 1
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
				[ "$REPLY" == ')' ] && [ $GRP1 -gt 0 -a $GRP1 -eq $GRP2 -o $GRP1 -eq 0 ] && continue
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

	# 0,3,4: escape status
	[ "${STATUS/[Z34]/}" ] || continue
}

doNextHist(){
	hists=${hists#?}   # deleting previous item
	hist=${hists:0:1}
	: ${hist:=.}       # if last, quit
}

doNextHistArg(){
	histargs=${histargs#*¤}
	histarg=${histargs%%¤*}
}

getChar(){
	gotoxy $x_prompt2 $y_prompt

	if [ "$f_i" == 1 ]
	then
		echo -n "${cP}"
		echo -n $"which one?"
		echo -n " $cN"
		read -n 1 -r USERINPUT
		uin="$USERINPUT"
	else
		doNextHistArg
		uin=$histarg
	fi

	uins="$uins¤$uin"
	F_ESCCHAR=1
}


#TODO 1st of all, take out repeated chars
getCharList(){
	gotoxy $x_prompt2 $y_prompt

	if [ "$f_i" == 1 ]
	then
		echo -n "${cP}"
		echo -n $"which?"
		echo -n " $cN"
		read -r USERINPUT
		uin="$USERINPUT"
	else
		doNextHistArg
		uin=$histarg
	fi
	uins="$uins¤$uin"

	# putting not special chars in not special places: [][^-]
	[ "${uin/^//}" != "$uin" ] && uin="${uin/^/}^"
	[ "${uin/-//}" != "$uin" ] && uin="${uin/-/}-"
	[ "${uin/[//}" != "$uin" ] && uin="[${uin/[/}"
	[ "${uin/]//}" != "$uin" ] && uin="]${uin/]/}"

	# if any $1, negated list
	[ "$1" ] && uin="^$uin"

	uin="[$uin]"
	F_ESCCHARLIST=1
}

getString(){
	gotoxy $x_prompt2 $y_prompt

	if [ "$f_i" == 1 ]
	then
		echo -ne "${cP}txt:$cN "
		read -r USERINPUT
		uin="$USERINPUT"
	else
		doNextHistArg
		uin=$histarg
	fi

	uins="$uins¤$uin"
	F_ESCCHAR=1
}

getNumber(){
	gotoxy $x_prompt2 $y_prompt

	if [ "$f_i" == 1 ]
	then
		echo -ne "${cP}N=$cN$_eol"
		read USERINPUT
		uin="$USERINPUT"
	else
		doNextHistArg
		uin=$histarg
	fi

	# Extracting !numbers
	uin="${uin//[^0-9]/}"

	# ee
	[ "${uin/666/x}" == 'x' ] && {
		gotoxy 36 1
		echo "$cP]:|$cN"
	}

	if [ "$uin" ]
	then
		uins="$uins¤$uin"
	else
		getNumber  # there _must_ be a number
	fi
}

getPosix(){
	local rpl psx=''
	unset SUBHUMAN

	if [ "$f_i" == 1 ]
	then
		Choice --reset "${posix_txt[@]}"
	else
		ChoiceAuto
	fi

	for rpl in $CHOICEREPLY
	do
		psx="$psx[:${posix_re[$rpl]}:]"
		SUBHUMAN="$SUBHUMAN, ${posix_txt[$rpl]/ (*)/}"
	done

	SUBHUMAN=${SUBHUMAN#, }
	F_POSIX=1

	uin="[$psx]"
	uins="$uins¤:${CHOICEREPLY// /}"
}

getCombo(){
	local rpl cmb=''
	unset SUBHUMAN

	if [ "$f_i" == 1 ]
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

	if [ "$1" == 'negated' ]
	then
		uin="[^$cmb]"
	else
		uin="[$cmb]"
	fi
	uins="$uins¤:${CHOICEREPLY// /}"
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
	[ "$x" == ',' -o "$x" == ' ' ] && x='<TAB>'
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
	[ "${ui/[\\\\$x]/}" != "$ui" ] && {

		for ((i=0; i<${#ui}; i++))  # for each user char
		do
			c="${ui:$i:1}"
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
	}
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
	unset REPLIES uins HUMAN Regex[*]
	GRP1=0
	GRP2=0
  	local p

	# global maxprogname
	maxprogname=$(getLargestItem "${progs[@]}")  # global var
	for p in ${progs[*]}
	do
		[ "$f_i" == 1 ] && printf " RegEx %-${#maxprogname}s: $_eol\n" "$p"
	done
}

showRegEx(){
	gotoxy $x_regex $y_regex
	local i save="$uin"

	# For each program
	for ((i=0 ;i<${#progs[@]}; i++))
	do
		[ "$F_ESCCHAR"     == 1 ] && escChar     $i
		[ "$F_ESCCHARLIST" == 1 ] && escCharList $i
		[ "$F_GETTAB"      == 1 ] && getListTab  $i
		[ "$F_POSIX"       == 1 ] && getHasPosix $i

		# Check status
		case "$1" in
			ax|S2)
				eval Regex[$i]="\${Regex[$i]}\${$1_${progs[$i]}[$REPLY]/@/$uin}"
			;;
			S0)
				Regex[$i]="${Regex[$i]}${S0_re[$REPLY]}"
			;;
			S1)
				Regex[$i]="${Regex[$i]}${uin:-${S1_re[$REPLY]}}"
			;;
		esac

		[ "$f_i" == 1 ] && printf " RegEx %-${#maxprogname}s: %s\n" "${progs[$i]}" "${Regex[$i]}"
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
	printf "  $cB%s$cN) %s%s " "$a" "$stat" "$opt"
}

# --reset resets the stat array
Choice(){
	[ "$1" == '--reset' ] && shift && local choicereset=1

	local alpha opts optxy numopts=$#
	local lines cols line line2 op alf rpl
	alpha=(a b c d e f g h i j k l m n o p q r s t u v w x y z)

	# Reading options and filling default status (off)
	i=0
	for opt in "$@"
	do
		opts[$i]="$opt"
		[ "$choicereset" ] && stat[$i]='-'
		i=$((i+1))
	done

	# Checking our number of items limit
	[ $numopts -gt "${#alpha[*]}" ] && {
		printf "too much itens (>%d)" "${#alpha[*]}"
		exit 1
	}

	# The header
	Clear
	printTitleCmd '.' $"exit"
	printf "| %s" $"press the letters to (un)select the items"

	# We will need 2 columns?
	cols=1
	[ "$numopts" -gt 10 ] && cols=2

	# And how much lines? (remember: odd number of items, requires one more line)
	lines=$((numopts/cols))
	[ "$((numopts%cols))" -eq 1 ] && lines=$((lines+1))

	# Filling the options screen's position array (+3 = header:2, sek:1)
	for ((line=0; line<$lines; line++))
	do
		# Column 1
		optxy[$line]="$((line+3));1"

		# Column 2
		[ "$cols" == 2 ] && optxy[$((line+lines))]="$((line+3));40"
	done

	# Showing initial status for all options
	for ((op=0; op<$numopts; op++))
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
				for ((alf=0; alf<$numopts; alf++))
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
				[ "${opts[alf]}" ] || continue
				ChoiceRefresh "${optxy[$alf]}" "${alpha[$alf]}" "${stat[$alf]}" "${opts[$alf]}"
			;;
			.)
				# Getting the user choices and exiting
				unset CHOICEREPLY
				for ((rpl=0; rpl<$numopts; rpl++))
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
			HUMAN="$S0_txt ${S0_txt[$REPLY]}"
			showRegEx S0
			STATUS=1
		;;
		1)
			TopTitle
			Menu S1_txt
			if [ "${REPLY/[1-9]/}" ]
			then
				HUMAN="$HUMAN $REPLY"
				if [ "$REPLY" == '|' ]
				then
					REPLY=1
				elif [ "$REPLY" == '(' ]
				then
					REPLY=2
					GRP1=$((GRP1+1))
				elif [ "$REPLY" == ')' ]
				then
					REPLY=3
					GRP2=$((GRP2+1))
				else
					echo -e "\n\nERROR: unknowm reply type '$REPLY'"
					exit 1
				fi
				showRegEx ax
			else
				HUMAN="$HUMAN, $S1_txt ${S1_txt[$REPLY]/ (*)/}"
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
				showRegEx S1
			fi
		;;
		12)
			[ "$REPLY" -eq 6  ] && STATUS=2 && getCombo
			[ "$REPLY" -eq 7  ] && STATUS=2 && getPosix
			[ "$REPLY" -eq 8  ] && STATUS=1 && getREady
			Clear
			TopTitle
			HUMAN="$HUMAN {$SUBHUMAN}"
			showRegEx S1
		;;
		2)
			TopTitle
			Menu S2_txt
			rep_middle=$"repeated"
			rep_txt="${S2_txt[$REPLY]}"
			rep_txtend=$"times"

			[ "$REPLY" -ge 5 ] && getNumber && rep_txt=${rep_txt/N/$uin}
			HUMAN="$HUMAN, $rep_middle ${rep_txt/ (*)/} $rep_txtend"
			showRegEx S2
			STATUS=1
		;;
		3)
			[ "$f_i" != 1 ] && {
				STATUS=9
				continue
			}
			warning=$"Really quit?"
			read -n 1 -p "..$cB $warning [.] $cN"
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
				i=$((i+1))
			done
			ScreenSize
			Clear
			STATUS=0
		;;
		9)
			gotoxy $x_hist $y_hist
			clearEnd
			if [ "$f_i" == 1 ]
			then
				noregex_txt=$"no regex"
				printf "$cB%s '%s%s'$cN\n\n" "txt2regex --history" "$REPLIES" "$uins"
				echo -e "${HUMAN:-$noregex_txt}.\n"
			else
				for ((i=0; i<${#progs[@]}; i++))  # for each program
				do
					printf " RegEx %-${#maxprogname}s: %s\n" "${progs[$i]}" "${Regex[$i]}"
				done
				echo
			fi
			exit 0
		;;
		*)
			echo "Error: STATUS = '$STATUS'"
			exit 1
		;;
	esac
done
