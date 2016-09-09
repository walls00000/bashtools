if [ $# -ne 2 ];then
  echo "Usage <fqdn> <ip>"
  exit 1
fi
fqdn=$1
ip=$2
reverse=`echo $ip | awk -F. '{print $4"."$3"."$2"."$1}'`
inaddrarpa="${reverse}.in-addr.arpa."
cat << FIN
nsupdate -k /etc/rndc.key
update add $fqdn 38400 A $ip
update add $inaddrarpa 38400 PTR ${fqdn}.
FIN

