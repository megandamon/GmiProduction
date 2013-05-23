#!/bin/bash


echo ". $NED_WORKING_DIR/.exp_env.bash"
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


export QUEUE_FILE="gmi*_$EXP_NAME""_$currentYear""_$currentMonth"".qsub"

# get the accounting file name
. $NED_WORKING_DIR/.accounting_path
echo "accountingFile = $accountingFile"
echo "NED_REAL_USER = $NED_REAL_USER"

if [ "$NED_REAL_USER" == "" ]; then
   export NED_REAL_USER=$NED_USER
fi 

# call the script to submit the job, record the accounting information and append jobID to the env file
echo "$NED_WORKING_DIR/$NED_UNIQUE_ID/bin/util/./SubmitPbsJobAndRecord.py -f $WORK_DIR/$QUEUE_FILE -q $QSUB -a $accountingFile -n $NED_USER -r $NED_REAL_USER -w $NED_WORKING_DIR/.exp_env.bash  -s $MACH -d $WORK_DIR "
$NED_WORKING_DIR/$NED_UNIQUE_ID/bin/util/./SubmitPbsJobAndRecord.py -f $WORK_DIR/$QUEUE_FILE -q $QSUB -a $accountingFile -n $NED_USER -r $NED_REAL_USER -w $NED_WORKING_DIR/.exp_env.bash  -s $MACH -d $WORK_DIR 

echo $?


. $NED_WORKING_DIR/.exp_env.bash

if [ "$jobID" == "" ]; then
    echo "There was a queue submission problem"
    exit -1
fi


#longId=`$SSH_PATH $NED_USER@$MACH $QSUB $WORK_DIR/$QUEUE_FILE`
#idLength=${#longId}
#echo "longId: $longId"
#echo "idLength: $idLength"
#if [ $idLength -eq 0 ]; then
#    echo "Bad id length: $idLength"
#    exit -1
#fi

echo "The $currentMonth $currentYear job id is: $jobID"

#--------------------------------------------------------------------------
# Watch the status of the, but be careful not to exit prematurely
#---------------------------------------------------------------------------
status = ""
let numberOfEmpty=0
export jobId=$jobID
echo "--------------------------------------------------------------------"

let maxSeconds=432000
let numSeconds=0
let sleepTime=45

echo -e "\nmaxSeconds: $maxSeconds"
echo "numSeconds: $numSeconds"
while [ $numSeconds -lt $maxSeconds ]; do

   echo -e "\nssh $NED_USER@$MACH $QSTAT | grep ${jobId}"
   status=`ssh $NED_USER@$MACH $QSTAT | grep ${jobId} | awk '{print $5}'`
   echo $status

   echo -e "\nsleep $sleepTime"
   sleep $sleepTime

   let numSeconds=numSeconds+sleepTime
   echo -e "\nseconds so far: $numSeconds"

   if [ "$status" = "R" ]; then
       echo -e "\nscp $NED_USER@$MACH:$WORK_DIR/stdout.log $NED_WORKING_DIR/$NED_UNIQUE_ID/log"
       scp $NED_USER@$MACH:$WORK_DIR/stdout.log $NED_WORKING_DIR/$NED_UNIQUE_ID/log
       tail -n 50 $NED_WORKING_DIR/$NED_UNIQUE_ID/log/stdout.log
   fi

   #--------------------------------------------------------------------------
   # the job may be done; needs further investigating
   #---------------------------------------------------------------------------
   if [ "$status"  = "" ]; then

    counter=0
    numberOfEmpty=0

    #---------------------------------------------------------------------------
    # keeps checking the batch system in case of a false negative
    #--------------------------------------------------------------------------
    while [ $counter -lt 5 ]; do

       sleep 30

       echo -e "\nssh $NED_USER@$MACH $QSTAT | grep ${jobId}"
       status=`ssh $NED_USER@$MACH $QSTAT | grep ${jobId}`

       if [ "$status"  = "" ]; then
          let numberOfEmpty=numberOfEmpty+1
          echo "Job status is empty ($numberOfEmpty)"
       fi

       let counter=counter+1

    done

    #---------------------------------------------------------------------------
    # exit when satified that the job has finished
    #--------------------------------------------------------------------------
    if [ $numberOfEmpty -gt 4 ]; then
        echo -e "\nThe empty job status has been satisfied"
        break
    fi

  fi

done


sleep 60

#---------------------------------------------------------------------------
# check standard output/error file
#--------------------------------------------------------------------------
export standardOutFile="gmi*$jobId"

successKeyWord="Successful completion of the run"
keyWordLength=${#successKeyWord}
if [ $numberOfEmpty -gt 4 ] && [ "$status" = "" ]; then

    echo "Attempting to get standard out/error file"
    echo "$SSH_PATH $NED_USER@$MACH mv -f $standardOutFile $WORK_DIR"
    $SSH_PATH $NED_USER@$MACH mv -f $standardOutFile $WORK_DIR
    echo "$SSH_PATH $NED_USER@$MACH tail -n 100 $WORK_DIR/$standardOutFile | grep \"${successKeyWord}\""
    outputCheck=`$SSH_PATH $NED_USER@$MACH tail -n 100 $WORK_DIR/$standardOutFile | grep "${successKeyWord}"`

    if [ "$?" != "0" ]; then
	echo "ERROR: Output check did not pass"
        echo "RETURNED: $outputCheck"
	exit -1
    else
	echo "$CURRENT_DATE completed successfully in GMI workflow" 
    fi

fi

echo "GMI $EXP_NAME $currentYear $currentMonth segment appears to have finished successfully"
echo "---------------------------------------------------------------------"	
exit 0
