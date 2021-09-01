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

ssh $REMOTE_USER@$MACH <<EOF
	cd $WORK_DIR
	pwd
	ncecat `cat ${currentMonth}StationNames.list` $fileName
	ncrename -d record,station_dim $fileName
	exit
EOF
echo "Returned from SSH"

echo "ssh $REMOTE_USER@$MACH ls $WORK_DIR/$fileName"
ssh $REMOTE_USER@$MACH ls $WORK_DIR/$fileName
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a problem creating the file: $WORK_DIR/$fileName"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

# MRD: Todo - add check for file size or check header variables


echo "exiting"
exit 0
