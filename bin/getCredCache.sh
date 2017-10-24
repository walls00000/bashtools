JAUTH_LOG="/var/svtfs/0/log/jauth.log"
if [ -z $SVTCLI_TICKET ];then
  echo "Missing Ticket"
else
  sltline=`grep $SVTCLI_TICKET $JAUTH_LOG | grep Authentication`
  slt=`echo "$sltline" | sed 's/.*SLT \(.*\), .*/\1/'`
  ccline=`grep $slt $JAUTH_LOG | grep "HMS cred cache" | grep "DIR::"`
  export CRED_CACHE=`echo $ccline | sed 's/.*DIR::\(.*\)\", .*/\1/'`
  grep $SVTCLI_TICKET $JAUTH_LOG | grep -q "Session expired" && echo "Session Expired"
  grep $SVTCLI_TICKET $JAUTH_LOG | grep -q "released ticket" && echo "Released Ticket"
  if [ -f $CRED_CACHE ];then
    echo "CRED_CACHE=$CRED_CACHE"
  else
    unset CRED_CACHE
    echo "No such file $CRED_CACHE"
  fi
fi
