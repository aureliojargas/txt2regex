#!/bin/bash
# txt2regexp.sh - Regular Expressions "wizard", all in bash2 builtins
# http://conectiva.com.br/~aurelio/programas/bash/txt2regexp
#
# it's GPL. use at your own risk. don't kill koalas.
#
# A T T E N T I O N: only works in bash >= 2.04 
#  
# all REs for the S2_PROG arrays was taken from the PROG man page
# or missing it, from the 'mastering regular expressions' book
#
# versions tested:
# ed: GNU ed version 0.2
# egrep: egrep (GNU grep) 2.4.2
# find: GNU find version 4.1
# gawk: GNU Awk 3.0.4
# grep: grep (GNU grep) 2.4.2
# mawk: mawk 1.2
# sed: GNU sed version 3.02.80
# vim: VIM - Vi IMproved 5.7
# php: 3.0.18 and 4.0.3pl1
#
# $STATUS:
#   0 begining of the regexp
#   1 defining regexp
#   12 defining type of letters
#   2 defining quantifier
#   3 end of the regexp
#   4 defining session programs
#
# 20001019 <aurelio@conectiva.com.br> ** 1st version
# 20001026 <aurelio@conectiva.com.br> ++ lots of changes and tests
# 20001028 <aurelio@conectiva.com.br> ++ improvements, public release
# 20001107 <aurelio@conectiva.com.br> ++ bash version check (thanks eliphas)
# 20001113 <aurelio@conectiva.com.br> ++ php support, Progs command
# 20010223 <aurelio@conectiva.com.br> ++ i18n, --all, fmeat announce (oh no!)
# v0.1
#
# TODO capture blanks on Get* (via menu)
# TODO create [] mixing letters/numbers/blanks
# TODO EscChar - delimiters too? like / (sed, *awk)
# TODO expr, oawk, nawk, MKS awk, flex
# TODO s/vi/n&/
# TODO use new 'for' ksh syntax
# TODO ~/.txt2regexprc - keep programs, last REs/histories

TEXTDOMAIN=txt2regexp
TEXTDOMAINDIR=po

# we _need_ bash>=2.04
case "$BASH_VERSION" in
  2.0[4-9]*|2.[1-9]*):;;
  *)echo "bash version >=2.04 required, but you have $BASH_VERSION"; exit 1;;
esac


# take out from here programs you don't want to know about
# or to minimize the lines printed on the screen
progs=(emacs gawk grep perl php python sed vim)

# the RegExp show
allprogs=(awk ed egrep emacs expect find gawk grep lex lisp mawk perl php python sed tcl vi vim)
[ "$1" == '--all' ] &&
  progs=(${allprogs[@]})

# texts on var because i18n inside arrays is not possible
S0_TXT0=$"start to match"; S0_TXT1=$"on the line beginning"
S0_TXT2=$"in any part of the line"

S1_TXT0=$"followed by"; S1_TXT1=$"numbers only"; S1_TXT2=$"letters only";
S1_TXT3=$"letters and numbers"; S1_TXT4=$"any character";
S1_TXT5=$"a specific character"; S1_TXT6=$"an allowed characters list";
S1_TXT7=$"a forbidden characters list"; S1_TXT8=$"a literal string";
S1_TXT9=$"anything"

S12_TXT0=$"type of the letters"; S12_TXT1=$"uppercase only"
S12_TXT2=$"lowercase only"; S12_TXT3=$"upper and lowercase"

S2_TXT0=$"how many times (repetition)"; S2_TXT1=$"one"
S2_TXT2=$"zero or one (optional)"; S2_TXT3=$"zero or more"
S2_TXT4=$"one or more"; S2_TXT5=$"exactly N"; S2_TXT6=$"up to N"
S2_TXT7=$"at least N"

AX_TXT0=$"details"; AX_TXT1=$"grouping"; AX_TXT2=$"alternatives"
AX_TXT3=$"escape normal"; AX_TXT4=$"escape list []"

