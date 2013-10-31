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
echo "----------------------------"
echo "Move station files to: $metDirectory"
echo "------------------------"
echo ""



echo "ssh $NED_USER@$MACH mv $WORK_DIR/*.list $metDirectory"
ssh $NED_USER@$MACH mv $WORK_DIR/*.list $metDirectory
export outputCode=$?
echo "output:  $outputCode"

if [ "$outputCode" == "0" ]; then
	echo "Metdata files moved to $metDirectory"
elif [ "$outputCode" == "1" ]; then	
	echo "Metdata NOT files moved to $metDirectory"
else
	echo "Don't understand this code:  $outputCode"
	exit -1
fi

echo "ssh $NED_USER@$MACH ls $metDirectory/*list | wc -l"
numMetdataFiles=`ssh $NED_USER@$MACH ls $metDirectory/*list | wc -l`
#trim leading whitespace with echo trick:
numMetdataFiles=`echo $numMetdataFiles`
echo "num met data files: $numMetdataFiles"
echo "export numMetdataFiles=$numMetdataFiles" >> $workflowConfig
	
echo "Success. Exiting"
exit 0
