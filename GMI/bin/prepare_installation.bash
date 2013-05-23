#!/bin/bash -xv


. $NED_WORKING_DIR/.exp_env.bash
. $ENV_FILE

echo "------------------------"
echo "NED_USER: $NED_USER"
echo "NED_WORKING_DIR: $NED_WORKING_DIR"
echo "------------------------"
echo ""

echo "------------------------"

if [ "$COMPILE" = "T" ]; then

   # copy the executable to the working directory
   echo "GMI executable selected from compilation"
   echo -e "\nssh $NED_USER@$MACH $CP $WORK_DIR/gmi_gsfc/Applications/GmiBin/gmi.x $WORK_DIR"
   ssh $NED_USER@$MACH $CP $WORK_DIR/gmi_gsfc/Applications/GmiBin/gmi.x $WORK_DIR
   if [ "$?" != "0" ]; then
       echo "There was a problem copying the executable"
       exit -1
   fi
   echo "------------------------"

else

   echo "Will copy GMI installation from pre compiled collection"
   echo "Installation directory: $INSTALL_GMI"
   echo "Working directory: $WORK_DIR"
   echo "------------------------"
   echo ""

   echo "------------------------"
   echo "Proceeding with installation"

   echo ""
   echo "Copying the executable from $INSTALL_GMI to $WORK_DIR"
   $SSH_PATH $NED_USER@$MACH $CP $INSTALL_GMI/gmi.x $WORK_DIR 
    if [ "$?" != "0" ]; then
      echo "Could not copy the executable" 
      echo "----------------------------"
      echo ""
      exit -1
   fi


fi

echo "----------------------------"

exit 0
