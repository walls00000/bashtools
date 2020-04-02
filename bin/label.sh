#!/bin/bash
###########################################
## label.sh present a colorful banner 
##
## TODO trap ctrl-c and remove the tmp file
## TODO eliminate tmp file
###########################################

source ~/bin/functions.sh
FILE=/tmp/label.$$
FIGLET=/usr/bin/figlet
SLEEPTIME=2

cyclebanner() {
 file=$1
 while true
 do
   echo "Reading file: $file"
   for color in red yellow green blue cyan purple
   do
     clear
     while IFS='' read -r line || [[ -n "$line" ]]; do
       $color "$line"
     done < "$file"
     sleep $SLEEPTIME
   done
 done
}

$FIGLET -w 255 $@ > $FILE
cyclebanner $FILE

rm $FILE
