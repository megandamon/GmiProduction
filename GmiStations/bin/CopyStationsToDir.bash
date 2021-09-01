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
echo "Copying stations to $WORK_DIR $currentMonth"
echo "------------------------"
echo ""

echo "ssh $REMOTE_USER@$MACH cp $ARCHIVE_DIR/$currentYear/stations/*$EXP_NAME*$currentYear*$currentMonth*profile.nc $WORK_DIR"
ssh $REMOTE_USER@$MACH cp $ARCHIVE_DIR/$currentYear/stations/*$EXP_NAME*$currentYear*$currentMonth*profile.nc $WORK_DIR
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a problem copying the $currentYear $currentMonth files to $WORK_DIR"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

echo "----------------------------"

exit 0
