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



fileNameString="gmic_"$EXP_NAME"_"$currentYear"_"$currentMonth"_*.profile.nc"
echo "----------------------------"
echo "Archiving separate station data for $currentMonth"
echo "------------------------"
echo ""

echo "ssh $REMOTE_USER@$MACH mkdir -p $ARCHIVE_DIR/$currentYear/stations/separateFiles"
ssh $REMOTE_USER@$MACH mkdir -p $ARCHIVE_DIR/$currentYear/stations/separateFiles
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a problem creating the directory: $ARCHIVE_DIR/$currentYear/stations/separateFiles"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

echo "ssh $REMOTE_USER@$MACH mv $ARCHIVE_DIR/$currentYear/stations/*$EXP_NAME*$currentYear*$currentMonth*profile.nc $ARCHIVE_DIR/$currentYear/stations/separateFiles/"
ssh $REMOTE_USER@$MACH mv $ARCHIVE_DIR/$currentYear/stations/*$EXP_NAME*$currentYear*$currentMonth*profile.nc $ARCHIVE_DIR/$currentYear/stations/separateFiles/
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a moving the data to: $ARCHIVE_DIR/$currentYear/stations/separateFiles"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

echo "exiting"
exit 0
