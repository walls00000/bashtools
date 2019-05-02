source ~/bin/functions.sh

usage() {
  if [ $# -gt 0 ]; then
    red "$@" 
  fi
  cat << FIN
$PROG </path/to/remoteps.log>
FIN
  exit 1
}

if [ $# -ne 1 ]; then
  usage "Please provide a path to the remoteps.log"
fi

LOGFILE=$1

cat $LOGFILE | grep "Completed command.*took" | sed -e 's/.*took //' -e 's/ sec.*//' | sort -n > z
echo -n "Worst case seconds: "
tail -1 z
echo -n "Median seconds : "
lines=`cat z |wc -l `; median=$(($lines/2));sed "${median}q;d" z
echo -n "95% seconds : "
lines=`cat z |wc -l `; ninetyfifth=$(($lines*95/100));sed "${ninetyfifth}q;d" z
echo -n "Average seconds : "
cat z | awk ' { l++; t+=$1 } END { print t/l }' 
