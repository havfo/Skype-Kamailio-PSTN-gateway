#!/bin/bash

# Variables used in the script
IPTABLES="/sbin/iptables"
IP6TABLES="/sbin/ip6tables"
RTP="16384:17485"

#Flush tables
$IPTABLES -F
$IPTABLES -X

$IP6TABLES -F
$IP6TABLES -X

#Default policy
$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD ACCEPT
$IPTABLES -P OUTPUT ACCEPT

$IP6TABLES -P INPUT DROP
$IP6TABLES -P FORWARD ACCEPT
$IP6TABLES -P OUTPUT ACCEPT

# Allow replies to outgoing requests
$IPTABLES -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IP6TABLES -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow ping
$IPTABLES -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

$IP6TABLES -A INPUT -p ipv6-icmp -m icmp6 --icmpv6-type echo-request -j ACCEPT
$IP6TABLES -A INPUT -p ipv6-icmp -m icmp6 --icmpv6-type 130 -j ACCEPT
$IP6TABLES -A INPUT -p ipv6-icmp -m icmp6 --icmpv6-type 133 -m hl --hl-eq 255 -j ACCEPT
$IP6TABLES -A INPUT -p ipv6-icmp -m icmp6 --icmpv6-type 134 -m hl --hl-eq 255 -j ACCEPT
$IP6TABLES -A INPUT -p ipv6-icmp -m icmp6 --icmpv6-type 135 -m hl --hl-eq 255 -j ACCEPT
$IP6TABLES -A INPUT -p ipv6-icmp -m icmp6 --icmpv6-type 136 -m hl --hl-eq 255 -j ACCEPT
$IP6TABLES -A INPUT -p ipv6-icmp -m icmp6 --icmpv6-type 137 -m hl --hl-eq 255 -j ACCEPT

# loopback rules
$IPTABLES -A INPUT -i lo -j ACCEPT
$IP6TABLES -A INPUT -i lo -j ACCEPT

# SIP
$IPTABLES -A INPUT -p tcp --dport 5064 -j ACCEPT
$IPTABLES -A INPUT -p tcp --dport 5065 -j ACCEPT
$IPTABLES -A INPUT -p udp --dport 5065 -j ACCEPT

$IP6TABLES -A INPUT -p tcp --dport 5064 -j ACCEPT
$IP6TABLES -A INPUT -p tcp --dport 5065 -j ACCEPT
$IP6TABLES -A INPUT -p udp --dport 5065 -j ACCEPT

# RTPEngine
$IPTABLES -I INPUT -p udp -j RTPENGINE --dport $RTP --id 0
$IP6TABLES -I INPUT -p udp -j RTPENGINE --dport $RTP --id 0

# Brute-force block
$IPTABLES -A INPUT -p tcp -m tcp --dport 22 -m state --state NEW -m recent --set --name DEFAULT --rsource
$IP6TABLES -A INPUT -p tcp -m tcp --dport 22 -m state --state NEW -m recent --set --name DEFAULT --rsource
$IPTABLES -A INPUT -p tcp -m tcp --dport 22 -m state --state NEW -m recent --update --seconds 180 --hitcount 3 --name DEFAULT --rsource -j DROP
$IP6TABLES -A INPUT -p tcp -m tcp --dport 22 -m state --state NEW -m recent --update --seconds 180 --hitcount 3 --name DEFAULT --rsource -j DROP

# Allow SSH
$IPTABLES -A INPUT -p tcp --dport 22 -j ACCEPT
$IP6TABLES -A INPUT -p tcp --dport 22 -j ACCEPT

# Save IP-tables and save for enabling after reboot
/sbin/iptables-save > /etc/iptables/firewall.conf
/sbin/ip6tables-save > /etc/iptables/firewall6.conf
