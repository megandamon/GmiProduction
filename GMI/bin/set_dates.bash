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

# Since the monitoring task doesn't really care about START_DATE
# We need to let it know what the current end date is 
# which may or may not be the actual end date
