#!/bin/sh

ip route show
IP_GW=$(ip route | awk '/default/ { print $3 }')
if [ $IP_GW != "" ]; then
	echo ping Gateway ...
	ping -c2 $IP_GW
	if [ $? -eq 0 ]; then
		echo ping Server ...
		ping -c2 www.hella-gutmann.com
	fi
fi

