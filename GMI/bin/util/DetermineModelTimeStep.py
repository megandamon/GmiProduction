#!/usr/bin/env python

#------------------------------------------------------------------------------
# AUTHORS:      Megan Damon
# AFFILIATION:  NASA GSFC / NGIT / TASC
# DATE:         October 10th, 2013
#
# DESCRIPTION:
# This script look at a file on a remote system and determine
# the date of the most recent model time step
# 
# Execute this script by typing : 
# python DetermineModelTimeStep.py -f stdout file -u user name -m remote system name -s search string 
#                                   
# NOTE:
#
# ** As input this script excepts a FULL PATH to a run directory; DO NOT
#    use unix/linux variables such as $HOME or relative paths.

# Modification History
#------------------------------------------------------------------------------

__author__ = 'Megan Damon'
__version__ = '0.0'
__date__ = '2013/3/10'

def removeAllLinesMatching(matchString, lines):
    
    newLines = []
    for line in lines:
        if line.find(matchString) == -1:
            newLines.append(line)
    
    return newLines
             
            
    

def executeSystemCmdAndCollectOutput(systemCommand):
    print systemCommand
    subProcess = subprocess.Popen(systemCommand, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    cmdOut, cmdErr = subProcess.communicate()
    return cmdOut

def extractYmdFromLine(ymdLines, lineFromBottom, splitNumber):
    numLines = len(ymdLines)
    lastLine = ymdLines[numLines - lineFromBottom]
    lastLineSplit = lastLine.split(',')
    ymd = lastLineSplit[splitNumber]
    return ymd.strip()

def usage ():
    print "Usage: MakeNameLists.py [-f][-e]"
    print "-p Full path remote stdout file"
    print "-e Full path to experiment's env file"
    sys.exit (0)

def extractEnvVariable(expEnvLines, searchString):
    
    matching = [s for s in expEnvLines if searchString in s]
    if len(matching) < 1:
        return None
    print matching
    
    matchArray = matching[0].split('=')
    matchQuotes = matchArray[1]
    matchArray = matchQuotes.split("\"")
    
    if len(matchArray) > 1: match = matchArray[1]
    else: match = matchArray[0]
    return match.strip()


import getopt
import sys
import os
import time
import commands
import subprocess
from IoRoutines import IoRoutines



NUM_ARGS=2
NUM_SPLIT_ARGS=5

ioRoutines = IoRoutines()

# Get options from command line
optList, argList = getopt.getopt(sys.argv[1:],'f:e:')
if len (optList) != NUM_ARGS:
    usage ()

stdoutFileName = optList[0][1]
expEnvFile = optList[1][1]

try:
    expEnvLines = ioRoutines.readFile(expEnvFile)
except:
    print "Check the file: ", expEnvFile
    sys.exit(-1)


machineName = extractEnvVariable(expEnvLines, "export MACH=" )
userName = extractEnvVariable(expEnvLines, "export NED_USER=" )
successString = extractEnvVariable(expEnvLines, "export SUCCESS_STRING=" )
searchString = extractEnvVariable(expEnvLines, "export YMD_STRING=" )


if machineName == None or userName == None or successString == None or searchString == None:
    print "MACH, NED_USER, and SUCCESS_STRING need to be defined in the environment"
    sys.exit(-1)


# first check if the job has already completed successfully
systemCommand = 'ssh ' + userName + '@' + machineName + " tail -n 1000 " + stdoutFileName + " | grep " + "\"" + successString + "\""
cmdOut = executeSystemCmdAndCollectOutput(systemCommand)

completeSuccessfulJob = False
if len(cmdOut) != 0:
    completeSuccessfulJob = True

print "has the job completed successfully? ", completeSuccessfulJob    


# start a process and get the process output
systemCommand = 'ssh ' + userName + '@' + machineName + " tail -n 1000 " + stdoutFileName + " | grep " + "\"" + searchString +"\""
cmdOut = executeSystemCmdAndCollectOutput(systemCommand)
ymdLines = cmdOut.split(searchString)

lastYmd = extractYmdFromLine(ymdLines, 1, NUM_SPLIT_ARGS)
newYmdLines = removeAllLinesMatching (lastYmd, ymdLines)
secondToLastYmd = extractYmdFromLine(newYmdLines, 1, NUM_SPLIT_ARGS)

# if the current job has completed, a few things could be true:
# 1. The simulation is complete and the calling task shouldn't be called again. 
# 2. The simulation is not complete. The next month is waiting in queue.
# 3. The simulation is not complete and although the last month finished successfully, the other jobs won't run. 
# Option 3 is tricky to determine. 
if (completeSuccessfulJob == True):
    
    endDate = extractEnvVariable(expEnvLines, "export END_DATE=")
    
    if endDate == None:
        print "Check END_DATE"
        sys.exit(-1)
        
    # case 1. 
    if (endDate == secondToLastYmd):
        print "Simulation completed"
        print "UPDATE: reached end date: ", lastYmd
        # if the simulation is done, signal to the calling process that it is
        sys.exit(1)
    
    
    # cases 2. and 3.
    else:
        print "UPDATE: current YMD: ", lastYmd
        print "Simulation not complete"
        sys.exit(0)

#sleep and repeat the process
else:
    # TODO - or possibly use "retries on fail" option in NED
    print "The current job appears to be time stepping... will sleep and re-confirm"
    print "UPDATE: current YMD: ", lastYmd
    time.sleep(5)
    # first save the old last ymd line
    # now sleep
    # get new last ymd line
    # if the old and new last ymd lines are the same, this could mean a problem
    



print "Exiting DetermineModelTimeStep.py"
sys.stdout.flush()
sys.exit(0)
