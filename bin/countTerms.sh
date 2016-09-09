#!/bin/bash
file=$1


. ~/bin/functions.sh

if [ -z ${file} ];then
  red "Please provide a filename"
  exit 0
fi

if [ ! -f ${file} ];then
  red "${file} is not a file"
  exit 0
fi

terms=`for i in $(cat ${file} | awk '{print $1}'); do echo $i; done | sort | uniq`

for term in $terms
do
  count=$(grep -c ${term} ${file})
  echo "${count}: ${term}"
done
