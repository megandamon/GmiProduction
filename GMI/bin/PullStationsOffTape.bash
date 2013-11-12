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

if [ "$CURRENT_DATE" == "" ]; then
	echo "Setting CURRENT_DATE to START_DATE"
	export CURRENT_DATE=$START_DATE 
else 
	echo "Setting CURRENT_DATE to next month"
	CURRENT_DATE=`$NED_WORKING_DIR/$NED_UNIQUE_ID/bin/util/./IncrementMonth.py -d $CURRENT_DATE` 
fi
echo "export CURRENT_DATE=$CURRENT_DATE" >> $workflowConfig
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
echo "Pulling stations off tape for $currentMonth"
echo "------------------------"
echo ""

echo "ssh $NED_USER@$MACH dmget $ARCHIVE_DIR/$currentYear/stations/*$EXP_NAME*$currentYear*$currentMonth*profile.nc"
ssh $NED_USER@$MACH dmget $ARCHIVE_DIR/$currentYear/stations/*$EXP_NAME*$currentYear*$currentMonth*profile.nc
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a problem pulling the $currentYear $currentMonth files off tape"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

echo "----------------------------"

exit 0
