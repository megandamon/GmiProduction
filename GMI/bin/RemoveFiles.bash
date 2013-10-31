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

export workDirectory=$WORK_DIR/completed/$YEAR
echo "----------------------------"
echo "Checking files in : $archiveDirectory"
echo "------------------------"
echo ""

echo "ssh $NED_USER@$MACH rm -rf $workDirectory"
ssh $NED_USER@$MACH rm -rf $workDirectory
export outputCode=$?
echo "output:  $outputCode"


if [ "$outputCode" == "0" ]; then
	echo "$workDirectory removed"
else
	echo "Problem removing the directory $workDirectory"
	exit -1
fi 

echo "Success. Exiting"
exit 0
