#!/bin/bash

while getopts f:m:s: input
do
	case "$input" in
	f)	FILE="$OPTARG";;
	m)	MO_POLLED_PER_POLLING_INTERVAL="$OPTARG";;
	s)	SLEEP_TIME="$OPTARG";;
	[?])	echo ""
		echo "Usage: $0: -f <Rawdata filename with fullpath> -m <MO to be polled in each polling interval> -s <polling duration>"
		echo ""
		exit 2;;
	esac
done

SLEEP_TIME=`expr $SLEEP_TIME - 1`

if [ ! -f $FILE ]; then
	echo "$FILE doesn't exists"
	exit 1
fi

epochTime=`perl epoch.pl`
COUNT=1
FILE_COUNT=1
CSVFILE_TEMP=$(echo $FILE | cut -d. -f1)
CSVFILE=$CSVFILE_TEMP-$FILE_COUNT.csv
FS=,
INCREMENT=0

while read data
do

	MONAME=$(echo $data | cut -d$FS -f1)
echo $MONAME
	pdpContextsetupTime=$(echo $data | cut -d$FS -f3)
echo $pdpContextsetupTime
	timeToRegister=$(echo $data | cut -d$FS -f4)
echo $timeToRegister
	httpRoundTripDelay=$(echo $data | cut -d$FS -f5)
echo $httpRoundTripDelay
	MAN_Up=$(echo $data | cut -d$FS -f6)
echo $MAN_Up
	CAN_Up=$(echo $data | cut -d$FS -f7)
echo $CAN_Up
	EDN_Up=$(echo $data | cut -d$FS -f8)
echo $EDN_Up
	MAN_Down=$(echo $data | cut -d$FS -f9)
echo $MAN_Down
	CAN_Down=$(echo $data | cut -d$FS -f10)
echo $CAN_Down
	EDN_Down=$(echo $data | cut -d$FS -f11)
echo $EDN_Down
	SDU_Lost=$(echo $data | cut -d$FS -f12)
echo $SDU_Lost
	SDU_Transmitted=$(echo $data | cut -d$FS -f13)
echo $SDU_Transmitted
	Errored_Bits=$(echo $data | cut -d$FS -f14)
echo $Errored_Bits
	Healthy_Bits=$(echo $data | cut -d$FS -f15)
echo $Healthy_Bits
	GSN_Congestion=$(echo $data | cut -d$FS -f16)
echo $GSN_Congestion
	serviceResourceCapacity=$(echo $data | cut -d$FS -f17)
echo $serviceResourceCapacity
	ServiceRequestLoad=$(echo $data | cut -d$FS -f18)
echo $ServiceRequestLoad

	#echo $COUNT $MO_POLLED_PER_POLLING_INTERVAL
	if [ $COUNT -le $MO_POLLED_PER_POLLING_INTERVAL ]; then
		POLLINGTIME=`expr $epochTime + $SLEEP_TIME  + $INCREMENT`
	else
		sleep $SLEEP_TIME
		mv $CSVFILE $FILE.moved.csv
		COUNT=1
		FILE_COUNT=`expr $FILE_COUNT + 1`
		epochTime=`perl epoch.pl`
		POLLINGTIME=`expr $epochTime + $SLEEP_TIME + $INCREMENT`
	fi

	POLLINGAT=$POLLINGTIME
	COUNT=`expr $COUNT + 1`
	CSVFILE=$CSVFILE_TEMP-$FILE_COUNT.csv


cat >> $CSVFILE << EOF
${MONAME},$POLLINGAT,$pdpContextsetupTime,$timeToRegister,$httpRoundTripDelay,$MAN_Up,$CAN_Up,$EDN_Up,$MAN_Down,$CAN_Down,$EDN_Down,$SDU_Lost,$SDU_Transmitted,$Errored_Bits,$Healthy_Bits,$GSN_Congestion
EOF
done < $FILE
mv $CSVFILE Final_File.csv
