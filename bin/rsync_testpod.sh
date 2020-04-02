#!/bin/bash
LOCAL_DIR="$1"
HOSTNAME="$2"
REMOTE_DIR="$3"


. ~/bin/functions.sh

usage() {
  if [ -n "$@" ];then
    red "$@"
  fi
  cat <<FIN
   $0 directory host remote_dir

FIN
exit 1
}

if [ -z $LOCAL_DIR ];then
  usage "Please supply a local directory name"
fi

if [ -z $HOSTNAME ];then
  usage "Please supply a hostname"
fi

if [ -z $REMOTE_DIR ];then
  usage "Please supply a remote directory name"
fi

echo "rsync -avz -e ssh ${LOCAL_DIR} ${HOSTNAME}:${REMOTE_DIR}"
rsync -avz -e ssh ${LOCAL_DIR} ${HOSTNAME}:${REMOTE_DIR}
