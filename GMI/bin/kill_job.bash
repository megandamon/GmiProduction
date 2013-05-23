#!/bin/bash -xv

echo "--------------------------------------"
echo "NED_USER: $NED_USER"
echo "NED_WORKING_DIR: $NED_WORKING_DIR"
echo "--------------------------------------"
echo ""

# Get variables from env files 
. $NED_WORKING_DIR/.exp_env.bash
export ENV_FILE=$NED_WORKING_DIR"."$MACH"_env.bash"
. $ENV_FILE

echo "--------------------------------------"
echo "ENV_FILE: $ENV_FILE"
echo "--------------------------------------"
echo ""

MODEL_LOG_DIR=$EXP_DIR/log
echo "--------------------------------------"
echo "MODEL LOG FILE: $MODEL_LOG_DIR/$EXP_ID.log"
echo "--------------------------------------"
echo ""

if [ "$jobID" = "" ]; then
    echo "There are no active jobs to kill!"
    exit -1
fi

echo "Attempting to kill the job id: $jobID"

echo "ssh $NED_USER@$MACH $QDEL $jobID" 
ssh $NED_USER@$MACH $QDEL $jobID
if [ "$?" != "0" ]; then
    echo "Could not kill the job id: $jobID"
    exit -1
else
    echo "Successfully killed the job: $jobID"
fi
