#!/bin/bash

prefix=${1:?provide sitename}
site=${2:?provide sitename}
isp=${3:?provide isp name}
_={$SCRIPT_ROOT:?Environment variable SCRIPT_ROOT not set}

export LC_ALL=C
cat $SCRIPT_ROOT/cache/avghops.$prefix.$site.$isp.csv | grep -v as1 | awk -F, '{print $1,$2,$3,$4,$5}' | \
   while read as1 AS1 as2 AS2 count ; do
      if test "$as1" = "$as2" ; then continue ; fi
      if test $count -lt 200  ; then continue ; fi
      printf "%-10s -> %-10s %-4s %-15s -> %-15s\n" "$as1" "$as2" $count "$AS1" "$AS2"
   done

