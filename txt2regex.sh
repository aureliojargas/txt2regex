#!/bin/bash
# txt2regex.sh - Regular Expressions "wizard", all in bash2 builtins
# http://txt2regex.sourceforge.net
#
# please, read the README file.
#
# - it's GPL. use at your own risk. don't kill koalas.
# - A T T E N T I O N: only works in bash >= 2.04
# - all REs for the S2_PROG arrays was taken from the PROG man page
#   or missing it, from the 'mastering regular expressions' book
# - programs versions tested
#     ed: GNU ed version 0.2
#     egrep: egrep (GNU grep) 2.4.2
#     find: GNU find version 4.1
#     gawk: GNU Awk 3.0.4
#     grep: grep (GNU grep) 2.4.2
#     mawk: mawk 1.2
#     sed: GNU sed version 3.02.80
#     vim: VIM - Vi IMproved 5.7
#     php: 3.0.18 and 4.0.3pl1
#
# $STATUS:
#   0  begining of the regex
#   1  defining regex
#   12 choosing subregex
#   2  defining quantifier
#   3  end of the regex
#   4  choosing session programs
#
# 20001019 <verde@verde666.org> ** 1st version
# 20001026 <verde@...> ++ lots of changes and tests
# 20001028 <verde@...> ++ improvements, public release
# 20001107 <verde@...> ++ bash version check (thanks eliphas)
# 20001113 <verde@...> ++ php support, Progs command
# 20010223 <verde@...> ++ i18n, --all, fmeat announce (oh no!)
# 20010223 v0.1
# 20010420 <verde@...> ++ id.po, \lfunction_name, s/regexp/regex/ig
# 20010423 <verde@...> ++ --nocolor, --history, Usage(), doNextHist{,Args}()
#                      ++ flags: interative, color, allprogs
#                      ++ .oO(¤user parameters history)
# 20010424 v0.2
# 20010606 <verde@...> ++ option --whitebg
#                      -- grep from $progs to fit on 24 lines by default
# 20010608 <verde@...> -- clear command (not bash), ++ Clear()
#                      -- stty command (not bash), ++ $LINES
#                      -- *Progs*(), ++ Choice(), ChoiceRefresh()
#                      ++ POSIX character classes [[:abc:]]
#                      ++ special combinations inside []
#                      ++ $HUMAN improved with getString, getNumber, Choice
#                      ++ detailed --help, sorceforge'd
# 20010613 v0.3
# 20010620 <verde@...> -- seq command (not bash), ++ sek()
# 20010613 v0.3.1
#
# TODO negated POSIX|special combination (Choice hack)
# TODO on --history, just show the final RE at once?
# TODO add expr, oawk, nawk, MKS awk, flex
# TODO s/vi/n&/ - can't reach real vi
# TODO vim with NO magic (quote bram)
# TODO use new 'for' ksh syntax instead i=$((i+1))
# ---- (user's requests) ----
# TODO undo last step (Bence Fejervari @ .hu)
# TODO std{in,out} mode to use it with a frontend (Robert-Claudiu Gheorghe @ .com)
# TODO interface to feed the programs with the RegEx (Chris Piechowicz @ .au)
# ---- (~/.txt2regexrc) ----
# - remember programs, last histories, name REs
# ---- (non-interative mode) ----
# TODO ready-to-use common regexes (email, date, ip, etc)
# hour: [012][0-9]:[0-5][0-9] -=- 00:00 -> 29:59
#       [0-9]{2}:[0-9]{2}     -=- 00:00 -> 99:99
# date mm/dd/yyyy: [01][0-9]/[0-3][0-9]/[12][0-9]{3} -=- 00/00/1000 -> 19/39/2999
#                  [0-9]{2}/[0-9]{2}/[0-9]{4}        -=- 00/00/0000 -> 99/99/9999
# email: [A-Za-z0-9_.-]+@[A-Za-z0-9_.]+
#        [^@ ]+@[^@ ]+
# rg: [0-9]\.[0-9]{3}\.[0-9]{3}-[0-9]
#
# TODO LATER how to capture blanks on Get* (via menu)?
# TODO LATER user defined ranges on lists (prompt, validation)

