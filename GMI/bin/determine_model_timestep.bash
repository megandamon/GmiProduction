#!/bin/bash


. $NED_WORKING_DIR/.exp_env.bash
. $ENV_FILE

echo "------------------------"
echo "NED_USER: $NED_USER"
echo "NED_WORKING_DIR: $NED_WORKING_DIR"
echo "------------------------"

# call the script to look at the job's stdout
echo "About to call python..."

python -u $NED_WORKING_DIR/$NED_UNIQUE_ID/bin/util/DetermineModelTimeStep.py -f $WORK_DIR/stdout.log -e $NED_WORKING_DIR/.exp_env.bash
returnCode=$?

echo "Back in bash, return code is: ", $returnCode

if [ $returnCode == 1 ]; then
	echo "Creating stop file"
	touch STOP
fi


echo "Exiting determine_model_timestep.bash"