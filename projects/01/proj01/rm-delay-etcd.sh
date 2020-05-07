#!/bin/sh
DEV=lo
IP=127.0.0.1

echo "Removing all network slowdown on interface $DEV"
tc qdisc del dev $DEV root
echo "Should show empty qdisc  (three lines, starting: qdisc noqueue 0):"
tc -s qdisc ls dev $DEV
echo "Should show empty filter (empty  output):"
tc -s filter ls dev $DEV
