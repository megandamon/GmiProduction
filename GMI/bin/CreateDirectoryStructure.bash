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

echo "----------------------------"
echo "Create archive structure in: $WORK_DIR"
echo "------------------------"
echo ""

export metDirectory=$WORK_DIR/completed/metdata_files
export diagDirectory=$WORK_DIR/completed/$YEAR/diagnostics
export runDirectory=$WORK_DIR/completed/$YEAR/run_info
export stationDirectory=$WORK_DIR/completed/$YEAR/stations

directories=( $metDirectory $diagDirectory $runDirectory $stationDirectory )
for directory in "${directories[@]}"
do
		echo "ssh $NED_USER@$MACH ls $directory/"
		ssh $NED_USER@$MACH ls $directory/
		export outputCode=$?
		echo $directory
		echo "exists? $outputCode"
		if [ "$outputCode" == "0" ]; then
    		echo "$directory exists"
		elif [ "$outputCode" == "2" ] || [ "$outputCode" == "1" ]; then	
			echo "ssh $NED_USER@$MACH mkdir -p $directory"
			ssh $NED_USER@$MACH mkdir -p $directory
		else
			echo "Don't understand this code:  $outputCode"
			exit -1
		fi
done	
 
echo "Success. Exiting"
exit 0
