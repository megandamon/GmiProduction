#!/usr/bin/env python

#------------------------------------------------------------------------------
# NASA/GSFC, Software Integration & Visualization Office, Code 610.3
#------------------------------------------------------------------------------
# AUTHORS:      Megan Damon
# AFFILIATION:  NASA GSFC / NGIT / TASC
# DATE:         May 8 2008
#
# DESCRIPTION: This script will attempt to copy a local file to a remote
#              system and then execute the script on the remote system.
#------------------------------------------------------------------------------

__author__ = 'Megan Damon'
__version__ = '0.0'
__date__ = '2008/5/8'

import getopt
import os
import sys
from RemoteSystemTools import RemoteSystemTools

NUM_ARGS = 4

def usage ():
    print "Usage: RunScriptOnRemoteSystem.py [-f] [-p] [-u] [-r]"
    print "-f name of script"
    print "-p local path to script"
    print "-u user name" 
    print "-r remote system"
    sys.exit (0)

optList, argList = getopt.getopt(sys.argv[1:], 'f:p:u:r:')

if len (optList) != NUM_ARGS:
    usage ()

scriptFile = optList[0][1]
scriptPath = optList[1][1]
userName   = optList[2][1]
remoteSys  = optList[3][1]


remoteSysTool = RemoteSystemTools ()

try:
    remoteSysTool.copyLocalFileAndExecute (scriptFile, scriptPath, userName, remoteSys, "")
except:
    sys.stderr.write ("Problem executing remote script\n")
    sys.exit (-1)

