#!/usr/bin/env python

#------------------------------------------------------------------------------
# NASA/GSFC, Software Integration & Visualization Office, Code 610.3
#------------------------------------------------------------------------------
# AUTHORS:      Megan Damon
# AFFILIATION:  NASA GSFC / NGIT / TASC
# DATE:         Oct 1 2008
#
# DESCRIPTION: This script will call the routine responsible routine
#              for submitting a pbs job and recording the real user name
#              and respective jobID.  Return values and errors will be handled
#              in this script.
#------------------------------------------------------------------------------

__author__ = 'Megan Damon'
__version__ = '0.0'
__date__ = '2008/10/1'

import getopt
import os
import sys
from RemoteSystemTools import RemoteSystemTools

NUM_ARGS = 8

def usage ():
    print "Usage: SubmitPbsJobAndRecord.py[-f] [-q] [-a] [-n] [-r] [-w] [-s]  [-d] "
    print "-f full path to remote qsub file"
    print "-q qsub executable on remote system"
    print "-a local path to accounting file"
    print "-n NED username"
    print "-r real username"
    print "-w workflow env file"
    print "-s remote system"
    print "-d remote working directory"
    sys.exit (0)

optList, argList = getopt.getopt(sys.argv[1:], 'f:q:a:n:r:w:s:d:')

if len (optList) != NUM_ARGS:
    usage ()

remoteQsubFile = optList[0][1]
remoteQsubCmd = optList[1][1]
accountingFile   = optList[2][1]
nedUser  = optList[3][1]
realUser  = optList[4][1]
workflowEnvFile = optList[5][1]
remoteSystem  = optList[6][1]
remoteWorkingDir = optList[7][1]

remoteSysTool = RemoteSystemTools ()

try:
    jobId = remoteSysTool.submitJobAndRecord (remoteWorkingDir, remoteQsubFile, remoteQsubCmd, \
                                          accountingFile, nedUser, \
                                          realUser, workflowEnvFile, remoteSystem)
    os.environ["JOB_ID"] = jobId
except:
    sys.stderr.write ("\nProblem submitting the remote job to: " + remoteSystem \
                          + "\n")
    sys.exit (-1)


print "\n"
print "Successful completion of script SubmitPbsJobAndRecord"
sys.exit (0)


