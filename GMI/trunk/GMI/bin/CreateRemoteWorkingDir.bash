#!/bin/bash

#export workflowConfig=$NED_WORKING_DIR/WorkflowConfigs.bash
export workflowConfig=$NED_WORKING_DIR/.exp_env.bash
echo $workflowConfig
. $workflowConfig

echo "------------------------"
echo "NED_USER: $NED_USER"
echo "REMOTE_USER: $REMOTE_USER"
echo "NED_WORKING_DIR: $NED_WORKING_DIR"
echo "------------------------"
echo ""

echo "----------------------------"
echo "Create working directory: $STN_WORK_DIR"
echo "------------------------"
echo ""

echo "ssh $REMOTE_USER@$MACH mkdir $STN_WORK_DIR"
ssh $REMOTE_USER@$MACH mkdir $STN_WORK_DIR
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a problem creating $STN_WORK_DIR"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

echo "Resetting CURRENT DATE before Station Processing loop"
echo "export CURRENT_DATE=" >> $workflowConfig

echo "----------------------------"
echo "Uploading labels.nc"
echo "------------------------"
echo ""

echo "scp ${NED_WORKING_DIR}/labels.nc $REMOTE_USER@$MACH:$STN_WORK_DIR"
scp ${NED_WORKING_DIR}/labels.nc $REMOTE_USER@$MACH:$STN_WORK_DIR
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a problem copying labels.nc $MACH"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

echo "----------------------------"

exit 0
