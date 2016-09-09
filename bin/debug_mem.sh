#!/bin/bash --
if [ $# -ne 1 ];then
  echo "Please provide a process name"
  exit
fi

proc_name=$1

while true
do 
  pid=`ps auxwww | grep -v grep | grep $proc_name | awk '{print $2}'`
  if [ "X$pid" != "X" ];then 
    sudo pmap -x $pid
  fi
done
