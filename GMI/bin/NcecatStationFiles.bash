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

fileName="gmic_"$EXP_NAME"_"$currentYear"_"$currentMonth".profile.nc"

ssh $NED_USER@$MACH <<EOF
	cd $STN_WORK_DIR
	pwd
	ncecat `cat ${currentMonth}StationNames.list` $fileName
	ncrename -d record,station_dim $fileName
#   cp ${currentMonth}StationNames.list $fileName
	exit
EOF
echo "Returned from SSH"

echo "ssh $NED_USER@$MACH ls $STN_WORK_DIR/$fileName"
ssh $NED_USER@$MACH ls $STN_WORK_DIR/$fileName
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a problem creating the file: $STN_WORK_DIR/$fileName"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

# MRD: Todo - add check for file size or check header variables


echo "exiting"
exit 0
