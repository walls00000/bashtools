OLDPWD=`pwd`
for i in "$PUPPET1" "$PUPPET2" "$PUPPET3" "$PUPPET4"
do
  echo -n "$i: "
  cd $i && git br | grep \*
done
cd $OLDPWD
