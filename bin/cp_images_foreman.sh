#!/bin/bash --


SOURCE='/mnt/esxi'
#####FOREMAN#####
DEST='/datastore02/foreman_tftp/boot/esxi'
#####SMARTPROXY#####
#DEST='/var/lib/tftpboot/boot/esxi'
pushd ${SOURCE}

for image in $@
do
  echo ${image}
  if [ ! -d ${image} ];then
    echo "${image} is not a directory"
    exit 1
  fi

  echo "RSYNCING ${image} to ${DEST}"
  sudo rsync -av ${image} ${DEST}
  sudo chown -R foreman-proxy:foreman-proxy ${DEST}/${image}
done

popd

