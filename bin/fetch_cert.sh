red() {
  echo "[031m$@[0m"
}

green() {
  echo "[032m$@[0m"
}


usage() {
  if [ "X$@" != "X" ];then
    red $@
  fi
  cat << FIN

Usage: $0 <host> <port>

FIN
  exit 1
}

if  [ $# -ne 2 ];then
  usage "Please provide an argument for host and port"
fi

outputdir=./
server=$1
port=$2
pem_response=$(openssl s_client -connect ${server}:${port} < /dev/null 2>/dev/null | openssl x509 -fingerprint -noout -in /dev/stdin)
thumbprint=$(echo "${pem_response}" | awk -F= '{print $2}' | sed 's/://g')
pemfile=${outputdir}${thumbprint}.pem

openssl s_client -connect ${server}:${port} < /dev/null 2>/dev/null | openssl x509 > $pemfile && green $pemfile || red "Couldn't fetch cert"
