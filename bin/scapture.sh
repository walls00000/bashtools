#!/bin/bash
source $HOME/bin/functions.sh
BUGDIR=${BUGDIR:-`pwd`}
PROG=$0
GREP=`which grep`
LS=`which ls`

usage() {
  if [ $# -gt 0 ]; then
    red "$@" 
  fi
  cat << FIN
$PROG 
FIN
  exit 1
}
if [ $# -gt 0 ];then
  usage "Please do not provide any arguments"
fi

for tgz in `$LS -1 Capture-*.tgz`
do
  octet=`echo "$tgz" | sed 's/Capture-[0-9]*\.[0-9]*\.[0-9]*\.\([0-9]*\)--.*\.tgz/\1/'`
  if [ ! -d $octet ];then
    mkdir $octet
    pushd $octet
    echo "${tgz} ==> ${octet}"
    tar zxf "${BUGDIR}/${tgz}"
    popd
  else
    echo "Directory $octet exists"
  fi
done
