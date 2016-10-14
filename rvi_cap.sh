#!/bin/bash
echo -e "current path: "

path=$(cd "$(dirname "$0")"; pwd)
echo -e "\t${path}"

echo -e  "\n\nlookup idevice's udid : "

udid=`system_profiler SPUSBDataType | sed -n  -e '/iPad/,/Extra/p' -e '/iPhone/,/Extra/p' | grep "Serial Number:.*" | sed s#".*Serial Number: "##`

if [ "$udid" == "" ]; then 
    echo -e "please insert your iphone."
    exit 0;
fi

echo -e "\tudid : ${udid}"

echo -e "\n\ntry to map rvi interface : "

interface=`rvictl -L | grep ${udid} | sed s#".*with interface"##`

if [ "$interface" = "" ]; then
    echo -e "\t${udid} have not map to rvi.."
    ok=`rvictl -s ${udid}`
    echo -e "\t{ok}"
fi

interface=`rvictl -L | grep ${udid} | sed s#".*with interface"##`
if [ "$interface" = "" ]; then
    echo -e "\tERROR : map ${udid} to rvi fail."
    exit 0
fi

echo -e "\t${interface}"

echo -e "\n\nlookup tcpdump : "

tcpdump="/usr/sbin/tcpdump"

if [ ! -x "$tcpdump" ]; then
    echo -e "\t${tcpdump} not exist. use ./tcpdump.."
    tcpdump="${path}/tcpdump"
    if [ ! -f "$tcpdump" ]; then
        echo -e "\tERROR : tcpdump not exist, please copy it to $path.."
        exit 0
    fi
    ok=`chmod 755 ${tcpdump}`
fi

echo -e "\tfind ${tcpdump}"

timestamp=`date  +"%Y%m%d_%H%M%S"`

echo -e "\ncapture package on ${interface}: "
echo -e  "\t${path}/${timestamp}.pcap ..";
echo -e "\n\n"

ok=`sudo tcpdump -i ${interface} -s0 -w ${path}/${timestamp}.pcap`
