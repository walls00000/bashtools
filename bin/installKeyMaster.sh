#!/bin/bash
if [ -z ${PUPPET} ];then
  echo "Please define the puppet installation in the variable PUPPET"
  exit
fi



KMVERSION="0.3.0"
KMTGZ="${KMVERSION}.tar.gz"
KMTGZURL="https://github.com/Aethylred/puppet-keymaster/archive/${KMTGZ}"
EXTRACT_DIR="puppet-keymaster-${KMVERSION}"
MODULENAME="keymaster"

cat <<FIN
KMVERSION=${KMVERSION}
KMTGZ=${KMTGZ}
KMTGZURL=${KMTGZURL}
PUPPET=${PUPPET}
MODULENAME=${MODULENAME}

FIN


pushd /tmp
if [ ! -f ${KMTGZ} ];then
  wget ${KMTGZURL}
fi
pushd ${PUPPET}/modules
gzip -cd /tmp/${KMTGZ} | tar xvf -
if [ -d ${PUPPET}/modules/${MODULENAME} ];then
  echo "Removing old ${MODULENAME} module"
  rm -rf ${PUPPET}/modules/${MODULENAME}
fi
mv ${PUPPET}/modules/${EXTRACT_DIR} ${PUPPET}/modules/${MODULENAME}
popd popd
