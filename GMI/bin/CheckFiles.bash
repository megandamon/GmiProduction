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

export archiveDirectory=$ARCHIVE_DIR/$YEAR
echo "----------------------------"
echo "Checking files in : $archiveDirectory"
echo "------------------------"
echo ""

export diagDirectory=$archiveDirectory/diagnostics
export stationDirectory=$archiveDirectory/stations


echo "ssh $NED_USER@$MACH ls $diagDirectory/*$YEAR*nc | wc -l"
#numArchiveDiagFiles=`ssh $NED_USER@$MACH ls $diagDirectory/*$YEAR*nc`
numArchiveDiagFiles=`ssh $NED_USER@$MACH find $diagDirectory -type f -print0 | tr -dc '\0' | wc -c`
echo $numArchiveDiagFiles
echo "check with: $numDiagFiles"

echo "ssh $NED_USER@$MACH ls $stationDirectory/*$YEAR*nc | wc -l"
#numArchiveStationFiles=`ssh $NED_USER@$MACH ls $stationDirectory/*$YEAR*nc`
numArchiveStationFiles=`ssh $NED_USER@$MACH find $stationDirectory -type f -print0 | tr -dc '\0' | wc -c`
echo $numArchiveStationFiles
echo "check with: $numStationFiles"

echo "ssh $NED_USER@$MACH ls $archiveDirectory/*$YEAR*nc | wc -l"
numArchiveDirectoryFiles=`ssh $NED_USER@$MACH ls $archiveDirectory/*$YEAR*nc | wc -l`
echo $numArchiveDirectoryFiles
echo "check with: $numNetcdfFiles"
 
echo "Success. Exiting"
exit 0
