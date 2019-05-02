LOGDIRS=""
for dir in `find . -name remoteps.log | sed 's/\/remoteps.log//'`
do
  LOGDIRS="$LOGDIRS $dir"
done


xterm -e lnav -tr $LOGDIRS &
