#!/bin/bash

ORACLE_BASE=<< Provide your Oracle Base path here >>
ORACLE_HOME=<< Provide your Oracle Home here >>
TNS_ADMIN=$ORACLE_HOME/network/admin
ORACLE_SID=<< Provide your Oracle SID here >>
TWO_TASK=<< Provide your Oracle TWO_TASK value here. It is usually same as ORACLE_SID >>
DB_USER=<< Provide database User name >>
DB_PASSWORD=<< Provide database password >>
DBPTR=$DB_USER/$DB_PASSWORD
PATH=$PATH:$ORACLE_HOME/bin
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME/lib32:$ORACLE_HOME/lib

export ORACLE_BASE ORACLE_HOME TNS_ADMIN ORACLE_SID TWO_TASK DB_USER DB_PASSWORD DBPTR PATH LD_LIBRARY_PATH

TIMESTAMPFILE=.
starttime=`timestamp.pl 0`
increment=60 	# This is 1 minutes
pollingtime=`$TIMESTAMPFILE/timestamp.pl $increment`

FILE=$1
RECORDS_IN_AGGREGATION_INTERVAL=$2
#RECORDS_IN_AGGREGATION_INTERVAL=$2
SQLFILE_TEMP=$(echo $FILE | cut -d. -f1)
SQLFILE=$SQLFILE_TEMP.sql
FS=,
COUNT=1

while read DBDSdata
do
	MONAME=$(echo $DBDSdata | cut -d$FS -f1)
	DB_ifInOctets=$(echo $DBDSdata | cut -d$FS -f2)
	DB_ifOutOctets=$(echo $DBDSdata | cut -d$FS -f3)
	DB_ifInErrors=$(echo $DBDSdata | cut -d$FS -f4)
	DB_ifOutErrors=$(echo $DBDSdata | cut -d$FS -f5)
	DB_ifInUnknownProtos=$(echo $DBDSdata | cut -d$FS -f6)
	DB_ifInDiscards=$(echo $DBDSdata | cut -d$FS -f7)
	DB_ifOutDiscards=$(echo $DBDSdata | cut -d$FS -f8)
	DB_dot1dStpPortEnable=$(echo $DBDSdata | cut -d$FS -f9)
	DB_cpmCPUTotal1minRev=$(echo $DBDSdata | cut -d$FS -f10)
	DB_ciscoMemoryPoolUsed=$(echo $DBDSdata | cut -d$FS -f11)
	DB_ciscoMemoryPoolFree=$(echo $DBDSdata | cut -d$FS -f12)
	DB_icmpInEchos=$(echo $DBDSdata | cut -d$FS -f13)
	DB_icmpInEchoReps=$(echo $DBDSdata | cut -d$FS -f14)
	DB_ssnmpInPkts=$(echo $DBDSdata | cut -d$FS -f15)
	DB_snmpOutPkts=$(echo $DBDSdata | cut -d$FS -f16)


	if [ $COUNT -le $RECORDS_IN_AGGREGATION_INTERVAL ]; then
		POLLINGAT=$pollingtime
	else
		COUNT=1
		increment=`expr $increment + 60`
		pollingtime=`$TIMESTAMPFILE/timestamp.pl $increment`
		POLLINGAT=$pollingtime
	fi

	COUNT=`expr $COUNT + 1`
	echo "Count is $COUNT.............Polling time is $POLLINGAT"

cat >> $SQLFILE << EOF
insert into << DB Table Name >> (TIMESTAMP,MONAME,DB_ifInOctets,DB_ifOutOctets,DB_ifInErrors,DB_ifOutErrors,DB_ifInUnknownProtos,DB_ifInDiscards,DB_ifOutDiscards,DB_dot1dStpPortEnable,DB_cpmCPUTotal1minRev,DB_ciscoMemoryPoolUsed,DB_ciscoMemoryPoolFree,DB_icmpInEchos,DB_icmpInEchoReps,DB_ssnmpInPkts,DB_snmpOutPkts) values (to_timestamp('$POLLINGAT','DD-MON-RR HH.MI.SS.FF AM'),'$MONAME',$DB_ifInOctets,$DB_ifOutOctets,$DB_ifInErrors,$DB_ifOutErrors,$DB_ifInUnknownProtos,$DB_ifInDiscards,$DB_ifOutDiscards,$DB_dot1dStpPortEnable,$DB_cpmCPUTotal1minRev,$DB_ciscoMemoryPoolUsed,$DB_ciscoMemoryPoolFree,$DB_icmpInEchos,$DB_icmpInEchoReps,$DB_ssnmpInPkts,$DB_snmpOutPkts);
EOF
done < $FILE

sqlplus $DBPTR @$SQLFILE << INSERTRECORDS
select count(*) from << Table Name >>;
commit;
exit;
INSERTRECORDS

rm -rf $SQLFILE
