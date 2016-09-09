#!/bin/bash
. ~/bin/functions.sh
SPEC_DIR="$1"

if [ -z $SPEC_DIR ];then
  echo "Please provide a spec dir"
  exit 1
fi

echo "Checking spec dir ${SPEC_DIR}"

for specfile in `find ${SPEC_DIR} -type f -name \*.rb`
do
  echo ${specfile} | grep -q spec_helper.rb && continue
  echo -n "${specfile} " 
  describeline=`grep describe ${specfile}`
  describe=`echo "${describeline}" | awk '{print $2}' | sed "s/\'//g" | sed 's/,//g'`
  define_describe=`echo "${describe}" | sed 's/::/__/g'`
  grep "contain_" "${specfile}" | egrep -q "${describe}|${define_describe}" && green "GOOD" || red "BAD"
done


