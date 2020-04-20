#!/bin/bash
source $HOME/bin/functions.sh
declare -A EXCEPTION_MESSAGE_MAP
declare -A EXCEPTION_ERROR_NUM_MAP

usage() {
  if [ $# -gt 0 ];then
    red "$@"
  fi
  cat << FIN

  $0 <TaskException1> [<TaskException2>] . . . 

FIN
  exit 1
}

checkEnv() {
    if [ -z ${MODULES} ]; then
        usage "MODULES is not set.  Please define MODULES to be the root of your projects, as set by svtsetup"
    fi
}

showEnv() {
    cat << FIN
    MODULES               '$MODULES'
    TASK_EXCEPTION_HEADER '$TASK_EXCEPTION_HEADER'
    ERRORS_XML            '$ERRORS_XML'
FIN
}
parseCommandline() {
   if [ $# -lt 1 ];then
       usage "Please provide the name of a TaskException"
   fi 

   EXCEPTIONS="$@"
}

checkControlRepo() {
    if [ ! -d $MODULES/control ]; then
        usage "The control repository is not found under $MODULES.  Please verify that $MODULES/control exists"
    fi  
    export CONTROL_REPO=$MODULES/control
}

checkErrorsRepo() {
    if [ ! -d $MODULES/errors ]; then
        usage "The errors repository is not found under $MODULES.  Please verify that $MODULES/errors exists"
    fi  
}

setErrorsXml() {
    checkErrorsRepo
    export ERRORS_XML=$(find $MODULES/errors -name errors.xml | grep -v build)
}

setTaskExceptionHeader() {
    checkErrorsRepo
    export TASK_EXCEPTION_HEADER=$(find $MODULES/errors -name taskexception.hpp)
}

parseTaskExceptionHeader() {
    echo "Reading $TASK_EXCEPTION_HEADER"
    local RECORD=false;
    while IFS='' read -r line || [[ -n "$line" ]]; do
        echo $line | grep -q ^TASK_EXCEPTION || continue 
        #echo "$line"
        local NAME=$(echo $line | awk -F, '{print $1}' | sed 's/TASK_EXCEPTION_CLASS(//' | tr -d '[:space:]')
        local ERROR_NUM=$(echo $line | awk -F, '{print $2}' | sed 's/)//' | tr -d '[:space:]')
        EXCEPTION_ERROR_NUM_MAP["$NAME"]="$ERROR_NUM"
        #echo "NAME=$NAME ERROR_NUM=${EXCEPTION_ERROR_NUM_MAP[$NAME]}"
    done < $TASK_EXCEPTION_HEADER
}

parseErrorsXml() {
    echo "Reading $ERRORS_XML"
    local START_LINE=false;
    local MESSAGE_LINE=false;
    local END_LINE=false;
    local ERROR_NUM=""
    local MESSAGE=""
    while IFS='' read -r line || [[ -n "$line" ]]; do
        #echo "$line"
        echo "$line" | grep -q 'description type=' && START_LINE="true"
        echo "$line" | grep -q 'message lang=' && MESSAGE_LINE="true"
        echo "$line" | grep -q '/description' && END_LINE="true"
        if [ "X${START_LINE}" == "Xtrue" ];then
            #echo "RECORD $line"
            ERROR_NUM=$(echo "$line" | awk -F. '{print $2}' | sed 's/\">//' | tr -d '[:space:]')
            START_LINE=false;
        fi
        if [ "X${MESSAGE_LINE}" == "Xtrue" ];then
            #echo "MESSAGE $line"
            MESSAGE=$(echo "$line" | awk -F\> '{print $2}' | sed 's/<\/.*//')
            MESSAGE_LINE="false"
        fi
        if [ "X${END_LINE}" == "Xtrue" ];then
            #echo "RECORD END $line"
            EXCEPTION_MESSAGE_MAP["$ERROR_NUM"]="$MESSAGE"
            #echo "ERROR_NUM=$ERROR_NUM MESSAGE=${EXCEPTION_MESSAGE_MAP[$ERROR_NUM]}"
            END_LINE="false"
        fi
    done < $ERRORS_XML
}

findWhereThrown() {
    local EX=$1
    pushd $CONTROL_REPO > /dev/null 2>&1
    grepResults=$(while read line; do echo "$line"; done <<< $(grep -irn $EX | grep throw))
    popd > /dev/null 2>&1
    echo "$grepResults" 
}

showException() {
    for EX in $@
    do
    NUM=${EXCEPTION_ERROR_NUM_MAP[$EX]}
    MESSAGE=${EXCEPTION_MESSAGE_MAP[$NUM]}
    WHERE_THROWN="$(findWhereThrown $EX)"
    cat << FIN
EXCEPTION: '$EX' ERROR_NUM: '$NUM' MESSAGE: '$MESSAGE' 
------------------------------------------------------
$WHERE_THROWN
------------------------------------------------------
FIN
    done
}
checkEnv
parseCommandline $@
setTaskExceptionHeader
setErrorsXml
checkControlRepo
showEnv
parseTaskExceptionHeader
parseErrorsXml
showException $EXCEPTIONS
