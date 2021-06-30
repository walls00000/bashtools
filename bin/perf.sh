#########################################################################
## perf.sh
## Run this script with the following command:
## nohup bash -c ./perf.sh
## Stop this script with kill -2 <pid> or ctrl-c
##   killing it in this way will force the cleanup function to run and 
##   produce a zip file containing all the logs in $LOGDIR
##   Note:  a kill signal may need to wait for the sleep to complete 
##          before registering
#########################################################################
LOGDIR=$HOME/perf
SLEEP_SECONDS=30
PROC="java"

getDate() {
  date --iso-8601=seconds
}

getFilenameDate() {
  date +%F-%H-%M-%S
}

log() {
  message=$1
  echo "$(getDate) $message" >> $LOGDIR/perf.log
}

getPids() {
  proc=$1
  ps aux | grep -v grep | grep $proc |  awk '{print $2}'
}

dolsof()  {
  pid=$1
  filecount=$(ls -l /proc/$pid/fd | wc -l)
  log "filecount for pid $pid is $filecount"
  #ls -al /proc/$pid/fd > $LOGDIR/$(getDate)_${pid}_fd.out
  lsof -p $pid > $LOGDIR/$(getFilenameDate)_lsof_${pid}.out
}

doTop() {
  pid=$1
  top -n 1 -H -p $pid > $LOGDIR/$(getFilenameDate)_${pid}_top.out
}

doNetstat() {
  netstat -anp > $LOGDIR/$(getFilenameDate)_netstat.out
}

doThreadDumpJ() {
  pid=$1
  jstack -l $pid > $LOGDIR/$(getFilenameDate)_${pid}_jstack.out
}

doThreadDumpK() {
  # The threaddump is not printed to stdout on a kill -3. Output will be in the application log
  # keeping the log file nonetheless
  pid=$1
  kill -3 $pid > $LOGDIR/$(getFilenameDate)_${pid}_thread_dump.out
}

doThreadDump() {
  pid=$1
  count=$2
  mod=$(($count % 4))
  if [ $mod -eq 0 ];then
    log "Thread dump on count $count"
    doThreadDumpJ $pid
    doThreadDumpK $pid
  fi
}

runLoop() {
  proc=$1
  count=$2
  pids=$(getPids $proc) 
  for pid in $pids 
  do
    log "--- $proc $pid ---"
    dolsof $pid
    doNetstat
    doThreadDump $pid $count
    doTop $pid
  done
}

mkLogDir() {
  if [ ! -d $LOGDIR ];then
    mkdir -p $LOGDIR
  fi
}

cleanup() {
  echo "Exiting"
  local parent=$(dirname $LOGDIR)
  local directory=$(echo $LOGDIR | sed 's/.*\///')
  pushd $parent
  local filename=perf_$(getFilenameDate)_$$
  local zipfile=${filename}.zip
  local tarfile=${filename}.tar
  echo "----- CREATING TAR GZ ${parent}/${tarfile}.gz ----"
  tar cvf $tarfile $directory
  gzip -9 $tarfile
  echo "----- CREATING ZIP FILE ${parent}/${zipfile} ----"
  zip -r  $zipfile $directory/*
  popd
  cat << FIN
#########################################################################
## PERF RESULTS ARE IN THE FOLLOWING FILES: 
## ${parent}/$tarfile.gz
## ${parent}/$zipfile
#########################################################################

FIN
  exit 0
}



trap cleanup SIGINT
mkLogDir
count=1
while :
do
  log "---------------- $(getDate) Iteration $count  ----------------" 
  runLoop $PROC $count
  sleep $SLEEP_SECONDS &
  wait $!
  count=$(($count+1))
done


