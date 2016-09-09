#!/bin/bash
. ~/bin/functions.sh
DIR=$1
HOST=$2

if [ $# -ne 2 ];then
  red "Usage <puppet_dir> <host>"
  exit 1
fi

if [ ! -d $1 ];then
  red "Please provide a valid  puppet directory!"
  exit 1
fi

pushd $DIR
ret=1
count=0
while true
do
  cyan "########## $count ##########"
  if [ $ret -eq 0 ];then
    green "Success!!"
    break
  fi
  set -x
  vagrant provision $HOST
  ret=$?
  set +x
  count=`expr $count + 1`
done

popd
