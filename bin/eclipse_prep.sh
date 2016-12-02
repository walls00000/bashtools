. ~/bin/functions.sh
PROG=$0


usage() {
if [ $# -gt 0 ];then
  red $@
fi
cat << FIN
Usage:

$PROG <module_dir> <gradle_command>

FIN
  exit 1
}
if [ $# -ne 2 ];then
  usage "Please provide valid arguments"
fi
if [ ! -d $modules ];then
  usage "Please provide a valid directory for modules"
fi


modules=$1
gradle_command=$2
green "using modules $modules"

for wrapper in `find . -name gradlew`
do
  module=`echo $wrapper | sed 's/\/gradlew$//'`
  pushd $module
  ./gradlew ${gradle_command}
  popd
done
