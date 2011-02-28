#!/bin/bash

# Author: Bastian Therres
# 

#######################################

#
# networks
#

ANYADDR="0/0"

OURNET="192.168.0.0/255.255.255.0"
OURDEV="eth0"

VPNNET="10.0.0.0/255.255.255.0"
VPNDEV="tun0"

#
# open ports (see /etc/services for port-names)
#

UDPIN="openvpn"
UDPININTERN="microsoft-ds,imap2,imaps"
UDPOUT="domain,ssh"

TCPIN="ssh,ftp,ftp-data" # define a passive port range for your ftp like 1234:5678 if needed
TCPININTERN="microsoft-ds,smtp,ssmtp,imap2,imaps"
TCPOUT="www,ftp,ftp-data,domain,ssh"

#######################################

#
# install modules
#

modprobe ip_tables
modprobe ip_conntrack

#######################################

case "$1" in
        start)
                #
                # flush all tables
                #
                iptables -F FORWARD
                iptables -F INPUT
                iptables -F OUTPUT
                #
                # forwarding/routing only between VPNNET and OURNET
                #
                iptables --policy FORWARD DROP
                iptables --append FORWARD --in-interface $OURDEV --out-interface $VPNDEV --source $OURNET --jump ACCEPT
                iptables --append FORWARD --in-interface $VPNDEV --source $VPNNET --destination $OURNET --jump ACCEPT
                #
                # incoming pakets
                #
                iptables --policy INPUT DROP
                #iptables --append INPUT --in-interface $VPNDEV --jump ACCEPT
                iptables --append INPUT --source $ANYADDR -p tcp -m multiport --destination-ports $TCPIN --jump ACCEPT
                iptables --append INPUT --source $ANYADDR -p udp -m multiport --destination-ports $UDPIN --jump ACCEPT
                iptables --append INPUT --in-interface $OURDEV --source $OURNET -p tcp -m multiport --destination-ports $TCPININTERN --jump ACCEPT
                iptables --append INPUT --in-interface $VPNDEV --source $VPNNET -p tcp -m multiport --destination-ports $TCPININTERN --jump ACCEPT
                iptables --append INPUT --in-interface $OURDEV --source $OURNET -p udp -m multiport --destination-ports $UDPININTERN --jump ACCEPT
                iptables --append INPUT --in-interface $VPNDEV --source $VPNNET -p udp -m multiport --destination-ports $UDPININTERN --jump ACCEPT
                iptables --append INPUT -m state --state ESTABLISHED,RELATED --jump ACCEPT
                #
                # outgoing packets
                #
                iptables --policy OUTPUT DROP
                iptables --append OUTPUT --out-interface $VPNDEV --jump ACCEPT
                iptables --append OUTPUT --out-interface $OURDEV -p tcp -m multiport --destination-ports $TCPOUT --jump ACCEPT
                iptables --append OUTPUT --out-interface $OURDEV -p udp -m multiport --destination-ports $UDPOUT --jump ACCEPT
                iptables --append OUTPUT -m state --state ESTABLISHED,RELATED --jump ACCEPT
        ;;
        stop)
                #
                # set default policy to accept
                # flush all tables
                #
                iptables --policy FORWARD ACCEPT
                iptables --policy INPUT ACCEPT
                iptables --policy OUTPUT ACCEPT
                iptables -F FORWARD
                iptables -F INPUT
                iptables -F OUTPUT

                echo "iptables turned off"
        ;;
        *)
                echo "start this script with the parameter start or stop"
        ;;
esac

exit 0