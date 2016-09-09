#!/bin/bash
. ~/bin/functions.sh
if [ $#  -ne 1 ];then
  red 'Please provide a directory argument'
  exit 1
fi
if [ ! -d $1 ];then
  red "$1 is not a directory"
  exit 1
fi

for dir in `find $1 -type d -name vendor`
do
  parent=`echo $dir | sed 's/vendor//'`
  gemfile_lock="${parent}Gemfile.lock"
  green "cleaning $dir"
  rm -rf $dir
  if [ -f ${gemfile_lock} ];then
    green "cleaning ${gemfile_lock}"
    rm -f ${gemfile_lock}
  fi
done

