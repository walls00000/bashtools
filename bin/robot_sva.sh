#!/bin/bash
source ~/bin/functions.sh

BINDIR=~/testbeds
THIS_FILE=$0
RIG_NAME=`echo $0 |sed 's/.*\///'`
TESTBEDS=${ROBOT_ROOT}/RobotTests/TestBeds
RIG_FILE=${TESTBEDS}/${RIG_NAME}.py
SVAS=""
HOSTS=""
HOSTNAMES=""
ACTION=$1

fatal() {
  red $@
  exit 1
}

usage() {
  red "Usage: $RIG_NAME [login|cssh||distkey|keygen]"
  red "       robot_sva.sh"
}

setup_rigs() {
  if [ ! -f $BINDIR ];then
    mkdir -p $BINDIR
  fi
  rm $BINDIR/*
  count=0
  for file in `ls -1 ${TESTBEDS}/*.py`
  do
    local rigname=$(basename $file | sed 's/\.py$//')
    ln -sf $THIS_FILE $BINDIR/$rigname
    count=$((count + 1))
  done  
  green "$count Rigs are now in $BINDIR"
  ls $BINDIR
}

keygen_svas() {
  for sva in $SVAS
  do
  ssh-keygen -R ${sva}
  done
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
    if [ "X$cssh_list" == "X" ];then
      cssh_list="${user_at_sva}"
    else
      cssh_list="${user_at_sva} ${cssh_list}"
    fi
  done
  cssh ${cssh_list} &
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

   ## DC
   if [[ $lower_line == dcip* ]];then
     DC=$(echo "${line}" | awk '{print $3}' | sed 's/\"//g')
   fi
   ## HMS
   if [[ $lower_line == hmsip* ]];then
     HMS=$(echo "${line}" | awk '{print $3}' | sed 's/\"//g')
   fi
   ## HOST
   if [[ $lower_line == managementip* ]];then
     local host=$(echo "${line}" | awk '{print $3}' | sed 's/\"//g')
     if [ "X${HOSTS}" == "X" ];then
       HOSTS=${host}
     else
       HOSTS="${HOSTS} ${host}"
     fi
   fi
   ## HOSTNAME
   echo $line | grep -q "ComputerName" 
   if [ $? -eq 0 ];then
       local hostname=$(echo "${line}" | awk '{print $3}' | sed 's/\"//g' | sed 's/,//g')
     if [ "X${HOSTNAMES}" == "X" ];then
       HOSTNAMES=${hostname}
     else
       HOSTNAMES="${HOSTNAMES} ${hostname}"
     fi
   fi
   
   ## SVAS
   if [[ $lower_line == svahost* ]];then
     local sva=$(echo "${line}" | awk '{print $3}' | sed 's/\"//g')
     if [ "X${SVAS}" == "X" ];then
       SVAS=${sva}
     else
       SVAS="${SVAS} ${sva}"
     fi
   fi
  
   
 done < "$file"
}

if [ "X$RIG_NAME" == "Xrobot_sva.sh" ];then
  echo "$RIG_NAME executing setup"
  setup_rigs
  exit 0
fi 

if  [ ! -f $RIG_FILE ];then
  fatal "No such file $RIG_FILE"
fi

green $RIG_NAME

readline $RIG_FILE

echo "RIG_FILE: $RIG_FILE"
yellow "DC=$DC"
green "HMS=$HMS"
green "HOSTS=$HOSTS"
green "HOSTNAMES=$HOSTNAMES"
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

  keygen)
    keygen_svas
  ;;

  "")
  ;;

  *)
    usage
  ;;

esac
