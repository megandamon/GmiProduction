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

export currentYear=${CURRENT_DATE:0:4}
export numMonth=${CURRENT_DATE:4:2}
export currentMonth='xxx'
returnMonth $numMonth $currentMonth

if [ "$currentMonth" = "xxx" ]; then
    echo "Month not recognized"
    exit -1
fi

echo "MPI_TYPE: $MPI_TYPE"
if [ "$MPI_TYPE" == "intel" ]; then
    export scali="false"
elif [ "$MPI_TYPE" == "scali" ]; then
    export scali="true"
else
    echo "The MPI type: ", $MPI_TYPE, " is not supported"
    echo "----------------------------"
    exit -1
fi

#if [ "$CURRENT_DATE" == "$START_DATE" ] || [ "$currentMonth" == "jan" ]; then
if [ "$CURRENT_DATE" == "$START_DATE" ]; then
   echo "current date is start date"
   echo "export jobID=0000" >> $NED_WORKING_DIR/.exp_env.bash
   . $NED_WORKING_DIR/.exp_env.bash
fi
   

echo "export scali=$scali" >> $NED_WORKING_DIR/.exp_env.bash
echo "scali: ", $scali

export NAMELIST_FILE="gmic_$EXP_NAME""_$currentYear""_$currentMonth"".in"

echo "NUM_PROCS: $NUM_PROCS"
echo "NAMELIST_FILE: $NAMELIST_FILE"
echo "WORK_DIR: $WORK_DIR"
echo "CHEMICAL: $CHEMISTRY"
echo "INCLUDE_NL_MPIRUN: $INCLUDE_NL_MPIRUN"
echo "RUN_REF: $RUN_REF"

echo "$NED_WORKING_DIR/$NED_UNIQUE_ID/bin/util/./MakeQueueScript.py -f $RUN_REF -n $NUM_PROCS -e $NUM_PROCS_PER_NODE -m $NAMELIST_FILE -p $WORK_DIR -c $GROUP_LIST -a $CHEMISTRY -d $NED_WORKING_DIR -w $WALL_TIME -s $scali -u false -i $INCLUDE_NL_MPIRUN -o $jobID -q $QUEUE" 
$NED_WORKING_DIR/$NED_UNIQUE_ID/bin/util/./MakeQueueScript.py -f $RUN_REF -n $NUM_PROCS -e $NUM_PROCS_PER_NODE -m $NAMELIST_FILE -p $WORK_DIR -c $GROUP_LIST -a $CHEMISTRY -d $NED_WORKING_DIR -w $WALL_TIME -s $scali -u false -i $INCLUDE_NL_MPIRUN -o $jobID -q $QUEUE

export QUEUE_FILE="gmic_$EXP_NAME""_$currentYear""_$currentMonth"".qsub"

$SCP_PATH $NED_WORKING_DIR/$QUEUE_FILE $REMOTE_USER@$MACH:$WORK_DIR
if [ "$?" != "0" ]; then
    echo "There was a problem updating the the queue file: $QUEUE_FILE"
    echo "------------------------"
    exit -1
fi

# get the accounting file name
. $NED_WORKING_DIR/.accounting_path
echo "accountingFile = $accountingFile"
echo "NED_REAL_USER = $NED_REAL_USER"

if [ "$NED_REAL_USER" == "" ]; then
   export NED_REAL_USER=$REMOTE_USER
fi

# call the script to submit the job, record the accounting information and append jobID to the env file
echo "$NED_WORKING_DIR/$NED_UNIQUE_ID/bin/util/./SubmitPbsJobAndRecord.py -f $WORK_DIR/$QUEUE_FILE -q $QSUB -a $accountingFile -n $REMOTE_USER -r $NED_REAL_USER -w $NED_WORKING_DIR/.exp_env.bash  -s $MACH -d $WORK_DIR"
$NED_WORKING_DIR/$NED_UNIQUE_ID/bin/util/./SubmitPbsJobAndRecord.py -f $WORK_DIR/$QUEUE_FILE -q $QSUB -a $accountingFile -n $REMOTE_USER -r $NED_REAL_USER -w $NED_WORKING_DIR/.exp_env.bash  -s $MACH -d $WORK_DIR

echo $?

. $NED_WORKING_DIR/.exp_env.bash

if [ "$jobID" == "" ]; then
    echo "There was a queue submission problem"
    exit -1
fi

echo "jobID: ", $jobID
echo "export $currentMonth$currentYear"JobID"=$jobID" >> $NED_WORKING_DIR/.exp_env.bash

echo "YEAR: ", $currentYear
echo "export YEAR=$currentYear" >> $NED_WORKING_DIR/.exp_env.bash
