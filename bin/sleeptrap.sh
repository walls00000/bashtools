cleanup() {
    echo "cleaning up"
    exit 0
}

trap cleanup SIGINT

echo "Sleeping.  Pid=$$"
while :
do
   sleep 10 &
   wait $!
   echo "Sleep over"
done
