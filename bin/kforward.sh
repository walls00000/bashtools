#########################################################################
## kforward.sh a script to run and monitor kubectl port-forward commands.
## This script reads $FORWARD_CONF which should contain any number of
## kubectl port-forward commands one per line  in this format:
##
##   kubectl port-forward <service> -n <namespace> <local_port>:<remote_port>
## example:
##   kubectl port-forward service/integration-gateway-service -n integration-gateway-staging 8443:443
##
## blank lines and lines begining with '#" are ignored.  This script
## runs kubectl commands  in the  background, and monitors the
## connection and pid every 5 seconds.
##
## A ctrl-c  interrupts the monitor and kills the background processes.
##
## run kforward.sh kill to kill any zomby background processes created by this
## script
########################################################################
## TODO: cleanup pid files created by this script
export FORWARD_CONF=${HOME}/forward.conf
PID_DIR=/tmp/kforward

green() {
  echo "[032m$@[0m"
}
red() {
  echo "[031m$@[0m"
}

info() {
    green "INFO $@"
}

error() {
    red "ERROR $@"
}

fatal() {
   red "FATAL $@"
   exit 1
}

getServiceName() {
    local command="$1"
    local service_name=$(echo $line | awk '{print $3}' | sed 's/\//-/g')
    echo "$service_name"
}

getNamespace() {
    local command="$1"
    local namespace=$(echo $line | awk '{print $5}')
    echo "$namespace"
}

getPorts() {
    local command="$1"
    local ports=$(echo $line | awk '{print $6}')
    echo "$ports"
}

getLocalPort() {
    local ports="$1"
    local localPort=$(echo $ports | awk -F: '{print $1}')
    echo $localPort
}

getId() {
    local command="$1"
    local service_name=$(getServiceName "$command")
    local namespace=$(getNamespace "$command")
    local ports=$(getPorts "$command")
    echo "${service_name}_${namespace}_${ports}"
}
runCommand() {
    local command="$1"
    local id=$(getId "$command")
    echo "id=$id"
    $command &
    pid=$!
    echo $pid > "${PID_DIR}/${id}.pid"
}

getPid() {
    local id="$1"
    local pid=$(cat "${PID_DIR}/${id}.pid")
    echo $pid
}

doPs() {
    local mypid="$1"
    ps aux | grep -v grep | awk '{print $2}' | grep -q $mypid && echo true || echo false 
}

doNetstat() {
    local localPort="$1"
    netstat -an | grep -v tcp6 | grep LISTEN | grep -q $localPort && echo true || echo false 
}

isLive() {
    local command="$1"
    local id=$(getId "$command")
    local pid=$(getPid "$id")
    local ports=$(getPorts "$command")
    local localPort=$(getLocalPort $ports)
    #if [[ $(doPs $pid) && $(do_netstat $localPort) ]];then
    if [[ $(doPs $pid) == true  && $(doNetstat $localPort) == true ]];then
        green "RUNNING $command $pid"
    else
        red "STOPPED $command $pid"
    fi
}

doMonitor() {
    local command="$1"
    local id=$(getId "$command")
    local pid=$(getPid "$id")
    isLive "$command"
}

doKill() {
   local command="$1"
   local id=$(getId "$command")
   local pid=$(getPid $id)
   kill -9 $pid
}

cleanup() {
    parseConfig cleanup
    exit 0
}


doAction() {
    local command="$1"
    case $action in
        run)
            runCommand "$line"
        ;;  
        monitor)
            doMonitor "$line"
        ;;  
        cleanup)
            doKill "$line"
        ;;  
        *)  
            echo "$line"
        ;;
    esac
}

prereqs() {
    if [ ! -f $FORWARD_CONF ];then
        fatal "No such file $FORWARD_CONF! Please place kubectl port-forward commands into $FORWARD_CONF"
    fi
    if [ ! -d $PID_DIR ];then
        mkdir -p $PID_DIR
    fi
}

parseConfig() {
    action=$1

    local count=0
    while IFS='' read -r line || [[ -n "$line" ]]; do
        count=$((count + 1))
        ## skip empty lines and lines beginning with #
        if [[ X${line} == X#* ]] || [[ X${line} == X ]];then
            continue
        fi
        nf=$(echo "$line" | awk '{print NF}')
        if [ $nf -ne 6 ];then
            fatal "Poorly formatted command in line ${count}: '$line' Port forward commands have 6 fields"
        fi

        #echo "$line"
        doAction "$line"

    done < "$FORWARD_CONF"
}

loopMonitor() {
    while true
    do
        sleep 5
        clear
        parseConfig monitor
    done
}

trap cleanup SIGINT
prereqs

if [[ X$1 == X*k* ]];then
    cleanup
fi
parseConfig run
loopMonitor