TEXTDOMAIN=txt2regex
TEXTDOMAINDIR=po

# we _need_ bash>=2.04
case "$BASH_VERSION" in
  2.0[4-9]*|2.[1-9]*):;;
  *)echo "bash version >=2.04 required, but you have $BASH_VERSION"; exit 1;;
esac

Usage(){
  echo $"\
usage: txt2regex [--history <value>] [--nocolor|--whitebg|--all]

OPTIONS (they are default OFF):

  --all              works with all registered programs
  --nocolor          self-explanatory
  --whitebg          colors adjusted to white background terminals
  --history <value>  prints to STDOUT a RegEx from a history data

for more details about the options, read the README file."
  exit 1
}

# the defaults
f_i=1
f_color=1
f_whitebg=0
f_allprogs=0


# parsing options
while [ $# -gt 0 ]
do case "$1" in
    --history) [ "$2" ] || Usage; history="$2"; shift; f_i=0 ; f_color=0
               hists="0${history%%¤*}" ; histargs="¤${history#*¤}"
               [ "${hists#0}" == "${histargs#¤}" ] && unset histargs ;;
    --nocolor) f_color=0 ;;
    --whitebg) f_whitebg=1 ;;
        --all) f_allprogs=1 ;;
            *) Usage;;
   esac
   shift
done


# take out from here programs you don't want to know about
# or to minimize the lines printed on the screen
progs=(emacs gawk perl php python sed vim)

# the RegEx show
allprogs=(awk ed egrep emacs expect find gawk grep lex lisp mawk perl php python sed tcl vi vim)
[ "$f_allprogs" == 1 ] && progs=(${allprogs[@]})

# texts on var because i18n inside arrays is not possible
S0_TXT0=$"start to match"; S0_TXT1=$"on the line beginning"
S0_TXT2=$"in any part of the line"

S1_TXT0=$"followed by"; S1_TXT1=$"any character"
S1_TXT2=$"a specific character"; S1_TXT3=$"a literal string"
S1_TXT4=$"an allowed characters list"; S1_TXT5=$"a forbidden characters list"
S1_TXT6=$"a special combination"; S1_TXT7=$"a POSIX combination (locale aware)"
S1_TXT8=$"a ready RegEx (not implemented)"; S1_TXT9=$"anything"

S12_TXT0=$"type of the letters"; S12_TXT1=$"uppercase only"
S12_TXT2=$"lowercase only"; S12_TXT3=$"upper and lowercase"

S2_TXT0=$"how many times (repetition)"; S2_TXT1=$"one"
S2_TXT2=$"zero or one (optional)"; S2_TXT3=$"zero or more"
S2_TXT4=$"one or more"; S2_TXT5=$"exactly N"; S2_TXT6=$"up to N"
S2_TXT7=$"at least N"

COMBO_TXT0=$"uppercase letters"
COMBO_TXT1=$"lowercase letters"
COMBO_TXT2=$"numbers"
COMBO_TXT3=$"underscore"
COMBO_TXT4=$"space"
COMBO_TXT5=$"TAB"

#TODO put all posix components?
POSIX_TXT0=$"letters"
POSIX_TXT1=$"lowercase letters"
POSIX_TXT2=$"uppercase letters"
POSIX_TXT3=$"numbers"
POSIX_TXT4=$"letters and numbers"
POSIX_TXT5=$"hexadecimal numbers"
POSIX_TXT6=$"whitespaces (space and TAB)"
POSIX_TXT7=$"graphic chars (not-whitespace)"


# defining text arrays
combo_txt=("$COMBO_TXT0" "$COMBO_TXT1" "$COMBO_TXT2" "$COMBO_TXT3"\
           "$COMBO_TXT4" "$COMBO_TXT5")
