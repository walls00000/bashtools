#!/bin/bash --

source ~/bin/functions.sh
REPO="${PUPPET2}"
RAW_OUTPUT="${1:-/tmp/repos.out}"

if [ -f ${RAW_OUTPUT} ];then
    echo "Raw output is already in ${RAW_OUTPUT}"
else 
    find ${REPO}/modules -name \*.pp -exec grep -l repos {} \; > ${RAW_OUTPUT}
    echo "Raw output is in ${RAW_OUTPUT}"
fi

for line in `cat ${RAW_OUTPUT}`
do
	first_char=`echo ${line} | cut -c 1`
	if [ "X${first_char}" = "X#" ];then
		yellow ". . . skipping ${line} "
		continue
	fi
	white "#########\n ${line}: \n"
	grep  repos ${line}
  grep role::base ${line}
done
