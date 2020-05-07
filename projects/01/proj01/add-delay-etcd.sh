#!/bin/sh
DEV=lo
IP=127.0.0.1

# Add a 200ms +/- 100ms delay to TCP traffic on 127.0.0.2
#
# http://linux-tc-notes.sourceforge.net/tc/doc/cls_u32.txt
# https://www.funtoo.org/Traffic_Control
# https://serverfault.com/questions/389290/using-tc-to-delay-packets-to-only-a-single-ip-address/391462#391462
# https://serverfault.com/questions/231880/how-to-match-port-range-using-u32-filter
#https://askubuntu.com/questions/444124/how-to-add-a-loopback-interface

echo "Adding network slowdown on interface ${DEV} to/from TCP ports 11000..11010"
#tc qdisc del dev ${DEV} root

tc qdisc add dev ${DEV} root handle 1: prio
tc qdisc add dev ${DEV} parent 1:3 handle 2: netem delay 200ms 100ms distribution normal
tc filter add dev ${DEV} parent 1:0 protocol ip basic match "(cmp(u16 at 0 layer transport gt 11000) and cmp(u16 at 0 layer transport lt 11010)) or (cmp(u16 at 2 layer transport gt 11000) and cmp(u16 at 2 layer transport lt 11010))" flowid 1:3

# to delay all traffic to/from ${IP} replace the "filter" line with these two
#
#tc filter add dev ${DEV} protocol ip parent 1:0 prio 3 u32 match ip dst ${IP} flowid 1:3
#tc filter add dev ${DEV} protocol ip parent 1:0 prio 3 u32 match ip src ${IP} flowid 1:3

