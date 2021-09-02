#!/bin/bash -xv

. $NED_WORKING_DIR/.exp_env.bash
. $ENV_FILE

echo "------------------------"
echo "NED_USER: $NED_USER"
echo "NED_WORKING_DIR: $NED_WORKING_DIR"
echo "------------------------"
echo ""

# Construct CVS command based on NED settings *
systemCommand="ssh $NED_USER@$MACH cd $WORK_DIR/; $CVS -d sourcemotel:/cvsroot/gmi"
if [ "$COMPILE" = "T" ]; then

   if [ "$TRUNK" = "T" ]; then
      echo "Checking out source code from the trunk"
      systemCommand="$systemCommand co gmi_gsfc"
   else
      echo "Checking out source code from the tag: $TAG"
      systemCommand="$systemCommand co -r $TAG gmi_gsfc"
   fi

else

   echo "Not compiling"
   exit 0
fi

echo $systemCommand
returnCode=`$systemCommand`

# Check that the "gmi_gsfc" directory exists
echo "ssh $NED_USER@$MACH $LS $WORK_DIR/gmi_gsfc"
ssh $NED_USER@$MACH $LS $WORK_DIR/gmi_gsfc
if [ "$?" != "0" ]; then
    echo "There was a problem with the CVS checkout"
    exit -1
fi


FILE=$NED_WORKING_DIR/compile.csh
cat << _EOF_ > $FILE

#!/usr/local/bin/csh
source $GMI_ENV

setenv BASEDIR $BASEDIR
setenv GMIHOME $WORK_DIR/gmi_gsfc
setenv CHEMCASE $CHEMISTRY
alias mkmf  '(/bin/rm -f Makefile; make -f $GMIHOME/Config/Makefile.init.int Makefile)'

cd $WORK_DIR/gmi_gsfc
gmake distclean
gmake all

_EOF_

chmod +x $FILE

# transfer script
echo -e "\nscp $FILE $NED_USER@$MACH:$WORK_DIR/gmi_gsfc"
scp $FILE $NED_USER@$MACH:$WORK_DIR/gmi_gsfc
echo "----------------------------------"
if [ "$?" != "0" ]; then
    echo "There was a problem copying $FILE to $MACH:$WORK_DIR/gmi_gsfc"
    exit -1
fi

# execute script
systemCommand="ssh $NED_USER@$MACH csh $WORK_DIR/gmi_gsfc/compile.csh"
echo $systemCommand
returnCode=`$systemCommand`

echo "----------------------------------"
echo ""