posix_txt=("$POSIX_TXT0" "$POSIX_TXT1" "$POSIX_TXT2" "$POSIX_TXT3"\
           "$POSIX_TXT4" "$POSIX_TXT5" "$POSIX_TXT6" "$POSIX_TXT7")
 S0_txt=("$S0_TXT0" "$S0_TXT1" "$S0_TXT2")
 S1_txt=("$S1_TXT0" "$S1_TXT1" "$S1_TXT2" "$S1_TXT3" "$S1_TXT4" "$S1_TXT5"\
         "$S1_TXT6" "$S1_TXT7" "$S1_TXT8" "$S1_TXT9")
 S2_txt=("$S2_TXT0" "$S2_TXT1" "$S2_TXT2" "$S2_TXT3" "$S2_TXT4" "$S2_TXT5"\
         "$S2_TXT6" "$S2_TXT7")
 ax_txt=("$AX_TXT0" "$AX_TXT1" "$AX_TXT2" "$AX_TXT4" "$AX_TXT5")
S12_txt=("$S12_TXT0" "$S12_TXT1" "$S12_TXT2" "$S12_TXT3")

set -o noglob

# here's all the RegExs arrays
POSIX=('alpha' 'lower' 'upper' 'digit' 'alnum' 'xdigit' 'blank' 'graph')
COMBO=('A-Z' 'a-z' '0-9' '_' ' ' '@')
S0_re=('' '^' '')
S1_re=('' '.' '' '' '' '' '' '' '' '.*')
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


