#!/bin/bash
source ~/bin/functions.sh

RIG_NAME=`echo $0 |sed 's/.*\///'`
RIG_FILE=${ROBOT_ROOT}/RobotTests/TestBeds/${RIG_NAME}.py
SVAS=""
HOSTS=""
ACTION=$1

fatal() {
  red $@
  exit 1
}

usage() {
  red "Usage: $RIG_NAME [login|cssh||distkey]"
}

distkey_svas() {
  for sva in $SVAS
  do
    ~/bin/distkey.pl  ${sva}
  done
}

cssh_svas() {
  local sva
  local cssh_list
  for sva in $SVAS
  do
    user_at_sva="svtcli@$sva"
    if [ -z $cssh_list ];then
      cssh_list="${user_at_sva}"
    else
      cssh_list="${user_at_sva} ${cssh_list}"
    fi
  done
  set -x
  cssh ${cssh_list} &
  set +x
}

login_svas() {
  for sva in $SVAS
  do
    xssh svtcli@${sva}
  done
}

readline() {
 file=$1
 while IFS='' read -r line || [[ -n "$line" ]]; do
   echo "${line}" | grep -q "\#" && continue
   lower_line=`echo "${line}" | tr '[:upper:]' '[:lower:]'`

   ## HMS
   if [[ $lower_line == hmsip* ]];then
     HMS=$(echo "${line}" | awk '{print $3}' | sed 's/\"//g')
   fi
   ## HOST
   if [[ $lower_line == managementip* ]];then
     local host=$(echo "${line}" | awk '{print $3}' | sed 's/\"//g')
     if [ -z ${HOSTS} ];then
       HOSTS=${host}
     else
       HOSTS="${HOSTS} ${host}"
     fi
   fi
   ## SVAS
   if [[ $lower_line == svahost* ]];then
     local sva=$(echo "${line}" | awk '{print $3}' | sed 's/\"//g')
     if [ -z ${SVAS} ];then
       SVAS=${sva}
     else
       SVAS="${SVAS} ${sva}"
     fi
   fi
  
   
 done < "$file"
}

if  [ ! -f $RIG_FILE ];then
  fatal "No such file $RIG_FILE"
fi

green $RIG_NAME

readline $RIG_FILE

green "HMS=$HMS"
green "HOSTS=$HOSTS"
green "SVAS=$SVAS"


case $ACTION in

  login)
    login_svas
  ;;

  cssh)
    cssh_svas
  ;;

  distkey)
    distkey_svas
  ;;

  "")
  ;;

  *)
    usage
  ;;

esac
