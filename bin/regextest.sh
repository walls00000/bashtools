#!/bin/bash
RET=1
if [ $# -ne 1 ];then
 echo 'Please supply one argument to test'
 exit 1
fi

test() {
  ip=$1
  case $ip in
    *10.143.6[5-9].*|*10.143.7[0-9].*|*10.143.8[0-9].*|*10.143.9[0-9].*|*10.143.10[0-9].*|*10.143.11[0-9].*|*10.143.12[0-7].*)
      echo "$ip MATCH"
      RET=0
    ;;

    *)
      echo $ip NOMATCH
      RET=1
    ;;

  esac
}

if [ -f $1 ];then
  ips=`cat $1`
  for ip in $ips
  do
    test $ip
  done
else
 test $1
fi

exit $RET
