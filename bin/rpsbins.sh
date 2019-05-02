############################################################################
## psrpbins source this and use the helper functions to 
## manage psrp binaries between development and deployment.
## This script is meant to be run from both dvm and sva.
## 
## IMPORTANT:  
## * Set SVAS to your remote sva hosts eg: 
##       SVAS=svtbuild@10.149.20.22 svtbuild@10.149.20.36
## * Set DIR to your dev machine's  remote-powershell module directory
## * create the following directories on your SVA hosts by sourcing this 
##   script on the SVA.  The files that will be created are: 
##    /home/svtcli/new 
##    /home/svtcli/orig  
## * On SVAs, manually backup original binaries to orig directory
## 
## For best results setup ssh keybased login to SVA hosts
############################################################################
SCRIPTS="java_client.sh analyzer.sh rpsbins.sh fetch_cert.sh rpstestenv"
BINS="${BINS:-libwsmv.so libpsrp.so libremoteps.so libremoteps-api.so remotepsapp $SCRIPTS}"
JAR_NAME="remoteps-test-client-*SNAPSHOT-all.jar"
SVAS="${SVAS:-localhost}"
LOGIN_DIR="${LOGIN_DIR:-/home/svtcli}"
BACKUP_DIR="${BACKUP_DIR:-${LOGIN_DIR}/orig}"
STAGING_DIR="${STAGING_DIR:-${LOGIN_DIR}/new}"
RPS_VERSION_DEFAULT=${RPS_VERSION:-12.8.3-psi14}
ARTIFACTORY_URL=https://artifactory.simplivt.local/artifactory/libs-release-local/com/simplivity/svt-remote-powershell/remoteps-test-client
IS_DVM=0
RPSBINS=${BASH_SOURCE[0]}

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

hostname_prefix=`echo "$HOSTNAME" | cut -c -5 | awk '{print toupper($0) }'`
if [ "X${hostname_prefix}" == "XOC-IP" ];then
  #sva
  IS_DVM=1
  DIR="/var/tmp/build"
  JAR_DIR=${LOGIN_DIR}
  createDirectories
else
  #dvm
  IS_DVM=0
  if [ "X${MODULES}" == "X" ];then
    red "WARNING: MODULES is not set!  Please set MODULES to the directory containing remote-powershell module!"
  fi
  if [  "X$DIR" != "X" ];then
    echo "DIR is already set to $DIR"
  elif [ -d $MODULES/remote-powershell ];then
    DIR="$MODULES/remote-powershell"
  elif [ -d $MODULES/svt-remote-powershell ];then
    DIR="$MODULES/svt-remote-powershell"
  else
    red "ERROR: Cannot find remote-powershell or svt-remote-powershell directory in $MODULES"
  fi
  JAR_DIR=$DIR
fi

is_dvm() {
  return $IS_DVM
}

rps_usage() {
cat << FIN
############################################################################
## RPSBINS:     $RPSBINS
## SVAS:        $SVAS
## MODULES:     $MODULES
## DIR:         $DIR
## JAR_DIR:     $JAR_DIR
## BINS:        $BINS
## BACKUP_DIR:  $BACKUP_DIR
## STAGING_DIR: $STAGING_DIR
##################################################################################################
## Common functions
##   rps_usage                                    show this usage
##   rps_get_client_versions  [year] [month]      fetch possible client versions from artifactory
##   rps_get_client                               fetch the java client from artifactory
##   rps_show                                     show the binaries on this host
##
## DVM functions:
##   rps_setup_sva                                scp $RPSBINS to all SVAs and source it
##   rps_to_sva                                   scp binaries from dvm to sva hosts
##   rps_copy_bins <dest>                         copy binaries to a specified destination dir
##
## SVA functions:
##   rps_refresh                                  replace the sva binaries with the ones from the
##                                                "new" directory
##   rps_backup                                   backup binaries to the orig directory - this is
##                                                a one-time operation
##   rps_revert                                   replace the sva binaries with the ones from the
##                                                "orig" directory
##
##################################################################################################
FIN
}

rps_show() {
  for bin in $BINS
  do
    file=`find $DIR -type f -name ${bin} | grep -v release | grep -v test-results`
    echo "$file"
  done
  JAR=`find $JAR_DIR -type f -name $JAR_NAME | tail -1`
  echo "$JAR"
}


#LOCAL COPY ON DVM
rps_copy_bins() {
  if [ 0 -ne ${IS_DVM} ];then
    red "This is a dvm command only"
    return
  fi
  if [ "X$1" == "X" ];then
    red "Please provide a valid destination directory argument to rps_copy_bins."
    return
  fi
  rps_bin_dest=$1
  if [ ! -d $rps_bin_dest ];then
    red "Destination $rps_bin_dest does not exist! Please provide a valid directory."
    return
  fi
  for bin in $BINS
  do
    file=`find $DIR -type f -name ${bin} | grep -v release | grep -v test-results`
    echo "$file => ${rps_bin_dest}"
    cp $file $rps_bin_dest
  done
  JAR=`find $JAR_DIR -type f -name $JAR_NAME | sort -n |tail -1`
  echo "$JAR => ${rps_bin_dest}"
  scp $JAR ${rps_bin_dest}
}

rps_setup_sva() {
  remoterpsbins=`basename ${RPSBINS}`
  for sva in $SVAS
  do
    echo "copying $RPSBINS to $sva"
    set -x
    scp $RPSBINS ${sva}:.
    ssh $sva source ./${remoterpsbins}
    set +x
  done
}

#FROM DVM TO SVA
rps_to_sva() {
  for sva in $SVAS
  do
    myfiles=""
    for bin in $BINS
    do
      file=`find $DIR -type f -name ${bin} | grep -v release | grep -v test-results`
      echo "$file => ${sva}:${STAGING_DIR}/."
      myfiles="${myfiles} $file"
    done
    JAR=`find $JAR_DIR -type f -name $JAR_NAME | sort -n |tail -1`
    echo "$JAR => ${sva}:${STAGING_DIR}/."
    myfiles="${myfiles} $JAR"
    scp $myfiles ${sva}:${STAGING_DIR}/.
  done
}

# Local Copy on SVA
rps_move() { 
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

rps_backup() {
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

rps_refresh() {
  rps_move ${STAGING_DIR} 
}

rps_revert() {
  rps_move ${BACKUP_DIR}
}

rps_get_client_versions() {
  local year="${1:-`date +%Y`}"
  local month="${2:-`date +%b`}"
  echo "${ARTIFACTORY_URL}"
  tmp_file="/tmp/wget.out.$$"
  wget --quiet --output-document=${tmp_file} ${ARTIFACTORY_URL}
  cat ${tmp_file} | grep -v xml | grep ${year} | grep ${month} | sed 's/<a href=".*">//' | sed 's/\/<\/a>//' | sed 's/-$//'
  rm ${tmp_file}
}

rps_get_client() {
  rps_fetch_client_versions
  echo "Enter RPS_VERSION: (default=${RPS_VERSION_DEFAULT})"
  read RPS_VERSION_USER
  if [  "X${RPS_VERSION_USER}" == "X" ];then
    RPS_VERSION="${RPS_VERSION_DEFAULT}"
  else
    RPS_VERSION="${RPS_VERSION_USER}"
  fi
  green "RPS_VERSION=$RPS_VERSION"
  wget ${ARTIFACTORY_URL}/${RPS_VERSION}/remoteps-test-client-${RPS_VERSION}-all.jar
}
rps_usage
