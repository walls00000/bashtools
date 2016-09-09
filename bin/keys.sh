. ~/bin/functions.sh

COMMAND=''
PUPPET_DIR=''
KEY_DEST=''
KEY_SOURCE="/etc/puppet/environments/production/secure"
PUPPET_MASTER="puppet-master-prod01.us-east02.simplivt.local"
KEYS="private_key.pkcs7.pem public_key.pkcs7.pem"

usage () {
  red $@
  cat << FIN

  $0 puppetdir get|delete [dev|prod]

FIN
  exit 0
}

getDev() {
  green "Getting keys and storing them in ${KEY_DEST}"
  cat << FIN >${KEY_DEST}/private_key.pkcs7.pem
DO YOU REALLY THINK A PRIVATE KEY WOULD BE HERE??
FIN
  cat << FIN >${KEY_DEST}/public_key.pkcs7.pem
DO YOU REALLY THINK A PUBLIC KEY WOULD BE HERE??
FIN
}

getProd() {
  green "Getting keys and storing them in ${KEY_DEST}"
  ssh -t ${SSH_USER}@${PUPPET_MASTER} sudo cp ${KEY_SOURCE}/p*key.pkcs7.pem /tmp/.
  ssh -t ${SSH_USER}@${PUPPET_MASTER} sudo chmod 777 /tmp/p*key.pkcs7.pem
  scp ${SSH_USER}@${PUPPET_MASTER}:/tmp/p*key.pkcs7.pem ${KEY_DEST}/.
  ssh -t ${SSH_USER}@${PUPPET_MASTER} sudo rm /tmp/p*key.pkcs7.pem
}

getKeys() {
  case ${TYPE} in
  dev)
    getDev
  ;;

  prod)
   getProd
  ;;

  *)
    usage "Unrecognized type '$TYPE'! Valid options are dev|prod"
  ;;
  esac
  chmod 400 ${KEY_DEST}/p*key.pkcs7.pem
}

if [[ $# -lt 2  ||  $# -gt 3 ]]; then
  usage "Please provide 2 or 3 arguments"
fi

PUPPET_DIR=$1
COMMAND=$2
TYPE="${3:-dev}"
KEY_DEST="${PUPPET_DIR}/bootstrap/eyaml"

if [ -z ${SSH_USER} ];then
  usage "Please define SSH_USER environment variable"
fi

if [ ! -d ${KEY_DEST} ];then
  usage "${KEY_DEST} must be a valid directory"
fi

case ${COMMAND} in
  get)
   getKeys
  ;;

  delete)
    green "deleting keys from ${PUPPET_DIR}"
    for key in ${KEYS}
    do
      chmod 777 ${KEY_DEST}/${KEY}
      rm -f ${KEY_DEST}/${key}
    done
  ;;

  *)
    usage "Unknown option ${COMMAND}"
  ;;
  
esac

green ${KEY_DEST}:
ls -l ${KEY_DEST}

