#!/bin/bash
export REGEN=true
. ${HOME}/bin/functions.sh

usage() {
  if [ $# -gt 0 ];then
    red "$@"
  fi
  cat << FIN

  $0 [SVA] <host1> [host2]...

  ## To regenerate keys:
  [export REGEN=true] 

FIN
  exit 1
}

if [ $# -lt 1 ];then
  usage "Please provide at least one hostname"
fi

KEYFILE="${HOME}/.ssh/id_rsa.pub"
if [ ! -f ${KEYFILE} ];then
  usage "keyfile ${KEYFILE} does not exist!"
fi

KEY=`cat ~/.ssh/id_rsa.pub`


if [ "X$1" == "XSVA" ];then
  shift
  getSvaHosts $@
  HOSTS=$SVA_HOSTS 
else
  HOSTS=$@
fi


for i in $HOSTS
do
  set -x
  ssh ${i} "echo ${KEY} >> .ssh/authorized_keys"
  set +x
done
export REGEN=false
