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

export metDirectory=$WORK_DIR/completed/metdata_files
export metArchive=$ARCHIVE_DIR/metdata_files
echo "----------------------------"
echo "Archive metdata files"
echo "------------------------"
echo ""

echo "ssh $NED_USER@$MACH ls $metArchive"
ssh $NED_USER@$MACH ls $metArchive
export outputCode=$?
echo "output:  $outputCode"

if [ "$outputCode" == "2" ] || [ "$outputCode" == "1" ]; then
	echo "Making $metArchive"
	echo "ssh $NED_USER@$MACH mkdir $metArchive"
	ssh $NED_USER@$MACH mkdir $metArchive

	echo "Moving metdata to: $metArchive"
	echo "ssh $NED_USER@$MACH mv $metDirectory/*.list $metArchive"
	ssh $NED_USER@$MACH mv $metDirectory/*.list $metArchive
	
elif [ "$outputCode" == "0" ]; then	
	echo "Moving metdata to: $metArchive"
	echo "ssh $NED_USER@$MACH mv $metDirectory/*.list $metArchive"
	ssh $NED_USER@$MACH mv $metDirectory/*.list $metArchive
else
	echo "Don't understand this code:  $outputCode"
	exit -1
fi


echo "Success. Exiting"
exit 0
