#!/bin/bash -xv

# Get variables from env files
. $NED_WORKING_DIR/.exp_env.bash

# Now add other variables to the file
export ENV_FILE="$NED_WORKING_DIR/.$MACH"_env.bash
. $ENV_FILE

echo "export NED_WORKING_DIR=$NED_WORKING_DIR" >> $NED_WORKING_DIR/.exp_env.bash
echo "export NED_USER=$NED_USER" >> $NED_WORKING_DIR/.exp_env.bash
echo "export NED_REAL_USER=$NED_REAL_USER" >> $NED_WORKING_DIR/.exp_env.bash
echo "export NED_UNIQUE_ID=$NED_UNIQUE_ID" >> $NED_WORKING_DIR/.exp_env.bash
. $ENV_FILE

# check to see if the top level experiment directory exists
echo "Checking if top level experiment directory exists..."  >> $NED_WORKING_DIR/main.log
echo "ls $NED_WORKING_DIR/$NED_UNIQUE_ID"  >> $NED_WORKING_DIR/main.log

ls $NED_WORKING_DIR/$NED_UNIQUE_ID
if [ "$?" != "0" ]; then
   # rename the top level experiment directory
    echo "mv $NED_WORKING_DIR/GMI/ $NED_WORKING_DIR/$NED_UNIQUE_ID" >> $NED_WORKING_DIR/main.log
    mv $NED_WORKING_DIR/GMI/ $NED_WORKING_DIR/$NED_UNIQUE_ID >> $NED_WORKING_DIR/main.log

else
    echo "mv $NED_WORKING_DIR/GMI/* $NED_WORKING_DIR/$NED_UNIQUE_ID/" >> $NED_WORKING_DIR/main.log
    mv $NED_WORKING_DIR/GMI/* $NED_WORKING_DIR/$NED_UNIQUE_ID/ >> $NED_WORKING_DIR/main.log
fi

# setup group_list variable
echo "$NED_WORKING_DIR/$NED_UNIQUE_ID/bin/util/./SetupGroupList.py -f $NED_WORKING_DIR/workflowMetadata.xml -s entry -n GROUP_CODE -w $NED_WORKING_DIR/.exp_env.bash"
 $NED_WORKING_DIR/$NED_UNIQUE_ID/bin/util/./SetupGroupList.py -f $NED_WORKING_DIR/workflowMetadata.xml -s entry -n GROUP_CODE -w $NED_WORKING_DIR/.exp_env.bash
echo $?

# Machine dependent ENV file
echo "#ENV file for selected system" >> $NED_WORKING_DIR/.exp_env.bash
echo "export ENV_FILE=$ENV_FILE" >> $NED_WORKING_DIR/.exp_env.bash

# Installation directories for pre-built executables
if [ "$COMPILE" = "F" ]; then

    if [ "$TRUNK" = "T" ]; then
	echo "#Trunk selected" >> $NED_WORKING_DIR/.exp_env.bash
	echo "export INSTALL_GMI=$INSTALL_DIR/latest" >> $NED_WORKING_DIR/.exp_env.bash
	echo "export WORK_DIR=$WORK_DIR/" >> $NED_WORKING_DIR/.exp_env.bash
    else
	echo "#Tag to be used: $TAG" >> $NED_WORKING_DIR/.exp_env.bash
	echo "export INSTALL_GMI=$INSTALL_DIR/$TAG" >> $NED_WORKING_DIR/.exp_env.bash
	echo "export WORK_DIR=$WORK_DIR/$TAG" >> $NED_WORKING_DIR/.exp_env.bash
    fi

fi

# Add local workflow bin files to the PATH
echo "export PATH=$PATH:$NED_WORKING_DIR/$NED_UNIQUE_ID/bin" >> $NED_WORKING_DIR/.exp_env.bash

# Visualization directory
echo "export VIS_DIR=$WORK_DIR/completed" >> $NED_WORKING_DIR/.exp_env.bash
echo "export VIS_SYS=$MACH" >> $NED_WORKING_DIR/.exp_env.bash

# Get variables from env files
. $NED_WORKING_DIR/.exp_env.bash

echo "------------------------"
echo "NED_USER: $NED_USER"
echo "NED_WORKING_DIR: $NED_WORKING_DIR"
echo "------------------------"
echo ""

echo "--------------------------------------"
echo "ENV_FILE: $ENV_FILE"
echo "--------------------------------------"
echo ""

. $ENV_FILE

# Create the remote working directory
systemCommand="ssh $NED_USER@$MACH $MKDIR -p $WORK_DIR"
echo $systemCommand
$systemCommand


