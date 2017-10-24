############################################################################
## psrpbins source this and use the helper functions to 
## manage psrp binaries between development and deployment.
## This script is meant to be run from both dvm and sva.
## 
## IMPORTANT:  
## * Set SVAS to your remote sva hosts eg: 
##       SVAS=svtbuild@10.149.20.22 svtbuild@10.149.20.36
## * Set DIR to your dev machine's  remote-powershell module directory
## * create the following directories on your SVA hosts: 
##    /home/svtbuild/new 
##    /home/svtbuild/old  
## * On SVAs, manually backup original binaries to old directory
## 
## For best results setup ssh keybased login to SVA hosts
############################################################################
BINS="${BINS:-libpsrp.so libremoteps.so libremoteps-api.so remotepsapp}"
JAR_NAME="remoteps-test-client-*SNAPSHOT-all.jar"
SVAS="${SVAS:-localhost}"
LOGIN_DIR="${LOGIN_DIR:-/home/svtcli}"
BACKUP_DIR="${BACKUP_DIR:-${LOGIN_DIR}/orig}"
STAGING_DIR="${STAGING_DIR:-${LOGIN_DIR}/new}"

red() {
  echo "[031m$@[0m"
}

green() {
  echo "[032m$@[0m"
}

yellow() {
  echo "[033m$@[0m"
}


createDirectories() {
  for dir in ${BACKUP_DIR} ${STAGING_DIR}
  do
    if [ ! -d $dir ];then
      mkdir -p $dir
      chmod 777 $dir
    fi
  done
}

hostname_prefix=`echo "$HOSTNAME" | cut -c -5`
if [ "X${hostname_prefix}" == "XOC-ip" ];then
  #sva
  DIR="/var/tmp/build"
  JAR_DIR=${LOGIN_DIR}
  createDirectories
else
  #dvm
  if [ "X${MODULES}" == "X" ];then
    red "WARNING: MODULES is not set!  Please set MODULES to the directory containing remote-powershell module!"
  fi
  if [ -d $MODULES/remote-powershell ];then
    DIR="$MODULES/remote-powershell"
  elif [ -d $MODULES/svt-remote-powershell-hvac ];then
    DIR="$MODULES/svt-remote-powershell-hvac"
  else
    red "ERROR: Cannot find remote-powershell or svt-remote-powershell directory in $MODULES"
  fi
  JAR_DIR=$DIR
fi

cat << FIN
############################################################################
## SVAS:        $SVAS
## MODULES:     $MODULES
## DIR:         $DIR
## BINS:        $BINS
## BACKUP_DIR:  $BACKUP_DIR
## STAGING_DIR: $STAGING_DIR
############################################################################
## 
## DVM functions:
##   showFiles (show the binaries on this host)
##   toSVA (scp binaries from dvm to sva hosts)
##
## SVA functions:
##   showFiles (show the binaries on this host)
##   refresh (replace the binaries from the "new" directory)
##   backup (backup binaries - this is a one-time operation)
##   revert (replace the binaries from the "old" directory)
##
############################################################################
FIN

showFiles() {
  for bin in $BINS
  do
    file=`find $DIR -type f -name ${bin} | grep -v release | grep -v test-results`
    echo "$file"
  done
  JAR=`find $JAR_DIR -type f -name $JAR_NAME | tail -1`    
  echo "$JAR"
}

#FROM DVM TO SVA
toSVA() {
  for sva in $SVAS
  do
    for bin in $BINS
    do
      file=`find $DIR -type f -name ${bin} | grep -v release | grep -v test-results`
      echo "$file => ${sva}:new/."
      scp $file ${sva}:new/.
    done
    JAR=`find $JAR_DIR -type f -name $JAR_NAME | sort -n |tail -1`
    echo "$JAR => ${sva}:."
    scp $JAR ${sva}:.
  done
}

# Local Copy on SVA
toBinDir() { 
  srcdir=$1
    for bin in $BINS
    do
      src="${srcdir}/${bin}"
      dest=`find $DIR -type f -name ${bin}`
      echo "$src => $dest"
      cp $src $dest
      chmod 775 $dest
      chown root:root $dest
    done
}

backup() {
  echo "Backing up binaries to ${BACKUP_DIR}"
  for bin in $BINS
  do
    src=`find $DIR -type f -name ${bin}`
    if [ -f ${BACKUP_DIR}/${bin} ];then
      red "REFUSING TO OVERWRITE ORIGINAL BACKUP in ${BACKUP_DIR}/${bin}"
    else 
      cp $src ${BACKUP_DIR}
    fi
  done
  ## Nothing to do for $JAR
}

refresh() {
  toBinDir ${STAGING_DIR} 
}

revert() {
  toBinDir ${BACKUP_DIR}
}

