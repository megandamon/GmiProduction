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

export NC_HEADER_DATA="-v col_latitude,col_longitude,am,bm,ai,bi,surf_pres,pot_temp,humidity,const,const_surf"
fileName="gmic_"$EXP_NAME"_"$currentYear"_"$currentMonth".profile.nc"
fileName2="gmic_"$EXP_NAME"_"$currentYear"_"$currentMonth".profile2.nc"
ssh $NED_USER@$MACH <<EOF
	cd $STN_WORK_DIR
	pwd
	ncks $NC_HEADER_DATA $fileName $fileName2
#   cp $fileName $fileName2
	exit
EOF
echo "Returned from SSH"


export NC_HEADER_DATA=" -v station_labels,station_dim"
ssh $NED_USER@$MACH <<EOF
	cd $STN_WORK_DIR
	pwd
	ncks $NC_HEADER_DATA labels.nc --append $fileName2
#   echo "fake: $NC_HEADER_DATA labels.nc --append $fileName2"
	exit
EOF
echo "Returned from SSH"

export NC_HEADER_DATA="-v hdf_dim,hdr,species_dim,const_labels,pressure"
ssh $NED_USER@$MACH <<EOF
	cd $STN_WORK_DIR
	pwd
	ncks $NC_HEADER_DATA ${currentMonth}.const.nc --append $fileName2
#   echo "fake: $NC_HEADER_DATA ${currentMonth}.const.nc --append $fileName2"
   exit
EOF
echo "Returned from SSH"


echo "ssh $NED_USER@$MACH ls $STN_WORK_DIR/$fileName2"
ssh $NED_USER@$MACH ls $STN_WORK_DIR/$fileName2
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a problem creating the file: $STN_WORK_DIR/$fileName2"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

echo "ssh $NED_USER@$MACH mv $STN_WORK_DIR/$fileName2 $STN_WORK_DIR/$fileName"
ssh $NED_USER@$MACH mv $STN_WORK_DIR/$fileName2 $STN_WORK_DIR/$fileName
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a problem moving the file: $STN_WORK_DIR/$fileName2"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

echo "ssh $NED_USER@$MACH rm $STN_WORK_DIR/$currentMonth.const.nc"
ssh $NED_USER@$MACH rm $STN_WORK_DIR/$currentMonth.const.nc
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a problem removing the file: $STN_WORK_DIR/$currentMonth.const.nc"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

# MRD: Todo - add check for file size or check header variables

echo "exiting"
exit 0
