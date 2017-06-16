BUILD_ARGS="${@:-}"
FAILED=""
repos="\
#ssh://git@stash.simplivt.local:7999/~wwallace/svt-remote-powershell-hvac.git \
ssh://git@stash.simplivt.local:7999/~wwallace/svt-hyperproxy-impl-hvac.git \
#ssh://git@stash.simplivt.local:7999/~wwallace/svt-cli-hvac.git \
ssh://git@stash.simplivt.local:7999/~slarson/svt-hval-hyperproxy-hvac.git \
#ssh://git@stash.simplivt.local:7999/~rlaporte/svt-eventmgr-hvac.git \
#ssh://git@stash.simplivt.local:7999/~rlaporte/svt-rest-api-hvac.git \
#ssh://git@stash.simplivt.local:7999/~kglidewell/svt-platform-scripts-hvac.git \
#ssh://git@stash.simplivt.local:7999/~mtardif/area51.svt-security.git \
#ssh://git@stash.simplivt.local:7999/~kglidewell/svt-assembly-hvac.git \
"
for i in $repos
do
  firstchar=`echo $i | cut -c 1`
  if [ "X${firstchar}" == "X#" ];then
    continue
  fi

  dir=$(echo $i | sed -e 's/.*\///' -e 's/\.git.*//')
  echo "=======================================" $dir "========================================================"
  if [ ! -d $dir ];then
    git clone $i
    cd $dir
    git checkout release/PSI10
  else
    cd $dir
  fi
  for j in `cat moduleversion.yaml | grep -v "^\#"`; do echo -n "$j "; done;echo
  echo "./gradlew ${BUILD_ARGS}"
  ./gradlew ${BUILD_ARGS}
  ret=$?
  if [ $ret -ne 0 ];then
    FAILED="${FAILED} $dir"
  fi
  cd ..
  echo "Exiting================================" $dir "========================================================"
done

if [ "X${FAILED}" != "X" ];then
  echo "FAILED MODULES:"
  for module in ${FAILED}
  do
    echo "$module"
  done
fi
