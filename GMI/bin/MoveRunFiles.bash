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

export runDirectory=$WORK_DIR/completed/$YEAR/run_info
echo "----------------------------"
echo "Move run files to: $runDirectory"
echo "------------------------"
echo ""

# Switched from "mv" to "find -exec mv" to avoid [Argument list too long] error on OS X
echo "ssh $NED_USER@$MACH find $WORK_DIR -maxdepth 1 -type f -name \"*\" -exec mv {} $runDirectory \;"
#ssh $NED_USER@$MACH mv $WORK_DIR/* $runDirectory
ssh $NED_USER@$MACH "find $WORK_DIR -maxdepth 1 -type f -name \"*\" -exec mv {} $runDirectory \;"
export outputCode=$?
echo "output:  $outputCode"


if [ "$outputCode" == "0" ]; then
	echo "Odd return code! Check that the run files moved to $runDirectory"
elif [ "$outputCode" == "1" ]; then	
	echo "Normal return code. Run files should have moved to $runDirectory"
else
	echo "Don't understand this code:  $outputCode"
	exit -1
fi

echo "ssh $NED_USER@$MACH ls $runDirectory/* | wc -l"
numRunFiles=`ssh $NED_USER@$MACH ls $runDirectory/* | wc -l`
#trim leading whitespace with echo trick:
numRunFiles=`echo $numRunFiles`
echo "num run files: $numRunFiles"
echo "export numRunFiles=$numRunFiles" >> $workflowConfig
	
echo "Success. Exiting"
exit 0
