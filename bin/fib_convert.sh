## Convert fib image to vmdk
source ~/bin/functions.sh
PROG=$0
VBOXMANAGE="/usr/bin/vboxmanage"
SOURCE_VHD=""
DEST_DIR=""
VMDKNAME=""
DRYRUN=${DRYRUN:-true}

usage() {
cat << FIN

  $PROG </path/to/disk.vhd(x)> </path/to/vmdk/dir>

FIN

}

fatal() {
  red "FATAL: $1"
  usage
  exit 1
}

parseCommandline() {
  if [ $# -ne 2 ];then
    fatal "Please provide arguments for source and destination"
  fi
  SOURCE_VHD=$1
  DEST_DIR=$2
  if [ ! -f $SOURCE_VHD ];then
    fatal "Source ${SOURCE_VHD} is not a file.  Please specify a vhd or vhdx file for the source argument"
  fi

  if [ ! -d  $DEST_DIR ];then
    fatal "Destination is not a directory.  Please specify a valid directory for the destination argument"
  fi
}

prereqs() {
  if [ ! -f $VBOXMANAGE ];then
    fatal "The vboxmanage executable does not exist at the expecte path $VBOXMANAGE.  Please verify VirtualBox is installed"
  fi
}

setVmdkName() {

  if [[ $SOURCE_VHD != *vhd* ]];then
    fatal "Source file $SOURCE_VHD doesn't have a vhd or vhdx extension"
  fi

  VMDKNAME=`basename $SOURCE_VHD | sed s/\vhd.*/vmdk/`  

  if [[ $VMDKNAME != *vmdk ]];then
    fatal "Calculated vmdk name does not end in 'vmdk'.  Was the source a vhd(x) file?"
  fi
}


doClone() {
  if [ "X${DRYRUN}" == "Xtrue" ];then
    yellow "*** DRY RUN ONLY! ***"
    yellow "To change:  export DRYRUN=false ***"
    echo "$VBOXMANAGE clonehd --format vmdk $SOURCE_VHD $DEST_DIR/$VMDKNAME"
  else
    set -x
    $VBOXMANAGE clonehd --format vmdk $SOURCE_VHD $DEST_DIR/$VMDKNAME
    set +x
  fi
}

showEnv() {
  cat << FIN
#######################################
  SOURCE_VHD:$SOURCE_VHD
  DEST_DIR:  $DEST_DIR
  VMDKNAME:  $VMDKNAME
#######################################

FIN
}
parseCommandline $@
prereqs
setVmdkName
showEnv
doClone
