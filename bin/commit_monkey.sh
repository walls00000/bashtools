#!/bin/bash
BUG_NUMBER=${1:-BUG-002}
FILENAMES=("file0" "file1" "file2" "file3" "file4" "file5" "file6" "file7" "file8" "file9")
MAX_COMMITS=10
LIMIT=$(( $RANDOM % $MAX_COMMITS + 1))
[[ $DRYRUN && ${DRYRUN-x} ]] &&  echo "--------DRYRUN--------"
for (( i=1; i<=$LIMIT; i++ ));
do
  filename=${FILENAMES[$(( $RANDOM % ${#FILENAMES[@]} ))]}
  echo "Commit $i/$LIMIT for $BUG_NUMBER to $filename"
  fortune | cowsay  >> $filename
  if [[ $DRYRUN && ${DRYRUN-x} ]];then
    echo "git add $filename"
    echo "git commit -m \"${BUG_NUMBER}: This is commit $i to file $filename\""
  else
    git add $filename
    git commit -m "${BUG_NUMBER}: This is commit $i to file $filename"
  fi
done
