#!/bin/bash
#
# Power on/off ATX remotely, get power LED status
# Usage:
# 	action.sh [*|off|long|dry]
#
# Default action is "on" (no param specified)
# off - single power button press, acpi should initiate graceful shutdown
# long - long press, acpi should power off immediately
# dry - only show status

PIN_LED=22
PIN_POWER=24
OFF_TIME=5
WAIT_TIME=20
SWITCH_TIME=1
server=myservername

if [ "$1" == "long" ]
then
	echo "Holding power for $OFF_TIME seconds"
	gpio mode $PIN_POWER output
	gpio write $PIN_POWER 1
	sleep $OFF_TIME
	gpio write $PIN_POWER 0
	echo "Done"
	exit 0
fi

echo Checking status...

gpio mode $PIN_LED input
lednorm=`gpio read $PIN_LED`
ping -c 1 $server 2>&1 >/dev/null
rcnorm=$?

# online: ping 0, LED on: gpio returns 0
if [ "$rcnorm" == "0" ]
then
	humanping="online"
else
	humanping="offline"
fi
if [ "$lednorm" == "0" ]
then
    humanled="on"
else
    humanled="off"
fi

echo "Ping: $humanping, LED: $humanled"

if [ "$1" == "dry" ]
then
	echo "Dry run. Exitting"
	exit 0
fi

# host online, no action specified = stop
if [ "$rcnorm" == "0" ] && [ "$1" != "off" ]
then
	echo "Host $server is online, but param \"off\" not specified. Exitting"
	exit 0
fi

# host offline and ATX power is on, no action specified  = boot delay, stop
if [ "$rcnorm" != "0" ] && [ "$lednorm" == "0" ] && [ "$1" != "off" ]
then
	echo "ATX is ON, but ping did not respond. Still booting? Exitting"
	exit 0
fi

echo "Power switch"
gpio mode $PIN_POWER output
gpio write $PIN_POWER 1
sleep $SWITCH_TIME
gpio write $PIN_POWER 0
date

count=$WAIT_TIME
while [[ $count -ne 0 ]]
do
    led=`gpio read $PIN_LED`
    ping -c 1 $server 2>&1 >/dev/null
    rc=$?

    echo "$count. Ping prev: $rcnorm, gpio prev: $lednorm, ping now: $rc, gpio now: $led" 

    # compare to previous ping and gpio, if changed - break, done
    if [[ $rc -ne $rcnorm ]] || [[ $led -ne $lednorm ]]; then  break;  fi
    ((count = count - 1))
    sleep 2
done

# if loop broke before counter reached - power toggled
if [[ $count -ne 0 ]]
then
    echo "Success"
else
    echo "Sever does not respond. Timeout"
fi

date
