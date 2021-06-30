#!/bin/bash
#########################################################################
## perf.sh
## Run this script as root with the following command:
## nohup bash -c ./perf.sh
## Stop this script with kill -2 <pid> or ctrl-c
##   killing it in this way will force the cleanup function to run and 
##   produce a zip file containing all the logs in $LOGDIR
#########################################################################
LOGDIR=$HOME/perf
SLEEP_SECONDS=900

procs="java"
getDate() {
  date --iso-8601=seconds
}

log() {
  message=$1
  echo "$(getDate) $message"
}

getPids() {
  proc=$1
  ps aux | grep -v grep | grep $proc |  awk '{print $2}'
}

dolsof()  {
  pid=$1
  filecount=$(ls -l /proc/$pid/fd | wc -l)
  log "filecount for pid $pid is $filecount"
  ls -al /proc/$pid/fd > $LOGDIR/$(getDate)_${pid}_fd.out
  lsof -p $pid > $LOGDIR/$(getDate)_lsof_${pid}.out
}

doNetstat() {
  netstat -anp > $LOGDIR/$(getDate)_netstat.out
}

runLoop() {
  proc=$1
  pids=$(getPids $proc) 
  for pid in $pids 
  do
    log "running loop for process $proc pid $pid"
    dolsof $pid
    doNetstat
  done
}

mkLogDir() {
  if [ ! -d $LOGDIR ];then
    mkdir -p $LOGDIR
  fi
}

cleanup() {
  echo "Exiting"
  zipfile=$HOME/perf_$(getDate)_$$.zip
  zip -r  $zipfile $LOGDIR/*
  cat << FIN
#########################################################################
## PERF RESULTS ARE IN ZIP FILE $zipfile
#########################################################################

FIN
  exit 0
}

trap cleanup SIGINT
trap cleanup 


main() {
  mkLogDir
  while [ true ]
  do
    for proc in $procs
    do
      runLoop $proc
    done
  sleep $SLEEP_SECONDS
  done

}

main
