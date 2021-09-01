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

export NC_HEADER_DATA="-v col_latitude,col_longitude,am,bm,ai,bi,surf_pres,${TEMPERATURE_VAR},humidity,const,const_surf"
#export NC_HEADER_DATA="-v col_latitude,col_longitude,am,bm,ai,bi,surf_pres,kel,humidity,const,const_surf"

fileName="gmic_"$EXP_NAME"_"$currentYear"_"$currentMonth".profile.nc"
fileName2="gmic_"$EXP_NAME"_"$currentYear"_"$currentMonth".profile2.nc"
ssh $REMOTE_USER@$MACH <<EOF
	cd $WORK_DIR
	pwd
	ncks $NC_HEADER_DATA $fileName $fileName2
	exit
EOF
echo "Returned from SSH"


export NC_HEADER_DATA=" -v station_labels,station_dim"
ssh $REMOTE_USER@$MACH <<EOF
	cd $WORK_DIR
	pwd
	ncks $NC_HEADER_DATA labels.nc --append $fileName2
	exit
EOF
echo "Returned from SSH"

export NC_HEADER_DATA="-v hdf_dim,hdr,species_dim,const_labels,pressure"
ssh $REMOTE_USER@$MACH <<EOF
	cd $WORK_DIR
	pwd
	ncks $NC_HEADER_DATA ${currentMonth}.const.nc --append $fileName2
	exit
EOF
echo "Returned from SSH"


echo "ssh $REMOTE_USER@$MACH ls $WORK_DIR/$fileName2"
ssh $REMOTE_USER@$MACH ls $WORK_DIR/$fileName2
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a problem creating the file: $WORK_DIR/$fileName2"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

echo "ssh $REMOTE_USER@$MACH mv $WORK_DIR/$fileName2 $WORK_DIR/$fileName"
ssh $REMOTE_USER@$MACH mv $WORK_DIR/$fileName2 $WORK_DIR/$fileName
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a problem moving the file: $WORK_DIR/$fileName2"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

echo "ssh $REMOTE_USER@$MACH rm $WORK_DIR/$currentMonth.const.nc"
ssh $REMOTE_USER@$MACH rm $WORK_DIR/$currentMonth.const.nc
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a problem removing the file: $WORK_DIR/$currentMonth.const.nc"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

# MRD: Todo - add check for file size or check header variables

echo "exiting"
exit 0
