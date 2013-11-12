#!/bin/bash

#export workflowConfig=$NED_WORKING_DIR/WorkflowConfigs.bash
export workflowConfig=$NED_WORKING_DIR/.exp_env.bash
echo $workflowConfig
. $workflowConfig

# Need to get $colDiagStationsNames array from WorkflowConfigs.bash file
. $NED_WORKING_DIR/WorkflowConfigs.bash
# Now split the single comma-separated string into an array
IFS=', ' read -a colDiagStationsNames <<< "$colDiagStationsNames"

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

export NC_HEADER_DATA="-v hdf_dim,hdr,species_dim,const_labels,pressure"
export firstStation=${colDiagStationsNames[0]}
fileName="gmic_"$EXP_NAME"_"$currentYear"_"$currentMonth"_"$firstStation".profile.nc"


ssh $NED_USER@$MACH <<EOF
	cd $STN_WORK_DIR
	pwd
	ncks $NC_HEADER_DATA $fileName ${currentMonth}.const.nc
#   touch ${currentMonth}.const.nc
	ls ${currentMonth}.const.nc
	exit
EOF
echo "Returned from SSH"


echo "ssh $NED_USER@$MACH ls $STN_WORK_DIR/${currentMonth}.const.nc"
ssh $NED_USER@$MACH ls $STN_WORK_DIR/${currentMonth}.const.nc
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a problem creating the file: $STN_WORK_DIR/${currentMonth}.const.nc"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

# MRD: Todo - add check for file size or check header variables

echo "exiting"
exit 0
