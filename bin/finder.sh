#!/bin/bash --
. ~/bin/functions.sh

usage () {
if [ "X$1" != 'X' ];then
  red $1
fi
  cat << FIN
$0 <directory> <search_term>

FIN
}
if [ $# -ne 2 ];then
  usage "Please provide 2 arguments"
fi

DIR=$1
TERM=$2

count=0
for file in `find ${DIR} -type f -exec grep -l "${TERM}" {} \;`
do
  echo "############################################"
  echo $file
  grep "${TERM}" ${file}
  count=`expr $count + 1`
done
echo "Found $count records"
