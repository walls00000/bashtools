FILE=$1

readLine() {
 file=$1
 echo "Reading file: $file"
 while IFS='' read -r line || [[ -n "$line" ]]; do
   echo "$line"
 done < "$file"
}

set -x
readLine $FILE
set +x
