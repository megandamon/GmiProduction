#!/bin/bash -xv


. $NED_WORKING_DIR/.exp_env.bash
. $ENV_FILE

echo "------------------------"
echo "NED_USER: $NED_USER"
echo "NED_WORKING_DIR: $NED_WORKING_DIR"
echo "------------------------"
echo ""

echo "----------------------------"
echo "Installing the restart file"
$SSH_PATH $REMOTE_USER@$MACH $CP $RESTART_FILE $WORK_DIR
if [ "$?" != "0" ]; then
   echo "Could not copy the restart file: $RESTART_FILE"
   echo "----------------------------"
   echo ""
   exit -1
fi



echo "----------------------------"


exit 0
