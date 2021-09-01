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

echo "----------------------------"
echo "Create working directory: $WORK_DIR"
echo "------------------------"
echo ""

echo "ssh $REMOTE_USER@$MACH mkdir $WORK_DIR"
ssh $REMOTE_USER@$MACH mkdir $WORK_DIR
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a problem creating $WORK_DIR"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

echo "----------------------------"
echo "Uploading labels.nc"
echo "------------------------"
echo ""

echo "scp ${NED_WORKING_DIR}/labels.nc $REMOTE_USER@$MACH:$WORK_DIR"
scp ${NED_WORKING_DIR}/labels.nc $REMOTE_USER@$MACH:$WORK_DIR
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
