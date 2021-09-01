#!/bin/bash

export workflowConfig=$NED_WORKING_DIR/WorkflowConfigs.bash
echo $workflowConfig
. $workflowConfig

echo "------------------------"
echo "NED_USER: $NED_USER"
echo "REMOTE_USER: $REMOTE_USER"
echo "NED_WORKING_DIR: $NED_WORKING_DIR"
echo "------------------------"
echo ""


echo "Current date: " $CURRENT_DATE

. $NED_WORKING_DIR/bin/ReturnMonth.bash
export currentYear=${CURRENT_DATE:0:4}
export numMonth=${CURRENT_DATE:4:2}
export currentMonth='xxx'
returnMonth $numMonth $currentMonth

if [ "$currentMonth" = "xxx" ]; then
        echo "Month not recognized"
    	exit -1
fi

echo "----------------------------"
echo "Cross Checking Station Names"
echo "------------------------"
echo ""

export numStations=${#colDiagStationsNames[@]}

echo "ssh $REMOTE_USER@$MACH ls $WORK_DIR/gmi*$EXP_NAME*$currentMonth*nc | wc -l"
remoteStations=`ssh $REMOTE_USER@$MACH ls $WORK_DIR/gmi*$EXP_NAME*$currentMonth*nc | wc -l`
if [ "$numStations" -ne "$remoteStations" ]; then
	echo "Number of stations in workflow configuration is not consistent with remote system stations"
	echo "Workflow config: $numStations"
	echo "Remote system: $remoteStations"
	exit -1
fi

if [ "$VERBOSE_STATION_CHECK" == "True" ]; then 
	for station in "${colDiagStationsNames[@]}" 
	do 
		echo "ssh $REMOTE_USER@$MACH ls $WORK_DIR/gmi*$EXP_NAME*$currentMonth*$station*nc"
		ssh $REMOTE_USER@$MACH ls $WORK_DIR/gmi*$EXP_NAME*$currentMonth*$station*nc
		export outputCode=$?
		if [ "$outputCode" != "0" ]; then
	    	echo "Station file $station not found!"
	    	echo "------------------------"
	    	exit -1
		else
			echo "Output check cleared on station $station: $outputCode"
		fi
	done	
else
	echo "Verbose station check not required"
fi		


exit 0



echo "----------------------------"

exit 0
