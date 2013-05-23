#!/bin/bash -xv


. $NED_WORKING_DIR/.exp_env.bash
. $ENV_FILE

env >> $NED_WORKING_DIR/ENV.out

$ENV_PATH $SED_PATH -e "s/=/:/g" > $NED_WORKING_DIR/ENV.out
