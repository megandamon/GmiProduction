#!/bin/bash


echo ". $NED_WORKING_DIR/.exp_env.bash"
. $NED_WORKING_DIR/.exp_env.bash

echo ". $ENV_FILE"
. $ENV_FILE
. $NED_WORKING_DIR/$NED_UNIQUE_ID/bin/ReturnMonth.bash

echo "------------------------"
echo "NED_USER: $NED_USER"
echo "NED_WORKING_DIR: $NED_WORKING_DIR"
echo "------------------------"
echo ""

echo "------------------------"
echo "CURRENT_DATE = $CURRENT_DATE"


export METFIELD_DIR=$GMI_DIR/input/run_info/metfile_lists/$MET_TYPE/
export currentYear=${CURRENT_DATE:0:4}
export numMonth=${CURRENT_DATE:4:2}

echo "METFIELD_DIR = $METFIELD_DIR"
echo "------------------------"

export currentMonth='xxx'
returnMonth $numMonth $currentMonth

if [ "$currentMonth" = "xxx" ]; then
    echo "Month not recognized"
    exit -1
fi


echo "------------------------"
echo "Current year: $currentYear"
echo "Current month: $currentMonth"
echo "------------------------"

echo "------------------------"

export NAMELIST_FILE="gmic_$EXP_NAME""_$currentYear""_$currentMonth"".in"
export REMOTE_HOST="$NED_USER@$MACH"


echo "NAMELIST_FILE: $NAMELIST_FILE"
echo "WORK_DIR: $WORK_DIR"
echo "REMOTE_HOST: $REMOTE_HOST"


echo "$NED_WORKING_DIR/$NED_UNIQUE_ID/bin/util/./ArchiveOutputs.py -r $REMOTE_HOST -d $CURRENT_DATE -w $WORK_DIR -n $NAMELIST_FILE -q $jobID -c $NED_WORKING_DIR -u $NED_USER"
$NED_WORKING_DIR/$NED_UNIQUE_ID/bin/util/./ArchiveOutputs.py -r $REMOTE_HOST -d $CURRENT_DATE -w $WORK_DIR -n $NAMELIST_FILE -q $jobID -c $NED_WORKING_DIR -u $NED_USER


echo $?
echo "------------------------"



exit 0
