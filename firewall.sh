#!/bin/bash
#comment: iptable manager tools

#----------------------<Set Variable>--------------------
# define tools
IPT='/sbin/iptables'
IPT_CONF='/etc/sysconfig/iptables'
TIMESTAME=`date "+%Y%m%d%H%M%S"`
IPT_BACKUP_DIR='/root/backup/iptables'
IPT_BACKUP_CONF=${IPT_BACKUP_DIR}/iptables.${TIMESTAME}

# define network
NET_LOCAL='192.168.1.0/24'

# define host
HOST_BAI='192.168.1.1'

# define applicaion
APP_SSH=9022
APP_HTTP=80

#-----------------------<Clear Original Rule>------------
$IPT -t filter -F
#------------------------<Set Default Rule>--------------
$IPT -P INPUT   DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT  ACCEPT
#-----------------------<Set INPUT Rule>-----------------
#define common
$IPT -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i lo   -j ACCEPT

#SSH
$IPT -A INPUT -s $NET_LOCAL -p tcp -m state --state NEW -m tcp --dport $APP_SSH -j ACCEPT

#ICMP
$IPT -A INPUT -s $NET_LOCAL  -p icmp -j ACCEPT

#HTTP
$IPT -A INPUT -p tcp -m state --state NEW -m tcp --dport $APP_HTTP -j ACCEPT

$IPT -A INPUT -j DROP
#-----------------------<Set Forward Rule>-----------------
$IPT -A FORWARD -j DROP

#-----------------------<Test Rule>------------------------
read -t 5 -p "Test firewall rule(Y):" YES
[ -z $YES ] && YES='Y'
if [ $YES = 'Y' ] ; then
    DAEMON_SCRIPT="`mktemp /tmp/firewall.XXXXXXXX`"
    echo '#!/bin/bash' >> $DAEMON_SCRIPT
    echo "sleep 30 " >> $DAEMON_SCRIPT
    echo "service iptables restart" >> $DAEMON_SCRIPT
    . $DAEMON_SCRIPT &

    echo "END"
    exit 0
fi

#-----------------------<Backup Rule>--------------------
read -t 5 -p "Save iptable config and backup(Y):" YES 
[ -z $YES ] && YES='n'
if [ $YES = 'Y' ] ; then
    [ ! -d $IPT_BACKUP_DIR ] && mkdir -p $IPT_BACKUP_DIR
    cp $IPT_CONF $IPT_BACKUP_CONF
    if [ $? -ne 0 ]; then
        exit 1
    fi
    service iptables save
fi
#-----------------------<END>--------------------
echo "The End"
