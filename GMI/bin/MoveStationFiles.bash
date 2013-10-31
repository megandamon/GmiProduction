#!/bin/bash

#export workflowConfig=$NED_WORKING_DIR/WorkflowConfigs.bash
export workflowConfig=$NED_WORKING_DIR/.exp_env.bash
echo $workflowConfig
. $workflowConfig

echo "------------------------"
echo "NED_USER: $NED_USER"
echo "NED_WORKING_DIR: $NED_WORKING_DIR"
echo "------------------------"
echo ""

export stationDirectory=$WORK_DIR/completed/$YEAR/stations
echo "----------------------------"
echo "Move station files to: $stationDirectory"
echo "------------------------"
echo ""


# Switched from "mv" to "find -exec mv" to avoid [Argument list too long] error on OS X
#echo "ssh $NED_USER@$MACH mv $WORK_DIR/*profile.nc $stationDirectory"
echo "ssh $NED_USER@$MACH find $WORK_DIR  -maxdepth 1 -name \"*profile.nc\" -exec mv {} $stationDirectory \;"
#ssh $NED_USER@$MACH mv $WORK_DIR/*profile.nc $stationDirectory
ssh $NED_USER@$MACH "find $WORK_DIR  -maxdepth 1 -name \"*profile.nc\" -exec mv {} $stationDirectory \;"
export outputCode=$?
echo "output:  $outputCode"


if [ "$outputCode" == "0" ]; then
	echo "Stations moved to $stationDirectory"
elif [ "$outputCode" == "1" ]; then	
	echo "Stations NOT moved to $stationDirectory"
else
	echo "Don't understand this code:  $outputCode"
	exit -1
fi

echo "----------------------------"
echo "Getting file count from: $stationDirectory"
echo "------------------------"
echo ""

# Switched from "mv" to "find -exec mv" to avoid [Argument list too long] error on OS X
echo "ssh $NED_USER@$MACH find $stationDirectory -type f -print0 | tr -dc '\0' | wc -c"
#numStationFiles=`ssh $NED_USER@$MACH ls $stationDirectory/*nc | wc -l`
numStationFiles=`ssh $NED_USER@$MACH find $stationDirectory -type f -print0 | tr -dc '\0' | wc -c`
#trim leading whitespace with echo trick:
numStationFiles=`echo $numStationFiles`
echo "num stations: $numStationFiles"
echo "export numStationFiles=$numStationFiles" >> $workflowConfig
	
echo "Success. Exiting"
exit 0
