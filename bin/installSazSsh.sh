#!/bin/bash
if [ -z ${PUPPET} ];then
  echo "Please define the puppet installation in the variable PUPPET"
  exit
fi



SAZSSH_VERSION="2.8.1"
SAZSSH_TGZ="v${SAZSSH_VERSION}.tar.gz"
SAZSSH_TGZURL="https://github.com/saz/puppet-ssh/archive/${SAZSSH_TGZ}"
EXTRACT_DIR="puppet-ssh-${SAZSSH_VERSION}"
MODULENAME="ssh"

cat <<FIN
SAZSSH_VERSION=${SAZSSH_VERSION}
SAZSSH_TGZ=${SAZSSH_TGZ}
SAZSSH_TGZURL=${SAZSSH_TGZURL}
PUPPET=${PUPPET}
MODULENAME=${MODULENAME}

FIN


pushd /tmp
if [ ! -f ${SAZSSH_TGZ} ];then
  wget ${SAZSSH_TGZURL}
fi
pushd ${PUPPET}/modules
gzip -cd /tmp/${SAZSSH_TGZ} | tar xvf -
if [ -d ${PUPPET}/modules/${MODULENAME} ];then
  echo "Removing old ${MODULENAME} module"
  rm -rf ${PUPPET}/modules/${MODULENAME}
fi
mv ${PUPPET}/modules/${EXTRACT_DIR} ${PUPPET}/modules/${MODULENAME}
popd popd
