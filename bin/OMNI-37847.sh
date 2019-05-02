if [ "X${SVTINSTDIR}" == "X" ];then
  echo "Please source /var/tmp/build/bin/appsetup"
fi 
set -x
mkdir ${SVTINSTDIR}/security/cacerts/external
chown caservice:caservice ${SVTINSTDIR}/security/cacerts/external
set +x
