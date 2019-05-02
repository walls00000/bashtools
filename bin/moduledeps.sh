#!/bin/sh
. ~/bin/functions.sh
PROG=$0
MODULE_NAME=""
DEPEND_LIST=""

usage() {
if [ "X$1" != "X" ];then
  red "$1"
fi 
cat << FIN
Usage: 
  $PROG  <MODULE_NAME>
FIN
  exit 1
}


getModuleName() {
  line=$1
  modulename=`echo "$line" | sed 's/.*modules\/\(.*\)\/moduledependencies.yaml/\1/'` 
}

if [ $# -ne 1 ];then
  usage "Please provide an argument for MODULE_NAME"
fi
if [ -z $MODULES ];then
  usage "Please define MODULES variable for path to svt modules directory"
fi
MODULE_NAME=$1
echo "MODULES=$MODULES"
green "Finding dependency modules of ${MODULE_NAME}"

hitcount=0
for depfile in `find $MODULES -type f -name moduledependencies.yaml`
do
  #echo "$depfile"
  results=`grep $MODULE_NAME $depfile`
  if [ $? -eq 0 ];then
    getModuleName "$depfile"
    printf "%-30s %s\n" "$modulename" "$results"
    hitcount=`expr $hitcount + 1`
  fi
done
if [ $hitcount -gt 0 ];then
  green "Found $hitcount dependencies"
else
  yellow "Found $hitcount dependencies"
fi