# defining text arrays
 S0_txt=("$S0_TXT0" "$S0_TXT1" "$S0_TXT2")
 S1_txt=("$S1_TXT0" "$S1_TXT1" "$S1_TXT2" "$S1_TXT3" "$S1_TXT4" "$S1_TXT5"\
         "$S1_TXT6" "$S1_TXT7" "$S1_TXT8" "$S1_TXT9")
 S2_txt=("$S2_TXT0" "$S2_TXT1" "$S2_TXT2" "$S2_TXT3" "$S2_TXT4" "$S2_TXT5"\
         "$S2_TXT6" "$S2_TXT7")
 ax_txt=("$AX_TXT0" "$AX_TXT1" "$AX_TXT2" "$AX_TXT4" "$AX_TXT5")
S12_txt=("$S12_TXT0" "$S12_TXT1" "$S12_TXT2" "$S12_TXT3")

set -o noglob

alpha=(a b c d e f g h i j k l m n o p q r s t u v w x y)
# here's all the RegExps arrays
S0_re=('' '^' '')
S1_re=( '' '[0-9]' '' '0-9' '.' '' '' '' '' '.*')
S12_re=( '' 'A-Z' 'a-z' 'A-Za-z')
S2_sed=(   '' '' '\?' '*' '\+' '\{@\}' '\{1,@\}' '\{@,\}')
S2_ed=(    '' '' '\?' '*' '\+' '\{@\}' '\{1,@\}' '\{@,\}')
S2_grep=(  '' '' '\?' '*' '\+' '\{@\}' '\{1,@\}' '\{@,\}')
S2_vim=(   '' '' '\=' '*' '\+' '\{@}'  '\{1,@}'  '\{@,}' )
S2_egrep=( '' ''  '?' '*'  '+'  '{@}'   '{1,@}'   '{@,}' )
S2_php=(   '' ''  '?' '*'  '+'  '{@}'   '{1,@}'   '{@,}' )
S2_python=('' ''  '?' '*'  '+'  '{@}'   '{1,@}'   '{@,}' )
S2_lex=(   '' ''  '?' '*'  '+'  '{@}'   '{1,@}'   '{@,}' )
S2_perl=(  '' ''  '?' '*'  '+'  '{@}'   '{1,@}'   '{@,}' )
S2_gawk=(  '' ''  '?' '*'  '+'  '{@}'   '{1,@}'   '{@,}' )
S2_mawk=(  '' ''  '?' '*'  '+'  '!!'    '!!'      '!!'   )
S2_awk=(   '' ''  '?' '*'  '+'  '!!'    '!!'      '!!'   )
S2_find=(  '' ''  '?' '*'  '+'  '!!'    '!!'      '!!'   )
S2_emacs=( '' ''  '?' '*'  '+'  '!!'    '!!'      '!!'   )
S2_lisp=(  '' ''  '?' '*'  '+'  '!!'    '!!'      '!!'   )
S2_tcl=(   '' ''  '?' '*'  '+'  '!!'    '!!'      '!!'   )
S2_expect=('' ''  '?' '*'  '+'  '!!'    '!!'      '!!'   )
S2_vi=(    '' '' '\?' '*' '\+'  '__'    '__'      '__'   )
#63# cause on table 6-1 it seems that the vi part is wrong

### mastering regular expressions:
# egrep 29 1-3
# .* 182 6-1
# grep 183 6-2
# *awk 184 6-3
# tcl 189 6-4
# emacs 194 6-7
# perl 201 7-1
### other:
# php 4.0.3pl1 docs (POSIX 1003.2 extended regular expressions)


