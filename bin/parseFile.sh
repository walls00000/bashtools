FILE=$1

readLine() {
 file=$1
 echo "Reading file: $file"
 while IFS='' read -r line || [[ -n "$line" ]]; do
   parse "$line"
 done < "$file" 
}

parse() {
  input="$1"
  #echo "$input"
  out=`echo "$input" | awk -F: '{print $1}'`
  echo $out
}
readLine $FILE
