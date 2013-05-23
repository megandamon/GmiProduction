#!/bin/bash

echo "Monitoring GMI segments"

echo ". $NED_WORKING_DIR/.exp_env.bash"
. $NED_WORKING_DIR/.exp_env.bash
. $ENV_FILE
. $NED_WORKING_DIR/$NED_UNIQUE_ID/bin/ReturnMonth.bash


if [ "$CURRENT_DATE" == "" ]; then
   echo "First month in experiment is: $CURRENT_DATE"
   export CURRENT_DATE=$START_DATE
else 
   CURRENT_DATE=`$NED_WORKING_DIR/$NED_UNIQUE_ID/bin/util/IncrementMonth.py -d $CURRENT_DATE` 
fi

echo "export CURRENT_DATE=$CURRENT_DATE" >> $NED_WORKING_DIR/.exp_env.bash
echo "Current date: ", $CURRENT_DATE

export currentYear=${CURRENT_DATE:0:4}
export numMonth=${CURRENT_DATE:4:2}
export currentMonth='xxx'
returnMonth $numMonth $currentMonth
if [ "$currentMonth" = "xxx" ]; then
    echo "Month not recognized"
    exit -1
fi


jobIdVarName=$currentMonth$currentYear"JobID"
jobId=${!jobIdVarName}
if [ "$jobId" == "" ]; then
    echo "ERROR: The $currentMonth job submission failed"
    exit -1
fi

echo "The $currentMonth $currentYear job id is: $jobId"

#--------------------------------------------------------------------------
# Watch the status of the, but be careful not to exit prematurely
#---------------------------------------------------------------------------
export status=""
let numberOfEmpty=0
export jobId=$jobId

let maxSeconds=432000
let numSeconds=0
let sleepTime=45

echo -e "\nmaxSeconds: $maxSeconds"
echo "numSeconds: $numSeconds"
while [ $numSeconds -lt $maxSeconds ]; do

   echo -e "\nssh $NED_USER@$MACH $QSTAT | grep ${jobId}"
   export status=`ssh $NED_USER@$MACH $QSTAT | grep ${jobId} | awk '{print $5}'`
   echo "Status is: $status"

   echo -e "\Sleeping for $sleepTime seconds"
   sleep $sleepTime

   let numSeconds=numSeconds+sleepTime
   echo -e "\nseconds so far: $numSeconds"

   if [ "$status" = "R" ]; then
       echo -e "\nscp $NED_USER@$MACH:$WORK_DIR/stdout.log $NED_WORKING_DIR/$NED_UNIQUE_ID/log"
       scp $NED_USER@$MACH:$WORK_DIR/stdout.log $NED_WORKING_DIR/$NED_UNIQUE_ID/log
       echo -e "\nchmod 755 $NED_WORKING_DIR/$NED_UNIQUE_ID/log/stdout.log; tail -n 50 $NED_WORKING_DIR/$NED_UNIQUE_ID/log/stdout.log"
       export latestOutput=`chmod 755 $NED_WORKING_DIR/$NED_UNIQUE_ID/log/stdout.log; tail -n 50 $NED_WORKING_DIR/$NED_UNIQUE_ID/log/stdout.log`
       echo -e "Latest output: ", $latestOutput
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
export standardOutFile="gmi*.e$jobId"

successKeyWord="Successful completion of the run"
keyWordLength=${#successKeyWord}
if [ $numberOfEmpty -gt 4 ] && [ "$status" = "" ]; then

    echo "Attempting to get standard out/error file"
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

