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

. $NED_WORKING_DIR/$NED_UNIQUE_ID/bin/ReturnMonth.bash
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

echo "ssh $NED_USER@$MACH rm $STN_WORK_DIR/$fileNameString"
ssh $NED_USER@$MACH rm $STN_WORK_DIR/$fileNameString
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a problem removing the files: $STN_WORK_DIR/$fileNameString"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

echo "exiting"
exit 0
