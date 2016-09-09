#!/bin/bash
. ./functions.sh

help() {
 cat << FIN

$PROG <gem> [gem1 [gem2]...]

FIN
}

for i in $@
do
  echo "###########################"
  echo "$i"
  gem dependency $i
done
