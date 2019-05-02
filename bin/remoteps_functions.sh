#!/bin/bash
##################################################
SUCCESS=3
FAIL=1
UPLOG="/var/log/svt-upgrade.log"
. /var/tmp/build/bin/svt_functions
log() {
    svt_log "$@" >>$UPLOG
}

##################################################

START_STOP_DAEMON="/sbin/start-stop-daemon"
REMOTEPS_PROCNAME="remotepsapp-static"
REMOTEPS_PIDFILE="/run/${REMOTEPS_PROCNAME}.pid"
REMOTEPS_PORTFILE="/run/${REMOTEPS_PROCNAME}.port"
NETSTAT="/bin/netstat"
TAIL="/usr/bin/tail"
AWK="/usr/bin/awk"
SED="/bin/sed"
SORT="/usr/bin/sort"
UNIQ="/usr/bin/uniq"
PORT_RANGE="2112 3113"


# Set $OPEN_PORT to the first free port number within the given range or return $FAIL
suggest_port()
{
    local port_start=$1
    local port_end=$2
    if [ "X$port_start" == "X"} ] || [ "X$port_end" == "X" ];then
        log "Cannot suggest port without a valid port range"
        return $FAIL
    fi
    local used_ports=$($NETSTAT -lunt | $TAIL -n +3 | $AWK '{print $4}' | $SED 's/.*://' | $SORT | $UNIQ)
    for ((port=$port_start; port <= $port_end; port++)); do
        echo "$used_ports" | grep -q $port 
        local ret=$?
        if [ 1 -eq $ret ];then
            log "Found open port on $port"
            OPEN_PORT=$port
            return 0
        fi
    done
   log "Couldn't find an open port with range ${port_start}-${port_end}"
   return $FAIL
}

set_remoteps_port() {
    set -x
    if [ -f ${REMOTEPS_PORTFILE} ];then
        REMOTEPS_ALT_THRIFT_PORT=$(<$REMOTEPS_PORTFILE) 
    fi
    if [ "X$REMOTEPS_ALT_THRIFT_PORT" == "X" ]; then
        suggest_port $PORT_RANGE
        local ret=$?
        if [ $ret -eq 0 ];then
           REMOTEPS_ALT_THRIFT_PORT=$OPEN_PORT
        else
            "Couldn't set an alternate port for $REMOTEPS_PROCNAME"
            return $ret
        fi
    fi
    echo $REMOTEPS_ALT_THRIFT_PORT > $REMOTEPS_PORTFILE 
    export REMOTEPS_ALT_THRIFT_PORT;
    set +x
    return 0
}
open_fwport() {
    local port=$1
    iptables -C INPUT -p tcp --dport $port -j ACCEPT > /dev/null 2>&1
    local ret=$?
    if [ 1 -eq $ret ];then
        log "Opening firewall for remotepsapp-static on port $port"
        iptables -A INPUT -p tcp --dport $port -j ACCEPT 
    else
        log "Firewall rule for remotepsapp-static is already active on $port"
    fi
}

stop_remoteps()
{
    local rps_pid=$(<$REMOTEPS_PIDFILE)
    if [ "X$rps_pid" == "X" ];then
        log "Couldn't kill $REMOTEPS_PROCNAME because there is no pid"
        return $FAIL
    fi
    log "Checking health of remoteps at PID $rps_pid"
    kill -n 0 $rps_pid 2>/dev/null
    if [[ $? -ne 0 ]]; then
        log "WARN: $REMOTEPS_PROCNAME pid file is present but process is not found; Cleaning up $REMOTEPS_PIDFILE"
        rm -f $REMOTEPS_PIDFILE
        return 0
    fi

    log "Stopping $REMOTEPS_PROCNAME process pid=$rps_pid"
    if [ "X${rps_pid}" == "X" ];then
        log "Can't find pid for $REMOTEPS_PROCNAME process"
        return $FAIL
    fi
    kill -n 15 $rps_pid
    ret=$?
    if [ $ret -eq 0 ];then
        log "Stopped $REMOTEPS_PROCNAME process pid=$rps_pid"
        log "Far above the world"
        log "Planet Earth is blue"
        log "And there's nothing I can do . . . "
        rm $REMOTEPS_PIDFILE
        rm -f $REMOTEPS_PORTFILE
        return 0
    else
        log "Couldn't stop $REMOTEPS_PROCNAME process pid=$rps_pid"
        return $FAIL
    fi
}

start_remoteps()
{
    local thrift_port=$1
    if [ "X$thrift_port" == "X" ];then
        log "No thrift port provided aborting remoteps startup . . . And there's nothing I can do"
        return $FAIL
    fi

    if portIsListening $thrift_port; then
        log "This is Major Tom to Ground Control . . . $REMOTEPS_PROCNAME is already running on port $thrift_port"
        return 0
    fi

    INSTANCE=0
    #. "\$APPSETUP"
    #. "\$SVTBUILD/bin/svt_functions"

    log "Starting $REMOTEPS_PROCNAME on port $thrift_port"

    # Keep the previous svt-remoteps-static.out around for forensic purposes
    LOG_FILE="/var/svtfs/$INSTANCE/log/remotepsapp-static.out"
    [ ! -e $LOG_FILE ] || mv $LOG_FILE $LOG_FILE.1

    export MALLOC_ARENA_MAX=1
    # Use an alternate thrift port
    export REMOTEPS_ALT_THRIFT_PORT=$thrift_port
    cmd="$START_STOP_DAEMON --chdir $SVTINSTDIR/log \
--start --chuid svtremoteps \
--user svtremoteps \
--group svtremoteps \
--exec $SVTBUILD/bin/$REMOTEPS_PROCNAME \
-- $INSTANCE"
    log "starting $REMOTEPS_PROCNAME with command: '$cmd'"
    $cmd >$LOG_FILE 2>&1 &
    local rps_pid=$!
    echo $rps_pid > $REMOTEPS_PIDFILE
    log "Started $REMOTEPS_PROCNAME pid: $rps_pid"
    waitForListeningPort $thrift_port $REMOTEPS_PROCNAME >> $UPLOG
    if ! portIsListening $thrift_port; then
        log "ABORT!  ABORT!  ABORT!"
        log "Your circuit's dead, there's something wrong! Can you hear me, Major Tom?"
        log "$REMOTEPS_PROCNAME can't hear us :("
        return $FAIL
    fi
    log "This is Major Tom to Ground Control"
    log "I'm stepping through the door"
    log "$REMOTEPS_PROCNAME is running at full bore" 
    return 0
}

