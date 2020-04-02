LOGS=$(find . -name svtfs.log | sed 's/svtfs.log//g')

echo "lnav -tr $LOGS"
lnav -tr $LOGS

