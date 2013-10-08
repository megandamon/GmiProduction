#!/bin/bash

. $NED_WORKING_DIR/.exp_env.bash
. $ENV_FILE

echo "------------------------"
echo "NED_USER: $NED_USER"
echo "NED_WORKING_DIR: $NED_WORKING_DIR"
echo "------------------------"
echo ""


echo "------------------------"
echo "Copying the env GMI files: "
echo ".loadGMI"
echo ".cshrc.gmi"
echo ".login.gmi"

if [ "$MPI_TYPE" == "intel" ]; then
    gmiEnvFile="$NED_WORKING_DIR/.loadGMI-$MACH-intel"
    runRefFile="$NED_WORKING_DIR/run_ref_intel_$MACH"
elif [ "$MPI_TYPE" == "scali" ]; then
    gmiEnvFile="$NED_WORKING_DIR/.loadGMI-$MACH-scali"
    runRefFile="$NED_WORKING_DIR/run_ref_scali_$MACH"
else
    echo "The MPI type: ", $MPI_TYPE, " is not supported"
    echo "----------------------------"
    exit -1
fi

echo "MPI_TYPE: ", $MPI_TYPE
echo "gmiEnvFile: ", $gmiEnvFile

echo "$SCP_PATH $gmiEnvFile $NED_USER@$MACH:$WORK_DIR"
echo "ready..."
$SCP_PATH $gmiEnvFile $NED_USER@$MACH:$WORK_DIR
if [ "$?" != "0" ]; then
     echo "The .loadGMI file was not installed on $MACH" 
     echo "----------------------------"
     echo ""
     exit -1
fi

echo "After SCP"
 
echo "#Path on remote system to the GMI env file" >> $NED_WORKING_DIR/.exp_env.bash
echo "export GMI_ENV=$WORK_DIR/.loadGMI-$MACH-$MPI_TYPE" >>  $NED_WORKING_DIR/.exp_env.bash 
echo "#Run reference file" >>  $NED_WORKING_DIR/.exp_env.bash
echo "export RUN_REF=$NED_WORKING_DIR/run_ref_${MPI_TYPE}_${MACH}" >> $NED_WORKING_DIR/.exp_env.bash

echo "$SCP_PATH $NED_WORKING_DIR/.cshrc.gmi-$MACH $NED_USER@$MACH:"
$SCP_PATH $NED_WORKING_DIR/.cshrc.gmi-$MACH $NED_USER@$MACH:
echo "after .cshrc scp"
if [ "$?" != "0" ]; then
     echo "The .cshrc.gmi file was not installed on $MACH" 
     echo "----------------------------"
     echo ""
     exit -1
fi

echo "$SCP_PATH $NED_WORKING_DIR/.login.gmi-$MACH $NED_USER@$MACH:"
$SCP_PATH $NED_WORKING_DIR/.login.gmi-$MACH $NED_USER@$MACH:
echo "after login scp"
if [ "$?" != "0" ]; then
     echo "The .login.gmi file was not installed on $MACH" 
     echo "----------------------------"
     echo ""
     exit -1
fi

echo "$SSH_PATH $NED_USER@$MACH chmod 755 .*.gmi* $WORK_DIR/.loadGMI*"
$SSH_PATH $NED_USER@$MACH chmod 755 .*.gmi* $WORK_DIR/.loadGMI* 
#if [ "$?" != "0" ]; then
    #     echo "There was a problem setting the permissions on the env files on $MACH"
    # echo "----------------------------"
    # echo ""
    # exit -1
#fi

echo "" 
echo "Files installed successfully"
echo "----------------------------"
exit 0
 

