#!/bin/bash -xv


. $NED_WORKING_DIR/.exp_env.bash
. $ENV_FILE

echo "------------------------"
echo "NED_USER: $NED_USER"
echo "NED_WORKING_DIR: $NED_WORKING_DIR"
echo "------------------------"
echo ""

echo "------------------------"

echo ""

echo "Removing the workflow directory: $WORK_DIR on $MACH"
echo "$SSH_PATH $NED_USER@$MACH rm -rf $WORK_DIR"
$SSH_PATH $NED_USER@$MACH rm -rf $WORK_DIR
if [ "$?" != "0" ]; then
   echo "Could not remove the directory $WORK_DIR on $MACH" 
   echo "----------------------------"
   echo ""
   exit -1
fi

echo "----------------------------"

exit 0
