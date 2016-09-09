#!/bin/bash
while true
do 
 curl -X GET http://www.google.com &> /dev/null
 echo -n '.'
done
