#!/bin/bash

#export workflowConfig=$NED_WORKING_DIR/WorkflowConfigs.bash
export workflowConfig=$NED_WORKING_DIR/.exp_env.bash
echo $workflowConfig
. $workflowConfig

echo "------------------------"
echo "NED_USER: $NED_USER"
echo "NED_WORKING_DIR: $NED_WORKING_DIR"
echo "------------------------"
echo ""

export yearDirectory=$WORK_DIR/completed/$YEAR

echo "----------------------------"
echo "Copying $yearDirectory to $ARCHIVE_DIR"
echo "------------------------"
echo ""


# check if year directory already exists in archive
echo "ssh $NED_USER@$MACH cd $ARCHIVE_DIR/$YEAR ;pwd"
ssh $NED_USER@$MACH "cd $ARCHIVE_DIR/$YEAR ;pwd"
export outputCode=$?

export xFlag=""
if [ "$TRANSFER_CMD" == "cp" ]; then
   export xFlag="-R"
fi

# if the archive year directory exists, then traverse each directory in $WORK_DIR/$YEAR
if [ "$outputCode" == "0" ]; then
	echo "archive directory exists: $outputCode"
	
	# first handle each sub-directory
	directories=( diagnostics run_info stations )
	for directory in "${directories[@]}"
	do
		
		echo "ssh $NED_USER@$MACH cd $ARCHIVE_DIR/$YEAR/$directory"
		ssh $NED_USER@$MACH cd $ARCHIVE_DIR/$YEAR/$directory
		export outputCode=$?
		
		# if the sub-directory already exists, copy the files over
		echo "$ARCHIVE_DIR/$YEAR/$directory exists? $outputCode"
		if [ "$outputCode" == "0" ]; then
			echo "Copying $directory files to existing archive directory."
			
         # Switched from "cp" to "find -exec cp" to avoid [Argument list too long] error on OS X
			echo "ssh $NED_USER@$MACH find $yearDirectory/$directory -maxdepth 1 -name \"*\" -exec $TRANSFER_CMD {} $ARCHIVE_DIR/$YEAR/$directory \;"
			#ssh $NED_USER@$MACH $TRANSFER_CMD $yearDirectory/$directory/* $ARCHIVE_DIR/$YEAR/$directory
         ssh $NED_USER@$MACH "find $yearDirectory/$directory -maxdepth 1 -name \"*\" -exec $TRANSFER_CMD {} $ARCHIVE_DIR/$YEAR/$directory \;"
         export outputCode=$?
			if [ "$outputCode" == "0" ]; then
				echo "Success copying files to existing directory"
			else
				echo "Error copying $directory files to existing directory"
				exit -1
			fi
		
		# if the sub-directory doesn't exist, then copy the whole sub-directory over	
		else			
			echo "Copying $directory to $ARCHIVE_DIR/$YEAR"
			
			echo "ssh $NED_USER@$MACH $TRANSFER_CMD $xFlag $yearDirectory/$directory $ARCHIVE_DIR/$YEAR/"
			ssh $NED_USER@$MACH $TRANSFER_CMD $xFlag $yearDirectory/$directory $ARCHIVE_DIR/$YEAR/
			export outputCode=$?
			if [ "$outputCode" == "0" ]; then
				echo "Success copying the entire directory"
			else
				echo "Error copying the directory $directory"
				exit -1
			fi
		fi	
		
		done	
		
		echo "Now copying netcdf files from $yearDirectory to $ARCHIVE_DIR/$YEAR"
		echo "ssh $NED_USER@$MACH $TRANSFER_CMD $yearDirectory/*.nc $ARCHIVE_DIR/$YEAR/"
		ssh $NED_USER@$MACH $TRANSFER_CMD $yearDirectory/*.nc $ARCHIVE_DIR/$YEAR/
		export outputCode=$?
		if [ "$outputCode" == "0" ]; then
			echo "Success copying the netcdf files in $WORK_DIR/$YEAR"
		else
			echo "Error copying the netcdf files in $WORK_DIR/$YEAR"
			exit -1
		fi
		

# if the year directory does not exist, then copy the entire thing
elif [ "$outputCode" == "2" ] || [ "$outputCode" == "1" ]; then	
#   if [ "$TRANSFER_CMD" == "cp" ]; then
#	   export TRANSFER_CMD="cp -R"
#   fi
	echo "$ARCHIVE_DIR/$YEAR does not exist: $outputCode"
   echo "Now copying the entire year directory to archive directory"
	
	echo "ssh $NED_USER@$MACH $TRANSFER_CMD $xFlag $yearDirectory $ARCHIVE_DIR"
	ssh $NED_USER@$MACH $TRANSFER_CMD $xFlag $yearDirectory $ARCHIVE_DIR/
	export outputCode=$?
	
	if [ "$outputCode" == "0" ]; then
		echo "Success copying $yearDirectory to $ARCHIVE_DIR"
	else
		echo "Failed copying $yearDirectory to $ARCHIVE_DIR!!!"
		exit -1
	fi		
	
		
				
			
else
	echo "Do not understand this code:  $outputCode"
	exit -1
fi



echo "Success. Exiting"
exit 0

# now write task to see if file numbers match
echo "Remove: $yearDirectory"
