#export SVANET="10.1.180."
export SVANET="10.1.182."
export CIPHER_PY="$HOME/sandbox/python101/oo_python/cipher.py"
export PYTHON="/usr/bin/python3"

red() {
  echo "[031m$@[0m"
}

green() {
  echo "[032m$@[0m"
}

yellow() {
  echo "[033m$@[0m"
}

blue() {
  echo "[034m$@[0m"
}

purple() {
  echo "[035m$@[0m"
}

cyan() {
  echo "[036m$@[0m"
}

white() {
  echo "[037m$@[0m"
}

black() {
  echo "[030m$@[0m"
}

##########################
## xterm colors
##########################
export AMBER="rgb:ff/af/00"
export DARK_GRAY="rgb:1c/1c/1c"
export LIGHT_BROWN="rgb:87/5f/00"
export LIGHT_BROWN2="rgb:af/5f/00"
export DARK_BROWN="rgb:5f/00/00"
export LIGHT_BLUE="rgb:5f/d7/ff"
export DARK_BLUE="rgb:5f/87/ff"

addToPath() {
  for path in $@
  do
    echo $PATH | grep -q $path || export PATH=$path:${PATH}
  done
}

xssh() {
  MY_TERM=xterm
  term_ssh $@
}

tssh() {
  MY_TERM=term
  term_ssh $@
}

term_ssh() {
  geometry="80x24"
  for host in $@
  do
    echo "Connecting to ${host}"
    case ${host} in
      hou-*)
        fg="$LIGHT_BLUE"
        bg="black"
        #profile="PinkFg"
        profile="Pro"
        ;;
      dvm*)
        fg="$AMBER"
        bg="$DARK_GRAY"
        #profile="PinkFg"
        profile="Pro"
        ;;
      ubuntu*)
        fg="$AMBER"
        bg="$DARK_GRAY"
        #profile="PinkFg"
        profile="Pro"
        ;;
      svtlab)
        geometry="110x58"
        fg="white"
        bg="NavyBlue"
        profile="BlueFg"
        ;;
      *)
        fg="white"
        bg="black"
        profile="BlueFg"
        ;;
    esac
    if [ "X${MY_TERM}" == "Xxterm" ];then
      xterm -fg ${fg} -bg ${bg} -geometry ${geometry} -e ssh ${host} &
    elif [ "X${MY_TERM}" == "Xterm" ];then
      macterm.sh "ssh ${host}" $profile 
    fi
  done
}

vssh() {
  for host in $@
  do
    echo "Connecting to ${host}"
    case ${host} in
      ubuntu)
        xterm -fg white -bg rgb:5f/00/5f -e vagrant ssh ${host} &
      ;;

      centos)
        xterm -fg black -bg rgb:ff/df/af -e vagrant ssh ${host} &
      ;;

      puppet_master*)
        xterm -fg white -bg rgb:5f/00/d7 -e vagrant ssh ${host} &
      ;;

      *)
        xterm -fg yellow -bg rgb:00/00/5f -e vagrant ssh ${host} &
      ;;
    esac
  done
}

xvim() {
  for i in $@
  do
    xterm -fg white -bg black -e vim $i &
  done
}

xless() {
  for i in $@
  do
    xterm -rv -e less $i &
  done
}


getSvaHosts() {
  USER="svtcli"
  SVA_HOSTS=""
  for i in $@
  do
    host="${SVANET}${i}"
    if [ "X$SVA_HOSTS" == "X" ];then
      SVA_HOSTS="$USER@$host"
    else
      SVA_HOSTS="$SVA_HOSTS $USER@$host"
    fi
    if [ "X$REGEN" == 'Xtrue' ];then
      ssh-keygen -R $host
    fi
  done
  export SVA_HOSTS
}

printSvaHosts() {
  getSvaHosts $@
  echo "SVA_HOSTS=${SVA_HOSTS}"
}


getEncryptedUser() {
  filename=$1
  decrypted=`$PYTHON $CIPHER_PY -d -f $filename`
  echo "$decrypted" | awk '{print $1}'
}

getEncryptedPass() {
  filename=$1
  decrypted=`$PYTHON $CIPHER_PY -d -f $filename`
  echo "$decrypted" | awk '{print $2}'
}
