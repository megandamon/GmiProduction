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

. $NED_WORKING_DIR/bin/ReturnMonth.bash
export currentYear=${CURRENT_DATE:0:4}
export numMonth=${CURRENT_DATE:4:2}
export currentMonth='xxx'
returnMonth $numMonth $currentMonth

if [ "$currentMonth" = "xxx" ]; then
        echo "Month not recognized"
    	exit -1
fi



fileName="gmic_"$EXP_NAME"_"$currentYear"_"$currentMonth".profile.nc"
echo "----------------------------"
echo "Archiving processed station data for $currentMonth"
echo "------------------------"
echo ""

echo "ssh $REMOTE_USER@$MACH mv $WORK_DIR/$fileName $ARCHIVE_DIR/$currentYear/stations/"
ssh $REMOTE_USER@$MACH mv $WORK_DIR/$fileName $ARCHIVE_DIR/$currentYear/stations/
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a moving the data to: $ARCHIVE_DIR/$currentYear/stations/"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

echo "exiting"
exit 0
