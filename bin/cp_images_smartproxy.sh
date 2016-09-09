#!/bin/bash --

##### SMARTPROXY VERSION #####
REMOTE_USER='svtbuild'
REMOTE_HOST='foreman-prod01'
REMOTE_DIR='/mnt/esxi'
SOURCE=${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}
DEST='/var/lib/tftpboot/boot/esxi'

if [ ! -d ${DEST} ];then
  echo "${DEST} is not a directory"
  exit 1
fi

for image_dir in $@
do
  echo ${image_dir}
  echo "RSYNCING ${SOURCE}/${image_dir} to ${DEST}"
  sudo rsync -avz -e "ssh -i .ssh/svtbuild" ${SOURCE}/${image_dir} ${DEST}
  sudo chown -R foreman-proxy:foreman-proxy ${DEST}/${image_dir}
done


