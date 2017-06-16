#!/bin/bash
source $HOME/bin/functions.sh
BUGDIR=${BUGDIR:-`pwd`}

GREP=`which grep`

usage() {
  if [ $# -gt 0 ]; then
    red "$@" 
  fi
  cat << FIN
FIN

}
if [ $# -eq 0 ];then
  usage "Please provide last octet of each sva"
fi

for i in $@
do
  if [ ! -d $i ];then
    mkdir $i
    pushd $i
    file=`ls ${BUGDIR}/*.tgz | ${GREP} ${i}--`
    echo "${file}"
    tar zxf "${file}"
    popd
  else
    echo "Directory $i exists"
  fi
done
