svatools=$HOME/SVA/tools
svatar=${svatools}/sva.tar
for ovc in $SVAS
do
  scp $svatar ${ovc}:
  ssh ${ovc} tar xf sva.tar
  ssh ${ovc} source rpsbins.sh
done


