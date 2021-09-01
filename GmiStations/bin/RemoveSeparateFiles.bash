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



fileNameString="gmic_"$EXP_NAME"_"$currentYear"_"$currentMonth"_*.profile.nc"
echo $fileNameString

echo "ssh $REMOTE_USER@$MACH rm $WORK_DIR/$fileNameString"
ssh $REMOTE_USER@$MACH rm $WORK_DIR/$fileNameString
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a problem removing the files: $WORK_DIR/$fileNameString"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

echo "exiting"
exit 0
