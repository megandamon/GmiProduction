#!/bin/bash -xv

. $NED_WORKING_DIR/.exp_env.bash
. $ENV_FILE

echo "------------------------"
echo "NED_USER: $NED_USER"
echo "NED_WORKING_DIR: $NED_WORKING_DIR"
echo "------------------------"
echo ""

echo "------------------------"
if [ "$MACH" == "discover" ]; then
   expectedReturn="discover"
elif [ "$MACH" == "localhost" ]; then
	expectedReturn="NONE"
else
	echo "$MACH not yet supported."
	exit -1
fi

echo "Checking for password-less ssh to $MACH"
hostNameLength=${#expectedReturn}
sshOutput=`ssh $NED_USER@$MACH hostname`

if [ "$?" != "0" ]; then
	echo "There may be an account problem on $MACH"
	echo "Check your .ssh settings for $MACH"
	exit -1
fi

if [ "$MACH" == "discover" ]; then
	if [ "${sshOutput:0:$hostNameLength}" != "$expectedReturn" ]; then
      echo "ssh output: $sshOutput"
      echo "expected: $expectedReturn"
      echo "There may be an account problem on $MACH"
      echo "Check your .ssh/authorized_keys file"
      exit -1
	else
		echo "ssh output: $sshOutput" 
	fi
fi

echo "$MACH ssh password-less check passed"
echo "------------------------"
exit 0 

