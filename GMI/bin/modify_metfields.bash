#!/bin/bash


. $NED_WORKING_DIR/.exp_env.bash
. $ENV_FILE
. $NED_WORKING_DIR/$NED_UNIQUE_ID/bin/ReturnMonth.bash

echo "------------------------"
echo "NED_USER: $NED_USER"
echo "NED_WORKING_DIR: $NED_WORKING_DIR"
echo "------------------------"
echo ""

echo "------------------------"
echo "CURRENT_DATE = $CURRENT_DATE"


export METFIELD_DIR=$GMI_DIR/input/run_info/metfile_lists/$MET_TYPE/$RESOLUTION/
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

export METFIELD_FILE=$METFIELD_DIR/$currentMonth$currentYear".list"

$SSH_PATH $NED_USER@$MACH $CP $METFIELD_FILE $WORK_DIR
if [ "$?" != "0" ]; then
    echo "There was a problem updating the metfield file: $METFIELD_FILE"
    echo "------------------------"
    exit -1
fi

echo "------------------------"

exit 0
