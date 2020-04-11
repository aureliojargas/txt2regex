#!/bin/sh
# procmail-re-test.sh
# 20010801 aurelio <verde@aurelio.net>
#
# details:
#  * LOGFILE=/tmp forces error and log is sent to STDERR
#  * /dev/null because we don't want written files
#  * text input is accepted via $2, $3, ... or STDIN
#  * generic usage: procmail-re-test.sh regex [text]
#  * usages: procmail-re-test.sh regex your sample text
#            cat textfile | procmail-re-test.sh regex
#            procmail-re-test.sh regex < textfile
#  * output: Match, No match, Invalid regexp "..."
#  * examples:
#    $ cat abc
#    homer
#    bart
#    maggie
#    $ cat abc | ./procmail-re-test.sh '^m'
#    Match
#    $ ./procmail-re-test.sh '^m' "`cat abc`"
#    Match
#    $ ./procmail-re-test.sh '^M' My cool line
#    Match
#    $ ./procmail-re-test.sh '^z' My cool line
#    No match
#    $ ./procmail-re-test.sh '^(' My cool line
#    Invalid regexp "^("
#

[ "$1" ] || {
    echo "usage: $0 regex [text]"
    exit 1
}

tmpfile=$(mktemp /tmp/procmail-re-test.sh.XXXXXX)
regex="$1"
shift
txt="$*"

[ "$txt" ] || txt="$(cat /dev/stdin)" # $* or stdin

{
    echo -e "VERBOSE=y\nLOGFILE=/tmp\nDEFAULT=/dev/null\n:0"
    echo "* $regex"
    echo /dev/null
} > $tmpfile

echo "$txt" |
    procmail $tmpfile 2>&1 |
    sed -n -e '
      /^procmail: Invalid regexp/{
        s/^[^ ]* //p
        q
      }
      s/^procmail: \(\(No m\|M\)atch\) .*/\1/p
    '

rm $tmpfile
