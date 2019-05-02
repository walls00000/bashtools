source ~/bin/functions.sh
BRANCH=${BRANCH:-master}
BUILD_ARGS="${@:-}"
FAILED=""
oldrepos="\
#ssh://git@stash.simplivt.local:7999/~slarson/svt-hval-hyperproxy-hvac.git \
#ssh://git@stash.simplivt.local:7999/~wwallace/svt-hyperproxy-impl-hvac.git \
#ssh://e#it@stash.simplivt.local:7999/~mtardif/area51.svt-security.git \
#ssh://git@stash.simplivt.local:7999/~rlaporte/svt-eventmgr-hvac.git \
ssh://git@stash.simplivt.local:7999/~wwallace/svt-remote-powershell-hvac.git \
#ssh://git@stash.simplivt.local:7999/~rlaporte/svt-rest-api-hvac.git \
#ssh://git@stash.simplivt.local:7999/~kglidewell/svt-platform-scripts-hvac.git \
#ssh://git@stash.simplivt.local:7999/~wwallace/svt-cli-hvac.git \
#ssh://git@stash.simplivt.local:7999/~ckallianpur/svt-deploy-installer-hvac.git \
#ssh://git@stash.simplivt.local:7999/~wwallace/svt-deploy-hvac.git \
#ssh://git@stash.simplivt.local:7999/~kglidewell/svt-deploy-api-hvac.git
#ssh://git@stash.simplivt.local:7999/~ckallianpur/svt-base-ubuntu-hvac.git \
#ssh://git@stash.simplivt.local:7999/~slarson/svt-control-plane-hvac.git \
#ssh://git@stash.simplivt.local:7999/~kglidewell/svt-assembly-hvac.git \
"

repos="\
ssh://git@stash.simplivt.local:7999/~wwallace/svt-hval-hyperproxy.git \
ssh://git@stash.simplivt.local:7999/~wwallace/svt-hyperproxy-impl.git \
ssh://git@stash.simplivt.local:7999/~wwallace/svt-security-common.git \
ssh://git@stash.simplivt.local:7999/~wwallace/svt-eventmgr.git \
#ssh://git@stash.simplivt.local:7999/~wwallace/svt-remote-powershell.git \
ssh://git@stash.simplivt.local:7999/~wwallace/svt-rest-api.git \
#ssh://git@stash.simplivt.local:7999/~wwallace/svt-platform-scripts.git \
#ssh://git@stash.simplivt.local:7999/~wwallace/svt-cli.git \
#ssh://git@stash.simplivt.local:7999/~wwallace/svt-deploy-installer.git \
ssh://git@stash.simplivt.local:7999/~wwallace/svt-deploy.git \
#ssh://git@stash.simplivt.local:7999/~wwallace/svt-deploy-api.git
#ssh://git@stash.simplivt.local:7999/~wwallace/svt-assembly.git \
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
    #TODO MAKE BRANCH CO MORE FLEXIBLE
    if [ "X${dir}" == "Xsvt-hval-hyperproxy" ];then
      yellow $dir
      git checkout $BRANCH
    else 
      git checkout master
    fi
  else
    cd $dir
    git pull --ff-only
  fi
  for j in `cat moduleversion.yaml | grep -v "^\#"`; do echo -n "$j "; done;echo
  if [ "X${dir}" == "Xsvt-assembly" ];then
    yellow "Skipping $dir"
    continue
  fi
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
  red "FAILED MODULES:"
  for module in ${FAILED}
  do
    echo "$module"
  done
fi
