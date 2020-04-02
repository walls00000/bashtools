PROG=$0
SMALL=1024x800
MEDIUM=1280x1024
LARGE=1900x1024


source functions.sh

usage() {
  if [ "X$@" != "X" ];then
    red $@
  fi
  cat << FIN

  Usage: $PROG <arg1> . . .
     valid args:
        show
        start SMALL|MEDIUM|LARGE|ALL
        kill  SMALL|MEDIUM|LARGE|ALL


FIN
  exit 1
}


start_vncserver() {
  local geom=$1
  local display=$2
  echo "Starting server with geometry $geom on display $display"
  vncserver -geometry $geom $display && green "SUCCESS" || red "FAILED" 
}


start_small() {
  start_vncserver $SMALL :1
}

start_medium() {
  start_vncserver $MEDIUM :2
}

start_large() {
  start_vncserver $LARGE :3
}

start() {
  if [ "X$1" == "X" ];then
    usage "Please provide a valid start argument"
  fi

  case $1 in

    SMALL)
      start_small
    ;;

    MEDIUM)
      start_medium
    ;;

    LARGE)
      start_large
    ;;

    ALL)
    ;;

    *)
      usage "Invalid start argument <$1>.  Please provide a valid start argument"
    ;;
  esac
}

kill_vncserver() {
  local display=$1
  local display_num=$(echo $display | cut -c2)
  echo "Killing vncserver on display $display"
  vncserver -kill $display
  #remove old cruft
  #rm -f /tmp/.X3-lock
  #rm -f /tmp/.X11-unix/X3
  xlock="/tmp/.X${display_num}-lock"
  x11unix_x="/tmp/.X11-unix/X${display_num}"
  for cruft in $xlock $x11unix_x
  do
    if [ -f $cruft ];then
      echo "Removing old cruft $cruft"
      #rm -f $cruft
    fi
  done
}

killit() {


  case $1 in

    SMALL)
      kill_vncserver :1     
    ;;

    MEDIUM)
      kill_vncserver :2     
    ;;

    LARGE)
      kill_vncserver :3     
    ;;

    ALL)
      for i in :1 :2 :3
      do
        kill_vncserver $i
      done
    ;;

    *)
      usage "Invalid start argument <$1>.  Please provide a valid start argument"
    ;;
  esac
}

show() {
  ps auxwww | grep Xvnc | grep -v grep
}

if [ $# -lt 1 ];then
  usage "Please provide a valid argument"
fi
case $1 in
  show)
    show
  ;;

  start)
    start $2
  ;;
  
  kill)
   killit $2
  ;;

  *)
    usage "Invalid argument <$1>.  Please provide a valid argument"
  ;;
esac
