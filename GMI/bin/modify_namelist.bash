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

if [ "$COMPILE" = "yes" ]; then

   echo "GMI executable selected from compilation"
   echo "This feature is currently not supported"
   echo "------------------------"
   exit -1

fi
   
echo ""
echo "Calling python script to modify current namelist"


$CHMOD_PATH 775 $NED_WORKING_DIR/base.in

if [ "$CURRENT_DATE" == "" ]; then
   export CURRENT_DATE=$START_DATE 
else 
   CURRENT_DATE=`$NED_WORKING_DIR/$NED_UNIQUE_ID/bin/util/./IncrementMonth.py -d $CURRENT_DATE` 
fi

echo "export CURRENT_DATE=$CURRENT_DATE" >> $NED_WORKING_DIR/.exp_env.bash
echo "Current date: ", $CURRENT_DATE

export replaceRestart=1
if [ "$CURRENT_DATE" == "$START_DATE" ]; then
    export replaceRestart=0
fi

echo "CHEMISTRY: ", $CHEMISTRY
echo "CURRENT_DATE: ", $CURRENT_DATE
echo "START_DATE: ", $START_DATE
if [ "$CURRENT_DATE" == "$START_DATE" ] && [ "$CHEMISTRY" == "age_of_air" ] && [ "$RESET_GMI_SEC" == "T"; then
   export gmi_sec="0" 
   echo "export gmi_sec=0" >> $NED_WORKING_DIR/.exp_env.bash
fi


echo "PATH: $PATH"
echo "replace restart  = ", $replaceRestart
echo "INCLUDE_NL_MPIRUN: ", $INCLUDE_NL_MPIRUN

export useFortranNameList="false"
if [ "$INCLUDE_NL_MPIRUN" == "T" ]; then
    export useFortranNameList="true" 
fi

echo "PATH: $PATH"
echo "replace restart  = ", $replaceRestart
echo "useFortranNameList? ", $useFortranNameList



cd $NED_WORKING_DIR/$NED_UNIQUE_ID/bin/

echo "$NED_WORKING_DIR/$NED_UNIQUE_ID/bin/util/./MakeNameLists.py -p $NED_WORKING_DIR  -n  base.in -d $CURRENT_DATE -r $replaceRestart -z \".\" -e $END_DATE -f $useFortranNameList -s $gmi_sec -v  $NED_WORKING_DIR/.exp_env.bash"
$NED_WORKING_DIR/$NED_UNIQUE_ID/bin/util/./MakeNameLists.py -p $NED_WORKING_DIR  -n  base.in -d $CURRENT_DATE -r $replaceRestart -z "." -e $END_DATE -f $useFortranNameList  -s $gmi_sec -v  $NED_WORKING_DIR/.exp_env.bash

export currentYear=${CURRENT_DATE:0:4}
export numMonth=${CURRENT_DATE:4:2}
export currentMonth='xxx'
returnMonth $numMonth $currentMonth

if [ "$currentMonth" = "xxx" ]; then
    echo "Month not recognized"
    exit -1
fi

$SCP_PATH $NED_WORKING_DIR/*$currentYear_$currentMonth.in $NED_USER@$MACH:$WORK_DIR
if [ "$?" != "0" ]; then
    echo "There was a problem updating the namelist file for $currentMonth $currentYear"
    echo "------------------------"
    exit -1
fi

echo "----------------------------"

exit 0
