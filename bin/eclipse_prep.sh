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
    yellow "Removing ivy caches $HOME/.ivy/repository"
    rm -rf $HOME/.ivy/repository/*
  fi
}

if [ $# -eq 0 ];then
  usage "Please provide at least one module name"
fi


if [ "X${1}" = "Xclean" ]; then
  clean  
  CLEAN="true";
  shift  
fi

. $SANDBOX/svt-dev-tools/bin/svtsetup


green "preparing modules $@"

for module in $@
do
  yellow "==${module}=="
  gcd $module || fatal "Bad module name ${module}!"

  if [ "X$CLEAN" = "Xtrue" ];then
    yellow  "clean $module"
    ./gradlew clean && green "clean ${module} SUCCESS" || fatal "gradlew clean failed"
  fi

  yellow "build ${module}"
  ./gradlew --refresh-dependencies -x test build && green "build ${module} SUCCESS" || fatal "gradlew -x test build failed"

  yellow "publish ${module}"
  ./gradlew -x test publish && green "publish ${module} SUCCESS" || fatal "gradlew -x test publish failed"
done
