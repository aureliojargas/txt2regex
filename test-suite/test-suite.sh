#!/bin/bash
# test-suite.sh
# 20001026 <verde@aurelio.net> debut
# 20010802 ++ lots of changes

#TODO php quebra linha em erro.

# all this code smells like shit
# someday i'll clean it


#color=1
set -o noglob

if [ ${color:=0} -eq 1 ]
then cN=`echo -ne "\033[m"`      # normal
     cY=`echo -ne "\033[1;33m"`  # yellow
else unset cN cW
fi


ms='] .{ .} ( ) .| + ? \] \{ \} \( \) \| \+ \? .^ .\^ $. \$. [\] [\\] ^[[:print:]] \t [\t]'
re='_$[]{}()|+?^\	_'
line='------------------------'
echo $line
echo $ms
echo $line

escesc(){ echo "$*" | sed 's/\\/\\\\/g'; }
delesc4tabtest(){ re="${re/\\\\/}"; }
echoprog(){ echo -n "$cY$1$cN: "; }
echometa(){ printf '%-13s' "$1"; }

er_ed(){
echoprog ed
ed --version
#TODO
echo $line
}

er_Xwk(){
local m a ver='--version'

for a in mawk gawk
do echoprog "$a"
   [ "$a" == 'mawk' ] && ver='-W version'
   $a $ver 2>&- | sed 's/,.*//;q'
   for m in `echo $ms`
   do echometa "$m" ;
      if [ "$a" == 'mawk' ]; then
 	 	[ "$m" == '[\t]' ] && delesc4tabtest
 		echo -n "$re" | $a "/$m/{print}" 2>&1 | sed q
      else
        echo -n "$re" | $a "{print gensub(/$m/, \"$cY·$cN\", \"g\")}" 2>&1 | sed 2q
      fi
	  echo
   done | sed '/^$/d'
   echo $line
done
}

er_sed(){
local m
echoprog sed
sed --version | sed 1q
for m in `echo $ms`
do echometa "$m" ; echo -n "$re" | sed -n "s/$m/$cY·$cN/gp" 2>&1 ; echo
done | sed '/^$/d'
echo $line
}

er_Xgrep(){
local m
for a in grep egrep
do echoprog "$a"
   $a --version | sed 1q
   for m in `echo $ms`
   do echometa "$m" ; [ "$m" == '[\t]' ] && delesc4tabtest
      echo -n "$re" | ${a%-*} "$m" 2>&1 ; echo
   done | sed '/^$/d'
   echo $line
done
}

er_php(){
local m
echoprog php
echo "<? echo phpversion().\"\n\" ; ?>" | php | sed 1,3d

for m in `echo $ms`
do echometa "$m" ; echo "<? \$r=ereg_replace('$m','$cY·$cN','$re');if(\$r!='$re')echo \"\$r\";?>" |
     php 2>&1 | sed '1,3d;/^<br>/d;s/<[^>]\+>//g' ; echo
done | sed '/^ *$/d'
echo $line
}


er_find(){
local m
echoprog find
find --version
touch "$re"
for m in `echo $ms`
do echometa "$m" ; [ "$m" == '[\t]' ] && delesc4tabtest
   find . -regex ".*$m.*" -print 2>&1 | sed 1q ; echo
done | sed '/^$/d'
rm "$re"
echo $line
}

# create table "teste" ("nome" char varying(50), "usu" char varying(30))
# insert into teste values('teste de escape', '_\$[]{}()|+?^\\\\<TAB>_')"
# TIP: DB must be runnig!
er_postgres(){
local m
echoprog postgres
psql --version | sed q
# wow. + needs to be \\+, but \t is ok and \\t is wrong...
for m in `echo $ms`
do [ "${m#[}" != "$m" -o "$m" == '\t' ] 2>/dev/null || m=`escesc $m`
   echometa "$m" ; [ "$m" == '[\t]' ] && delesc4tabtest
   echo select usu from teste where usu \~ \'$m\' | psql -e teste 2>&1 |
   sed '1d;s/^ //' | sed '/^ERROR/!{3!d;}'
done
echo $line
}


# save the output onto javascript.html
er_javascript(){
echoprog javascript
# rpm -q --qf 'netscape-%{VERSION}\n' netscape-navigator
re2=`escesc "$re"`  # double escaping escaped metas
echo '<!DOCTYPE html>' > javascript.html
echo '<html lang="en"><head><meta charset="UTF-8"></head>' >> javascript.html
echo '<body style="font-size:25px;"><pre><script>' >> javascript.html
echo "var er = \"$re2\";" | tee -a javascript.html
for m in `echo $ms`
do m=`escesc "$m"`
   echo "document.write('$m	'+er.replace('$m','<b>★</b>')+\"<br>\");" |
   sed "/'\(\.{\|(\|\[\\\\\\\\]\)'/s,er\.re[^)]\+),\"ERROR\"," |
   sed "s/'\[\\\\\\\\\\\\\\\\/&./g"
   # first sed avoid fatal error on .{, ( and [\]
   # second sed puts a . on the [\\] cause \ cannot be the last list item
done | tee -a javascript.html
echo '</script></pre></body></html>' >> javascript.html
echo
echo "Check javascript.html in your browser."
echo $line
}


er_perl(){
local m
echoprog perl
perl --version | sed -n '2s/.*, //p'
for m in `echo $ms`
do echometa "$m" ; echo -n "$re" | perl -pe "s/$m/$cY·$cN/g" 2>&1 ; echo
done | sed '/^$/d'
echo $line
}


er_tcl(){
local m
echoprog tcl
echo 'puts $tcl_version' | tclsh
re=`escesc "$re"`
for m in `echo $ms`
do echometa "$m" ;
   # we need the tmpfile because it hangs on the 1st error on ...$res" | tclsh
   echo "regsub -all {${m}} \"$re\" \"·\" res; puts \$res" > tmp; tclsh tmp 2>&1 |
   sed "s/·/$cY&$cN/g;q"
done
rm -f tmp
echo $line
}

er_vim(){
echoprog vim
vim --version 2>&1 | sed 's/,.*/)/;q'
#TODO
echo $line
}

er_procmail(){
local m
echoprog procmail
procmail -v 2>&1 | sed q
for m in `echo $ms`;
do echometa "$m" ; [ "$m" == '[\t]' ] && delesc4tabtest
   ./procmail-re-test.sh "$m" "$re"
done
echo $line

}

if [ "$1" ]; then
  eval er_$1
else
  er_ed
  er_Xwk
  er_Xgrep
  er_find
  er_javascript
  er_perl
  er_php
  er_postgres
  er_sed
  er_tcl
  er_vim
  er_procmail
fi