# tst: \/_$[]{}()|+?^_/p
# [gm]awk = egrep
#                              \.*[]{}()|+?^$   ,=tested  space=pending
ax_ed=(    ''  '\(,\)'   '\|' '\.*[,,,,,,,,,,' ',')
ax_vim=(   ''  '\(,\)'   '\|' '\.*[,,,,,,,,,,' '\')
ax_sed=(   ''  '\(,\)'   '\|' '\.*[,,,,,,,,,,' ',')
ax_grep=(  ''  '\(,\)'   '\|' '\.*[,,,,,,,,,,' ',')
ax_find=(  ''  '\(,\)'   '\|' '\.*[,,,,,,+?,,' ',')
ax_egrep=( ''   '(,)'     '|' '\.*[,{,()|+?^$' ',')
ax_php=(   ''   '(,)'     '|' '\.*[,{,(,|+?^$' ',')
ax_python=(''   '(,)'     '|' '\.*[,{,()|+?  ' '\')
ax_lex=(   ''   '(,)'     '|' '\.*[ { ( |+?  ' ' ')
ax_perl=(  ''   '(,)'     '|' '\.*[ { ( |+?  ' '\')
ax_gawk=(  ''   '(,)'     '|' '\.*[,,,(,|+?^$' '\')
ax_mawk=(  ''   '(,)'     '|' '\.*[,,,()|+?^$' '\')
ax_awk=(   ''   '(,)'     '|' '\.*[   (,|+?  ' '\')
ax_emacs=( ''  '\(,\)'   '\|' '\.*[      +?  ' ',')
ax_lisp=(  '' '\\(,\\)' '\\|' '\.*[      +?  ' ',')
ax_tcl=(   ''   '(,)'     '|' '\.*[   ( |+?  ' ',')
ax_expect=(''   '(,)'     '|' '\.*[   ( |+?  ' ' ')
ax_vi=(    ''  '\(,\)'   '!!' '\.*[          ' ' ')
#194# emacs: a backslash ... it is completely unspecial
#189# tcl: withing a class, a backslash is completely unspecial

ScreenSize(){
# screen size/positioning issues
  x_regexp=1 ; y_regexp=3
  x_hist=3   ; y_hist=$((y_regexp+${#progs[*]}+1))
  x_prompt=3 ; y_prompt=$((y_regexp+${#progs[*]}+2))
  x_menu=3   ; y_menu=$((y_prompt+2))
  x_prompt2=15
  y_max=$((y_menu+${#S1_txt[*]}))
  screensize=`stty size`
  [ "${screensize% *}" -lt "$y_max" ] && { printf $"error:
  your screen has %s lines and should have at least %s to this
  program fit on it. increase the number of lines or select
  less programs to show the RegExp.\n\n" "${screensize% *}" "$y_max"
  exit 1
  }
}


_eol=`echo -ne "\033[0K"`  # clear trash until EOL

# the cool functions
gotoxy(){ echo -ne "\033[$2;$1H" ;}
ClearEnd(){ echo -ne "\033[0J"; }

ColorOnOff(){
  if [ "$cN" ]
  then unset cN cR cY cW
  else cN=`echo -ne "\033[m"`      # normal
       cR=`echo -ne "\033[1;31m"`  # red
       cY=`echo -ne "\033[1;33m"`  # yellow
       cW=`echo -ne "\033[1;37m"`  # white
  fi
  TopTitle
}

TopTitle(){ gotoxy 1 1 
  echo -n  "${cY}[.]${cN}"; echo -n $"quit"  
  echo -n " ${cY}[0]${cN}"; echo -n $"reset"
  echo -n " ${cY}[*]${cN}"; echo -n $"color"
  if [ $STATUS -eq 0 ]
  then echo -n " ${cY}[/]${cN}"; echo -n $"progs"
  else echo '            '
  fi
  gotoxy 44 ;
  printf $"%s unknown  %s not supported" "${cW}__$cN" "$cW!!$cN"
}

ProgsTitle(){ gotoxy 1 1 
  echo -n "${cY}[.]${cN}"; echo -n $"exit" ; echo -n ' | '
  echo $"press the letters to (un)select the programs"
}

DoMenu(){
  eval Menui=(\"\${$1[@]}\"); menu_n=$((${#Menui[*]}-1))  # ini
  gotoxy $x_hist $y_hist ; echo "   $cR.oO($cN$REPLIES$cR)$cN$_eol"   # history
  gotoxy $x_menu $y_menu ; echo "$cY${Menui[0]}:$cN$_eol" # title
  for i in `seq $menu_n`                                  # itens
  do echo "  $cW$i$cN) ${Menui[$i]}$_eol"; i=$((i+1)); done
  ClearEnd                                                # prompt
  gotoxy $x_prompt $y_prompt ; echo -ne "$cR[1-$menu_n]:$cN $_eol"
  read -n 1
}

Menu(){
  DoMenu "$1"
  case "$REPLY" in
    [1-9])if [ "$REPLY" -gt "$menu_n" ]
          then Menu "$1" ; else REPLIES="$REPLIES$REPLY"; fi;;
        .)STATUS=3 ;; 0)STATUS=0 ;; \*)ColorOnOff; Menu "$1";;
	    /)STATUS=4 ;;
        *)Menu "$1";;
  esac
  [ "${STATUS/[034]/}" ] || continue         # 0,3,4: escape status
}

GetChar(){ gotoxy $x_prompt2 $y_prompt
  echo -n "${cR}"; echo -n $"which one?"; echo -n " $cN"
  read -n 1 -r USERINPUT; uin="$USERINPUT"; F_ESCCHAR=1
}


#TODO 1st of all, take out repeated chars
GetCharList(){ gotoxy $x_prompt2 $y_prompt
  echo -n "${cR}"; echo -n $"which?"; echo -n " $cN"
  read -r USERINPUT; uin="$USERINPUT"
  # putting not special chars in not special places: [][^-]
  [ "${uin/^//}" != "$uin" ] && uin="${uin/^/}^"
  [ "${uin/-//}" != "$uin" ] && uin="${uin/-/}-"
  [ "${uin/[//}" != "$uin" ] && uin="[${uin/[/}"
  [ "${uin/]//}" != "$uin" ] && uin="]${uin/]/}"
  [ "$1" ] && uin="^$uin"                   # if any $1, negated list
  uin="[$uin]"
  F_ESCCHARLIST=1
}

GetString(){ gotoxy $x_prompt2 $y_prompt
  echo -ne "${cR}txt:$cN " ; read -r USERINPUT ; uin="$USERINPUT"
  F_ESCCHAR=1
}

GetNumber(){ gotoxy $x_prompt2 $y_prompt
  echo -ne "${cR}N=$cN$_eol" ; read USERINPUT
  uin="${USERINPUT//[^0-9]/}"               # extracting !numbers
  [ "${uin/666/x}" == 'x' ] && { gotoxy 36 1 ; echo "$cR]:|$cN" ; } # ee
  [ "$uin" ] || GetNumber                   # there _must_ be a number
}

EscChar(){ # escape userinput chars as .,*,[ and friends
  local c x x2 z i ui esc
  esc='\'; [ "$1" == 'lisp' ] && esc='\\'   # double escape for lisp
  ui="$uin"
  eval x=\"\${ax_$1[3]}\" ; x="${x//[, ]/}" # list of escapable chars
  [ "${ui/[\\\\$x]/}" != "$ui" ] && {       # test for speed up
    for i in `seq 0 $((${#ui}-1))`          # for each user char
    do c="${ui:$i:1}"
       case "$c" in                         # special bash chars
         [?*#%])x2="${x/[$c]/}";;
           [/}])x2="${x/\\$c/}";;
           [\\])x2="${x/$c$c/}";;
              *)x2="${x/$c/}"  ;;
       esac
       [ "$x2" != "$x" ] && c="$esc$c"      # escaping
       z="$z$c"
    done
    uin="$z"                                # ah, the escaped string
  }
}

EscCharList(){
  local x esc='\' ; eval x=\"\${ax_$1[4]}\"
  [ "$x" == '\' ] && uin="${uin/\\\\/$esc$esc}" # escaping escape
}

Reset(){ gotoxy $x_regexp $y_regexp
  unset REPLIES HUMAN Regexp[*]
  for p in ${progs[*]}; do printf " RegExp %-6s: $_eol\n" "$p"; done
}

ShowRegExp(){ gotoxy $x_regexp $y_regexp
  local i save="$uin"
  for i in `seq 0 $((${#progs[*]}-1))`      # for each program
  do [ "$F_ESCCHAR"     == '1' ] && EscChar     ${progs[$i]}
     [ "$F_ESCCHARLIST" == '1' ] && EscCharList ${progs[$i]}
     case "$1" in                           # check status
       S2) eval Regexp[$i]="\${Regexp[$i]}\${S2_${progs[$i]}[$REPLY]/@/$uin}";;
       S0) Regexp[$i]="${Regexp[$i]}${S0_re[$REPLY]}";;
       S1) Regexp[$i]="${Regexp[$i]}${uin:-${S1_re[$REPLY]}}";;
      S12) Regexp[$i]="${Regexp[$i]}$TMP_RE";;
     esac
     printf " RegExp %-6s: %s\n" "${progs[$i]}" "${Regexp[$i]}"
     uin="$save"
  done
  unset uin USERINPUT F_ESCCHAR F_ESCCHARLIST
}

SyncActiveProgs(){
  local p i=0 ps=" ${progs[*]} "

  for i in `seq 0 $((${#allprogs[*]}-1))`   # for each program
  do p="${allprogs[$i]}"
	 progsflag[$i]='-'; [ "${ps/ $p /}" != "$ps" ] && progsflag[$i]='+'
  done
}

SyncNewProgs(){
  local i i2=0
  
  unset progs[*]
  for i in `seq 0 $((${#progsflag[*]}-1))`  # for each program
  do if [ "${progsflag[$i]}" == '+' ]
     then progs[$i2]="${allprogs[$i]}"
	      i2=$((i2+1))
     fi		  
  done
}

ProgsOnOff(){
local i
for i in `seq 0 $((${#allprogs[*]}-1))`     # for each program
do if [ "${alpha[$i]}" == "$1" ]
   then if [ "${progsflag[$i]}" == '+' ]
        then progsflag[$i]='-'
		else progsflag[$i]='+'
		fi
   fi
done
}


ShowProgs(){ gotoxy 1 3
  local i i2 n tot=${#allprogs[*]} 
  n=$((tot/2)) 
  [ "$((tot%2))" -eq 1 ] && n=$((n+1)) 
  
  for i in `seq 0 $((n-1))`                 # for each program
  do i2=$((i+n)) ;
     x11="$cW${alpha[$i]}$cN)"
	 x12="${progsflag[$i]}" ; [ "$x12" == '+' ] && x12="$cY$x12$cN"
	 x13="${allprogs[$i]}"
     
	 if [ $i2 -lt $tot ]
	 then x21="$cW${alpha[$i2]}$cN)"
	      x22="${progsflag[$i2]}"; [ "$x22" == '+' ] && x22="$cY$x22$cN"
	      x23="${allprogs[$i2]}"
     else unset x21 x22 x23		  
     fi
	 
     printf "  %s %s%-15s %s %s%-15s\n"	$x11 $x12 $x13 $x21 $x22 $x23
     i=$((i+1));
  done

  echo ; printf $"choose"; echo -n ": $_eol" ; read -n 1

  case "$REPLY" in
   [a-y]) ProgsOnOff $REPLY; ShowProgs;;
       .) SyncNewProgs;;
	   *) ShowProgs;;
  esac  
}


clear
STATUS=0
ScreenSize
ColorOnOff

while : ; do
case ${STATUS:=0} in
 0) Reset
    TopTitle
    STATUS=1
    Menu S0_txt
    HUMAN="$S0_txt ${S0_txt[$REPLY]}"
    ShowRegExp S0
    STATUS=1
    ;;
 1) TopTitle
    Menu S1_txt
    TMP_RE="${S1_re[$REPLY]}"
    HUMAN="$HUMAN, $S1_txt ${S1_txt[$REPLY]}"
    [ "$REPLY" -eq 2 ] && STATUS=12 && continue
    [ "$REPLY" -eq 3 ] && STATUS=12 && continue
    [ "$REPLY" -eq 5 ] && GetChar
    [ "$REPLY" -eq 6 ] && GetCharList
    [ "$REPLY" -eq 7 ] && GetCharList negated
    STATUS=2
    [ "$REPLY" -eq 8 ] && GetString && STATUS=1
    [ "$REPLY" -eq 9 ] && STATUS=1
    ShowRegExp S1
    ;;
12) Menu S12_txt
    TMP_RE="[$TMP_RE${S12_re[$REPLY]}]"
    ShowRegExp S12
    STATUS=2
    ;;
 2) Menu S2_txt
    [ "$REPLY" -ge 5 ] && GetNumber
    repetition_txt=$"time(s)"
    HUMAN="$HUMAN, ${S2_txt[$REPLY]} $repetition_txt"
    ShowRegExp S2
    STATUS=1
    ;;
 3) echo -ne "\033[0G" ; ClearEnd
    echo -e "\n  ${HUMAN:-no RegExp}.\n"
    exit 0
    ;;
 4) 
    SyncActiveProgs
	gotoxy 1 1 ; ClearEnd
	ProgsTitle
    ShowProgs
	ScreenSize
	clear
    STATUS=0
    ;;
 *) echo "Error: STATUS = $STATUS"
    exit 1
    ;;
esac
done

# vim: tw=80 et
