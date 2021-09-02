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

export diagDirectory=$WORK_DIR/completed/$YEAR/diagnostics
echo "----------------------------"
echo "Move diagnostic files to: $diagDirectory"
echo "------------------------"
echo ""


for fileType in "${DIAG_NAMES[@]}"
do
	export fileString="*$EXP_NAME*$fileType*nc"
	echo "ssh $NED_USER@$MACH mv $WORK_DIR/$fileString $diagDirectory"
	ssh $NED_USER@$MACH mv $WORK_DIR/$fileString $diagDirectory
	export outputCode=$?
	if [ "$outputCode" == "0" ]; then
			echo "$fileString moved to $diagDirectory"
	elif [ "$outputCode" == "1" ]; then	
		echo "$fileString NOT moved to $diagDirectory"
	else
		echo "Don't understand this code:  $outputCode"
		exit -1
	fi	

done 

echo "ssh $NED_USER@$MACH ls $diagDirectory/*nc | wc -l"
numDiagFiles=`ssh $NED_USER@$MACH ls $diagDirectory/*nc | wc -l`
#trim leading whitespace with echo trick:
numDiagFiles=`echo $numDiagFiles`
echo "num diag files: $numDiagFiles"
echo "export numDiagFiles=$numDiagFiles" >> $workflowConfig

echo "Success. Exiting"
exit 0
