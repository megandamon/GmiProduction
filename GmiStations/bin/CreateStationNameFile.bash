#!/bin/bash

export workflowConfig=$NED_WORKING_DIR/WorkflowConfigs.bash
echo $workflowConfig
. $workflowConfig

echo "------------------------"
echo "NED_USER: $NED_USER"
echo "NED_WORKING_DIR: $NED_WORKING_DIR"
echo "------------------------"
echo ""


echo "Current date: " $CURRENT_DATE

. $NED_WORKING_DIR/bin/ReturnMonth.bash
export currentYear=${CURRENT_DATE:0:4}
export numMonth=${CURRENT_DATE:4:2}
export currentMonth='xxx'
returnMonth $numMonth $currentMonth

if [ "$currentMonth" = "xxx" ]; then
        echo "Month not recognized"
    	exit -1
fi

echo "----------------------------"
echo "Creating station name file"
echo "------------------------"
echo ""

for station in "${colDiagStationsNames[@]}" 
do 
	echo "echo -n gmic_${EXP_NAME}_${currentYear}_${currentMonth}_${station}.profile.nc" " >> ${NED_WORKING_DIR}/${currentMonth}StationNames.list"
	echo -n gmic_${EXP_NAME}_${currentYear}_${currentMonth}_${station}.profile.nc" " >> ${NED_WORKING_DIR}/${currentMonth}StationNames.list
done

echo "scp ${NED_WORKING_DIR}/${currentMonth}StationNames.list $REMOTE_USER@$MACH:$WORK_DIR"
scp ${NED_WORKING_DIR}/${currentMonth}StationNames.list $REMOTE_USER@$MACH:$WORK_DIR
export outputCode=$?
if [ "$outputCode" != "0" ]; then
    echo "There was a problem copying ${currentMonth}StationNames.list file to $MACH"
    echo "------------------------"
    exit -1
else
	echo "Output check cleared: $outputCode"
fi

echo "----------------------------"
echo "Adding $currentMonth as lastMonth to workflow config"
echo "------------------------"
echo ""

echo "export lastMonth=$currentMonth" >> $workflowConfig

exit 0
