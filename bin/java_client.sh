command=${1:-get-date}
JAR="remoteps-test-client-2.1.1000-SNAPSHOT-all.jar"
PSRP_DEST=192.168.20.10

getCredCache() {
  JAUTH_LOG="/var/svtfs/0/log/jauth.log"
  if [ -z $SVTCLI_TICKET ];then
    echo "Missing Ticket"
  else
    sltline=`grep $SVTCLI_TICKET $JAUTH_LOG | grep Authentication`
    slt=`echo "$sltline" | sed 's/.*SLT \(.*\), .*/\1/'`
    ccline=`grep $slt $JAUTH_LOG | grep "DIR::"`
    export CRED_CACHE=`echo $ccline | sed 's/.*DIR::\(.*\)\".*/\1/'`
    grep $SVTCLI_TICKET $JAUTH_LOG | grep -q "Session expired" && echo "Session Expired"
    grep $SVTCLI_TICKET $JAUTH_LOG | grep -q "released ticket" && echo "Released Ticket"
    if [ -f $CRED_CACHE ];then
      echo "CRED_CACHE=$CRED_CACHE"
    else
      echo "No such file $CRED_CACHE"
      unset CRED_CACHE
    fi
  fi
}

getCredCache

if [ -z $CRED_CACHE ];then
  echo "No credential cache"
  exit 1
fi
set -x
java -jar $JAR TEST_PSRP ${PSRP_DEST} /etc/ssl/certs/${PSRP_DEST}.pem "${command}" $CRED_CACHE 30 1 6
set +x
