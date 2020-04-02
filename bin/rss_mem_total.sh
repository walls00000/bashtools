## Get the total RSS from ps aux --sort -rss
FILE=$1

total_rss=0
total_vsz=0

readFields() {
  #VSZ
  vsz=`echo "$@" | awk '{print $5}'`
  if [ "X${vsz}" != "XVSZ" ];then
    #echo "$vsz" 
    total_vsz=`expr $vsz + $total_vsz`
  fi
  #RSS
  rss=`echo "$@" | awk '{print $6}'`
  if [ "X${rss}" != "XRSS" ];then
    #echo "$rss" 
    total_rss=`expr $rss + $total_rss`
  fi
}

readLine() {
 file=$1
 echo "Reading file: $file"
 while IFS='' read -r line || [[ -n "$line" ]]; do
   #echo "$line"
   readFields $line
 done < "$file"
}

readLine $FILE
total_vsz_mb=`expr $total_vsz / 1024`
echo "TOTAL_VSZ: $total_vsz Kb $total_vsz_mb Mb"

total_rss_mb=`expr $total_rss / 1024`
echo "TOTAL_RSS: $total_rss Kb $total_rss_mb Mb"
