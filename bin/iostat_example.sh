#!/bin/bash
###########################################
## I told iostat to capture the data every two seconds 
## (this is the 2 after the device) and do it 100 times 
## (this is the 100 at the end of the command). This means 
## I captured 200 seconds of data in two-second intervals. 
## The -c option displays the CPU report, -d displays the 
## device utilization report, -x displays extended statistics,
## -t prints the time for each report displayed (good for 
## getting a time history), and -m displays the statistics 
## in megabytes per second (MB/s in the output).
###########################################
device=$1
iostat -c -d -x -t -m $device 2 100

