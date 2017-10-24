export SVANET="10.149.20."

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
      dvm*)
        fg="$AMBER"
        bg="$DARK_GRAY"
        #profile="PinkFg"
        profile="Pro"
        ;;
      foreman-prod*)
        fg="yellow" 
        bg="rgb:80/00/00"
        ;;
      smartproxy-frco*)
        fg="white" 
        bg="rgb:af/00/00"
        ;;
      smartproxy-wb*)
        fg="white" 
        bg="rgb:80/00/00"
        ;;
      vyos)
        fg="black" 
        bg="gray"
        ;;
      *prod_alt)
        fg="white"
        bg="rgb:00/5f/87"
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
    xterm -rv -e vim $i &
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

