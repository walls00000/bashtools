MAC="00:50:56:a9:9c:ae"
HOSTNAME="foreman-prod01"
NETWORK="192.168.12"
NETMASK="255.255.255.0"
IP="${NETWORK}.5"
DOMAIN="us-east02.simplivt.local"
ROUTER="${NETWORK}.1"
DNS="${NETWORK}.1"

#configure /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i "s/HWADDR=.*/HWADDR=${MAC}/" /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i "s/IPADDR=.*/IPADDR=${IP}/" /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i "s/NETMASK=.*/NETMASK=${NETMASK}/" /etc/sysconfig/network-scripts/ifcfg-eth0

#configure /etc/sysconfig/network
sed -i "s/HOSTNAME=.*/HOSTNAME=${HOSTNAME}.${DOMAIN}/" /etc/sysconfig/network
sed -i "s/GATEWAY=.*/GATEWAY=${ROUTER}/" /etc/sysconfig/network

#configure /etc/resolv.conf
echo nameserver ${DNS} > /etc/resolv.conf

#fix eth0 bug
#sys-unconfig
#touch /.unconfigured
rm -f /etc/udev/rules.d/*-persistent-*.rules
reboot
