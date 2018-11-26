#!/bin/bash

#export workflowConfig=$NED_WORKING_DIR/WorkflowConfigs.bash
export workflowConfig=$NED_WORKING_DIR/.exp_env.bash
echo $workflowConfig
. $workflowConfig

# Need to get $colDiagStationsNames array from WorkflowConfigs.bash file
. $NED_WORKING_DIR/WorkflowConfigs.bash
# Now split the single comma-separated string into an array
IFS=', ' read -a colDiagStationsNames <<< "$colDiagStationsNames"

echo "------------------------"
echo "NED_USER: $NED_USER"
echo "NED_WORKING_DIR: $NED_WORKING_DIR"
echo "STN_WORK_DIR: $STN_WORK_DIR"
echo "------------------------"
echo ""


echo "Current date: " $CURRENT_DATE

. $NED_WORKING_DIR/$NED_UNIQUE_ID/bin/ReturnMonth.bash
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
echo "numStations = $numStations"
echo "1st station: ${colDiagStationsNames[0]}"
echo "317th station: ${colDiagStationsNames[316]}"
echo "318th station: ${colDiagStationsNames[317]}"

echo "ssh $NED_USER@$MACH ls $STN_WORK_DIR/gmi*$EXP_NAME*${currentMonth}_*nc | wc -l"
remoteStations=`ssh $NED_USER@$MACH ls $STN_WORK_DIR/gmi*$EXP_NAME*${currentMonth}_*nc | wc -l`
echo "remoteStations = $remoteStations"
if [ "$numStations" -ne "$remoteStations" ]; then
	echo "Number of stations in workflow configuration is not consistent with remote system stations"
	echo "Workflow config: $numStations"
	echo "Remote system: $remoteStations"
	exit -1
fi

if [ "$VERBOSE_STATION_CHECK" == "True" ]; then 
	for station in "${colDiagStationsNames[@]}" 
	do 
		echo "ssh $NED_USER@$MACH ls $STN_WORK_DIR/gmi*$EXP_NAME*$currentMonth*$station*nc"
		ssh $NED_USER@$MACH ls $STN_WORK_DIR/gmi*$EXP_NAME*$currentMonth*$station*nc
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
