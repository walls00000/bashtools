export SVANET="10.149.20."
export FIBNET="192.168.20."

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


xssh() {
  MY_TERM=xterm
  term_ssh $@
}

tssh() {
  MY_TERM=term
  term_ssh $@
}

term_ssh() {
  for host in $@
  do
    echo "Connecting to ${host}"
    case ${host} in
      dvm*)
        fg="white"
        bg="rgb:5f/00/5f"
        profile="PinkFg"
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
      *)
        fg="white"
        bg="black"
        profile="BlueFg"
        ;;
    esac
    if [ "X${MY_TERM}" == "Xxterm" ];then
      xterm -fg ${fg} -bg ${bg} -e ssh ${host} &
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

getSVAs() {
  USER="svtcli"
  SVA_HOSTS=""
  for i in $@
  do
    host="${MANAGEMENT_NET}${i}"
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

getFibHosts() {
  MANAGEMENT_NET=${FIBNET}
  getSVAs $@
  unset MANAGEMENT_NET
}
getSvaHosts() {
  MANAGEMENT_NET=${SVANET}
  getSVAs $@
  unset MANAGEMENT_NET
}