# tst: \/_$[]{}()|+?^_/p , [gm]awk=egrep, lisp=emacs
# [[:abc:]]: Invalid character class name
#details,grouping,alternatives,escape normal,escape inside [],[:POSIX:],TAB inside []
#                              \.*[]{}()|+?^$   ,=tested  space=pending
ax_ed=(    ''  '\(,\)'   '\|' '\.*[,,,,,,,,,,' ',' 'P' ',')
ax_vim=(   ''  '\(,\)'   '\|' '\.*[,,,,,,,,,,' '\' 'P' '\t')
ax_sed=(   ''  '\(,\)'   '\|' '\.*[,,,,,,,,,,' ',' 'P' '\t')
ax_grep=(  ''  '\(,\)'   '\|' '\.*[,,,,,,,,,,' ',' 'P' ',')
ax_find=(  ''  '\(,\)'   '\|' '\.*[,,,,,,+?,,' ',' ',' ',')
ax_egrep=( ''   '(,)'     '|' '\.*[,{,()|+?^$' ',' 'P' ',')
ax_php=(   ''   '(,)'     '|' '\.*[,{,(,|+?^$' ',' 'P' '\t')
ax_python=(''   '(,)'     '|' '\.*[,{,()|+?^$' '\' ',' '\t')
ax_lex=(   ''   '(,)'     '|' '\.*[ { ( |+?  ' ' ' ' ' ' ')
ax_perl=(  ''   '(,)'     '|' '\.*[ { ( |+?  ' '\' ' ' '\t')
ax_gawk=(  ''   '(,)'     '|' '\.*[,,,(,|+?^$' '\' 'P' '\t')
ax_mawk=(  ''   '(,)'     '|' '\.*[,,,()|+?^$' '\' ',' '\t')
ax_awk=(   ''   '(,)'     '|' '\.*[   (,|+?  ' '\' ',' '\t')
ax_emacs=( ''  '\(,\)'   '\|' '\.*[      +?  ' ',' ',' ',')
ax_lisp=(  '' '\\(,\\)' '\\|' '\.*[      +?  ' ',' ',' ',')
ax_tcl=(   ''   '(,)'     '|' '\.*[   ( |+?  ' ',' ' ' ' ')
ax_expect=(''   '(,)'     '|' '\.*[   ( |+?  ' ' ' ' ' ' ')
ax_vi=(    ''  '\(,\)'   '!!' '\.*[          ' ' ' ' ' ' ')
#194# emacs: a backslash ... it is completely unspecial
#78#  emacs: it uses \s for special "syntax classes"
#189# tcl: withing a class, a backslash is completely unspecial

ScreenSize(){
# screen size/positioning issues
  x_regex=1  ; y_regex=3
  x_hist=3   ; y_hist=$((y_regex+${#progs[*]}+1))
  x_prompt=3 ; y_prompt=$((y_regex+${#progs[*]}+2))
  x_menu=3   ; y_menu=$((y_prompt+2))
  x_prompt2=15
  y_max=$((y_menu+${#S1_txt[*]}))
  [ "${LINES:=24}" -lt "$y_max" ] && { printf $"error:
  your screen has %s lines and should have at least %s to this
  program fit on it. increase the number of lines or select
  less programs to show the RegEx.\n\n" "$LINES" "$y_max"
  exit 1
  }
}


_eol=`echo -ne "\033[0K"`  # clear trash until EOL

# the cool functions
gotoxy(){ echo -ne "\033[$2;$1H" ;}
clearEnd(){ echo -ne "\033[0J"; }
Clear(){ gotoxy 1 1; clearEnd; }


sek(){
  local H='<' s='++' a=1 z=$1; [ "$2" ] && { a=$1; z=$2; }
  [ $a -gt $z ] && { H='>'; s='--'; }; for ((i=$a;i$H=$z;i$s)); do echo $i; done
}


ColorOnOff(){
  # the colors: Normal, Prompt, Bold, Important
  [ "$f_color" != 1 ] && return
  if [ "$cN" ]; then
    unset cN cP cB cI
  elif [ "$f_whitebg" != 1 ]; then
    cN=`echo -ne "\033[m"`      # normal
    cP=`echo -ne "\033[1;31m"`  # red
    cB=`echo -ne "\033[1;37m"`  # white
    cI=`echo -ne "\033[1;33m"`  # yellow
  else
    cN=`echo -ne "\033[m"`      # normal
    cP=`echo -ne "\033[31m"`    # red
    cB=`echo -ne "\033[32m"`    # green
    cI=`echo -ne "\033[34m"`    # blue
  fi
  TopTitle
}

TopTitle(){ gotoxy 1 1
  [ "$f_i" != 1 ] && return
  echo -n  "${cI}[.]${cN}"; echo -n $"quit"
  echo -n " ${cI}[0]${cN}"; echo -n $"reset"
  [ "$f_color" == 1 ] &&
    echo -n " ${cI}[*]${cN}"; echo -n $"color"
  if [ $STATUS -eq 0 ]
  then echo -n " ${cI}[/]${cN}"; echo -n $"progs"
  else echo '            '
  fi
  gotoxy 44 ;
  printf $"%s unknown  %s not supported" "${cB}__$cN" "$cB!!$cN"
}

doMenu(){
  eval Menui=(\"\${$1[@]}\"); menu_n=$((${#Menui[*]}-1))  # ini

  if [ "$f_i" == 1 ]; then
    gotoxy $x_hist $y_hist
    echo "   $cP.oO($cN$REPLIES$cP)$cN$cP($cN$uins$cP)$cN$_eol"   # history
    gotoxy $x_menu $y_menu ; echo "$cI${Menui[0]}:$cN$_eol" # title
    for i in `sek $menu_n`                                  # itens
    do echo "  $cB$i$cN) ${Menui[$i]}$_eol"; i=$((i+1)); done
    clearEnd                                                # prompt
    gotoxy $x_prompt $y_prompt ; echo -ne "$cP[1-$menu_n]:$cN $_eol"
    read -n 1
  else
    doNextHist; REPLY=$hist
  fi
}

Menu(){
  doMenu "$1"
  case "$REPLY" in
    [1-9])if [ "$REPLY" -gt "$menu_n" ]
          then Menu "$1" ; else REPLIES="$REPLIES$REPLY"; fi;;
        .)STATUS=3 ;; 0)STATUS=0 ;; \*)ColorOnOff; Menu "$1";;
        /)STATUS=4 ;;
        *)Menu "$1";;
  esac
  [ "${STATUS/[034]/}" ] || continue         # 0,3,4: escape status
}

doNextHist(){
  hists=${hists#?}            #deleting previous item
  hist=${hists:0:1}
  [ "$hist" ] || hist='.'
}

doNextHistArg(){
  histargs=${histargs#*¤}
  histarg=${histargs%%¤*}
}

getChar(){ gotoxy $x_prompt2 $y_prompt
  if [ "$f_i" == 1 ]
  then echo -n "${cP}"; echo -n $"which one?"; echo -n " $cN"
       read -n 1 -r USERINPUT; uin="$USERINPUT";
  else doNextHistArg; uin=$histarg
  fi
  uins="$uins¤$uin"
  F_ESCCHAR=1
}


#TODO 1st of all, take out repeated chars
getCharList(){ gotoxy $x_prompt2 $y_prompt
  if [ "$f_i" == 1 ]
  then echo -n "${cP}"; echo -n $"which?"; echo -n " $cN"
       read -r USERINPUT; uin="$USERINPUT"
  else doNextHistArg; uin=$histarg
  fi
  uins="$uins¤$uin"
  # putting not special chars in not special places: [][^-]
  [ "${uin/^//}" != "$uin" ] && uin="${uin/^/}^"
  [ "${uin/-//}" != "$uin" ] && uin="${uin/-/}-"
  [ "${uin/[//}" != "$uin" ] && uin="[${uin/[/}"
  [ "${uin/]//}" != "$uin" ] && uin="]${uin/]/}"
  [ "$1" ] && uin="^$uin"                   # if any $1, negated list
  uin="[$uin]"
  F_ESCCHARLIST=1
}

getString(){ gotoxy $x_prompt2 $y_prompt
  if [ "$f_i" == 1 ]
  then echo -ne "${cP}txt:$cN " ; read -r USERINPUT ; uin="$USERINPUT"
  else doNextHistArg; uin=$histarg
  fi
  uins="$uins¤$uin"
  F_ESCCHAR=1
}

getNumber(){ gotoxy $x_prompt2 $y_prompt
  if [ "$f_i" == 1 ]
  then echo -ne "${cP}N=$cN$_eol" ; read USERINPUT ; uin="$USERINPUT"
  else doNextHistArg; uin=$histarg
  fi
  uin="${uin//[^0-9]/}"                     # extracting !numbers
  [ "${uin/666/x}" == 'x' ] && { gotoxy 36 1 ; echo "$cP]:|$cN" ; } # ee
  if [ "$uin" ]
  then uins="$uins¤$uin"
  else getNumber                            # there _must_ be a number
  fi
}

getPosix(){
  local rpl psx=''; unset SUBHUMAN
  Choice --reset "${posix_txt[@]}"
  for rpl in $CHOICEREPLY; do
    psx="$psx[:${POSIX[$rpl]}:]"; SUBHUMAN="$SUBHUMAN, ${posix_txt[$rpl]/ (*)/}"
  done
  SUBHUMAN=${SUBHUMAN#, }
  F_POSIX=1
  uin="[$psx]"
}

getCombo(){
  local rpl cmb=''; unset SUBHUMAN
  Choice --reset "${combo_txt[@]}"
  for rpl in $CHOICEREPLY; do
    cmb="$cmb${COMBO[$rpl]}"; SUBHUMAN="$SUBHUMAN, ${combo_txt[$rpl]/ (*)/}"
  done
  #TODO change this to if [ "$rpl" -eq 5 ]
  [ "$cmb" != "${cmb/@/}" ] && F_GETTAB=1
  SUBHUMAN=${SUBHUMAN#, }
  uin="[$cmb]"; [ "$1" == 'negated' ] && uin="[^$cmb]"
}

#TODO all
getREady(){
  unset SUBHUMAN
  uin=''
}

# convert [@] -> [\t] or [<TAB>] based on ax_*[6] value
# TODO expand this to all "gettable" fields: @
getListTab(){
  local x; eval x=\"\${ax_${progs[$i]}[6]}\"
  [ "$x" == ',' -o "$x" == ' ' ] && x='<TAB>'
  uin="${uin/@/$x}"
}

getHasPosix(){
  local x; eval x=\"\${ax_${progs[$i]}[5]}\"
  # let's just unsupport the tested ones
  [ "$x" == ',' ] && uin='!!'
}

escChar(){ # escape userinput chars as .,*,[ and friends
  local c x x2 z i ui esc
  esc='\'; [ "$1" == 'lisp' ] && esc='\\'   # double escape for lisp
  ui="$uin"
  eval x=\"\${ax_$1[3]}\" ; x="${x//[, ]/}" # list of escapable chars
  [ "${ui/[\\\\$x]/}" != "$ui" ] && {       # test for speed up
    for i in `sek 0 $((${#ui}-1))`          # for each user char
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

escCharList(){
  local x esc='\' ; eval x=\"\${ax_$1[4]}\"
  [ "$x" == '\' ] && uin="${uin/\\\\/$esc$esc}" # escaping escape
}

Reset(){ gotoxy $x_regex $y_regex
  unset REPLIES uins HUMAN Regex[*]
  for p in ${progs[*]}; do printf " RegEx %-6s: $_eol\n" "$p"; done
}

showRegEx(){ gotoxy $x_regex $y_regex
  local i save="$uin"
  for i in `sek 0 $((${#progs[*]}-1))`      # for each program
  do [ "$F_ESCCHAR"     == 1 ] && escChar     ${progs[$i]}
     [ "$F_ESCCHARLIST" == 1 ] && escCharList ${progs[$i]}
     [ "$F_GETTAB"      == 1 ] && getListTab  ${progs[$i]}
     [ "$F_POSIX"       == 1 ] && getHasPosix ${progs[$i]}

     case "$1" in                           # check status
       S2) eval Regex[$i]="\${Regex[$i]}\${S2_${progs[$i]}[$REPLY]/@/$uin}";;
       S0) Regex[$i]="${Regex[$i]}${S0_re[$REPLY]}";;
       S1) Regex[$i]="${Regex[$i]}${uin:-${S1_re[$REPLY]}}";;
     esac
     printf " RegEx %-6s: %s\n" "${progs[$i]}" "${Regex[$i]}"
     uin="$save"
  done
  unset uin USERINPUT F_ESCCHAR F_ESCCHARLIST F_GETTAB F_POSIX
}


#
### and now the cool-smart-MSclippy choice menu/prompt
#
# number of items <= 10, 1 column
# number of items >  10, 2 columns
# maximum number of items = 26 (a-z)
#

# just refresh the selected item on the screen
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

  # reading options and filling default status (off)
  i=0; for opt in "$@"; do
    opts[$i]="$opt"; [ "$choicereset" ] && stat[$i]='-'; i=$((i+1))
  done

  # checking our number of items limit
  [ $numopts -gt "${#alpha[*]}" ] && {
    printf "too much itens (>%d)" "${#alpha[*]}"; exit 1; }

  # the header
  Clear
  echo -n "${cI}[.]${cN}"; echo -n $"exit" ; echo -n ' | '
  echo $"press the letters to (un)select the items"

  # we will need 2 columns?
  cols=1 ; [ "$numopts" -gt 10 ] && cols=2

  # and how much lines? (remember: odd number of items, requires one more line)
  lines=$((numopts/cols)) ; [ "$((numopts%cols))" -eq 1 ] && lines=$((lines+1))

  # filling the options screen's position array (+3 = header:2, sek:1)
  for line in `sek 0 $((lines-1))`; do
    optxy[$line]="$((line+3));1"                                # column 1
    [ "$cols" == 2 ] && optxy[$((line+lines))]="$((line+3));40" # column 2
  done

  # showing initial status for all options
  for op in `sek 0 $((numopts-1))`
  do ChoiceRefresh "${optxy[$op]}" "${alpha[$op]}" "${stat[$op]}" "${opts[$op]}"
  done


  # and now the cool invisible prompt
  while :; do
    read -s -r -n 1 CHOICEREPLY

    case "$CHOICEREPLY" in
      [a-z])
        # inverting the option status
        for alf in `sek 0 $((numopts-1))`; do
          if [ "${alpha[$alf]}" == "$CHOICEREPLY" ]; then
            if [ "${stat[$alf]}" == '+' ]
            then stat[$alf]='-'
            else stat[$alf]='+'
            fi
            break
          fi
        done
        # showing the change
        ChoiceRefresh "${optxy[$alf]}" "${alpha[$alf]}" "${stat[$alf]}" "${opts[$alf]}"
        ;;
      .)
        # getting the user choices and exiting
        unset CHOICEREPLY; for rpl in `sek 0 $((numopts-1))`; do
          [ "${stat[$rpl]}" == '+' ] && CHOICEREPLY="$CHOICEREPLY $rpl"
        done
        break
        ;;
    esac
  done
}


# fills the stat array with the actual active programs ON
statActiveProgs(){
  local p i=0 ps=" ${progs[*]} "
  for i in `sek 0 $((${#allprogs[*]}-1))`; do  # for each program
    p="${allprogs[$i]}"; stat[$i]='-';         # default OFF
    [ "${ps/ $p /}" != "$ps" ] && stat[$i]='+' # case found, turn ON
  done
}

###############################################################################
######################### ariel, ucla, vamos! #################################
###############################################################################

STATUS=0           # default status
Clear; ScreenSize  # screen things
ColorOnOff         # turning color ON

while : ; do
case ${STATUS:=0} in
 0) Reset; TopTitle; STATUS=1
    Menu S0_txt
    HUMAN="$S0_txt ${S0_txt[$REPLY]}"
    showRegEx S0
    STATUS=1
    ;;
 1) TopTitle
    Menu S1_txt
    HUMAN="$HUMAN, $S1_txt ${S1_txt[$REPLY]/ (*)/}"
    case "$REPLY" in
        1) STATUS=2 ;;
        2) STATUS=2  ; getChar;;
        3) STATUS=1  ; getString; HUMAN="$HUMAN {$uin}";;
        4) STATUS=2  ; getCharList;;
        5) STATUS=2  ; getCharList negated;;
    [678]) STATUS=12 ; continue;;
        9) STATUS=1 ;;
    esac
    showRegEx S1
    ;;
12) [ "$REPLY" -eq 6  ] && STATUS=2 && getCombo
    [ "$REPLY" -eq 7  ] && STATUS=2 && getPosix
    [ "$REPLY" -eq 8  ] && STATUS=1 && getREady
    Clear; TopTitle
    HUMAN="$HUMAN {$SUBHUMAN}"
    showRegEx S1
    ;;
 2) Menu S2_txt
    rep_middle=$"repeated"
    rep_txt="${S2_txt[$REPLY]}"; rep_txtend=$"times"
    [ "$REPLY" -ge 5 ] && getNumber && rep_txt=${rep_txt/N/$uin}
    HUMAN="$HUMAN, $rep_middle ${rep_txt/ (*)/} $rep_txtend"
    showRegEx S2
    STATUS=1
    ;;
 3) echo -ne "\033[0G"
    noregex_txt=$"no RegEx"
    if [ "$f_i" == 1 ]
    then clearEnd; echo -e "\n${HUMAN:-$noregex_txt}.\n"
    else gotoxy 0 $y_prompt
    fi
    exit 0
    ;;
 4) statActiveProgs
    Choice "${allprogs[@]}"
    i=0 ; unset progs       # rewriting the progs array with the user choices
    for rpl in $CHOICEREPLY; do progs[$i]=${allprogs[$rpl]}; i=$((i+1)); done
    ScreenSize; Clear
    STATUS=0
    ;;
 *) echo "Error: STATUS = '$STATUS'"
    exit 1
    ;;
esac
done

# vim: tw=80 et
