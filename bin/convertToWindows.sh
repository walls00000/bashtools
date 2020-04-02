#!/bin/bash
. ~/bin/functions.sh 

usage() {
  cat << FIN
$0 <infile> <outfile>
  (infile must be a unix formatted file)
FIN
  exit 0
}

if [ $# -ne 2 ];then
  red "Please provide two arguments!"
  usage
fi

unixfile=$1
winfile=$2

yellow "converting" 
echo "${unixfile} "
green "${winfile}"
awk 'sub("$", "\r")' ${unixfile} > ${winfile}
