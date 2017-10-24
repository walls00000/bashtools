source ~/bin/functions.sh
DEPLOY=${DEPLOY:-deploy}
DEST="/Volumes/hyperv-public/wwallace/tmp"
JAR=`find $MODULES/$DEPLOY -name orchestrator\\*-all.jar`

if [ ! -d $DEST ];then
  i=0
  while [ $i -lt 10 ]
  do
    ls $DEST > /dev/null
    ret=$? 
    if [ $ret -eq 0 ];then
      break
    fi
    i=$(expr $i + 1)
  red "$i No such directory $DEST" 
  sleep 1
  done
  
fi

cat << FIN
$JAR => 
$DEST"
FIN
cp $JAR $DEST && green SUCCESS || red FAILED
