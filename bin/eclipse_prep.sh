. ~/bin/functions.sh
PROG=$0

fatal() {
  red $@
  exit 1
}
usage() {
if [ $# -gt 0 ];then
  red $@
fi
cat << FIN
Usage:

$PROG <module1> [<module2>] . . . 
$PROG clean <module1> [<module2>] . . . 

FIN
  exit 1
}

clean() {
  if [ -d $HOME/.gradle/caches ];then
    yellow "Removing gradle caches $HOME/.gradle/caches"
    rm -rf $HOME/.gradle/caches/*
  fi
}

if [ $# -eq 0 ];then
  usage "Please provide at least one module name"
fi


if [ "X${1}" = "Xclean" ]; then
  clean  
  shift  
fi

. $SANDBOX/svt-dev-tools/bin/svtsetup


green "preparing modules $@"

for module in $@
do
  yellow "==${module}=="
  gcd $module || fatal "Bad module name ${module}!"
  ./gradlew clean || fatal "gradlew clean failed"
  ./gradlew -x test build || fatal "gradlew -x test build failed"
  ./gradlew -x test publish || fatal "gradlew -x test publish failed"
done
