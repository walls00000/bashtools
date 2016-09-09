cat << FIN > /tmp/motd
###########################################################
##                                                       ##
##                   TESTING ONLY                        ##
##                                                       ##
###########################################################
FIN

for i in $@
do
  echo $i
  scp /tmp/motd root@$i:/etc/motd
done
