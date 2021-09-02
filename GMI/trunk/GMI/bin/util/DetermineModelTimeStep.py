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




# starting from the bottom, 
#loop each line until one that has characters and isn't all whitespace is found
def getLastLinefromCmd(len, cmdOut):
    
    cmdOutSplit = cmdOut.split("\n")
    lastLine = None
    for line in cmdOutSplit:
        if (len(line) != 0 and not line.isspace()):
            lastLine = line
    
    return lastLine

def determineIfYearIsComplete(endDateYearMonth, lastYearMonth): #secondToLastYearMonth, secondToLastMonth, secondToLastDay, numDaysInMonth):
    yearComplete = False
    print "endDateYearMonth: ", endDateYearMonth
    print "lastYearMonth: :", lastYearMonth
    #print "secondToLastYearMonth: ", secondToLastYearMonth
    #print "secondToLastMonth: ", secondToLastMonth
    #print "secondToLastDay: ", secondToLastDay
    #print "numDaysInMonth: :", numDaysInMonth
    
    if (endDateYearMonth == lastYearMonth):
        yearComplete = True
    #if (endDateYearMonth == secondToLastYearMonth):
    #    if (secondToLastMonth != "02" and secondToLastDay == numDaysInMonth):
    #        yearComplete = True
    #    elif (secondToLastMonth == "02" and (secondToLastDay == '28' or secondToLastDay == '29')):
    #        yearComplete = True
    
    return yearComplete


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
    
    print "matchArray: ", matchArray
    
    if len(matchArray) > 1: match = matchArray[1]
    else: match = matchArray[0]
    return match.strip()

def unableToObtainYmdInfo(sleepSeconds, stdoutLines):
    print "Unable to obtain ymd information from stdout file at this time."
    print "stdoutLines:", stdoutLines
    time.sleep(int(sleepSeconds))
    print "Exiting DetermineModelTimeStep.py"
    sys.stdout.flush()
    sys.exit(0)


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
lastStdoutLine = extractEnvVariable(expEnvLines, "export lastStdoutLine=" )
sleepSeconds = extractEnvVariable(expEnvLines, "export SLEEP_SECONDS=" )


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
print systemCommand
cmdOut = executeSystemCmdAndCollectOutput(systemCommand)
print cmdOut

if (len(cmdOut) != 0):
    ymdLines = cmdOut.split(searchString)
    lastYmd = extractYmdFromLine(ymdLines, 1, NUM_SPLIT_ARGS)
    print "lastYmd: ", lastYmd
    newYmdLines = removeAllLinesMatching (lastYmd, ymdLines)
    print "newYmdLines: ", newYmdLines
    print "len of newYmdLines: ", len(newYmdLines)
    if (len(newYmdLines) > 1    ):
        secondToLastYmd = extractYmdFromLine(newYmdLines, 1, NUM_SPLIT_ARGS)
        newLastStdoutLine = getLastLinefromCmd(len, cmdOut)
        ioRoutines.writeToFile (["export lastStdoutLine=" + newLastStdoutLine], expEnvFile)
    else:
          unableToObtainYmdInfo(sleepSeconds, newYmdLines)
    
else:   
    
    systemCommand = 'ssh ' + userName + '@' + machineName + " tail -n 1000 " + stdoutFileName
    cmdOut = executeSystemCmdAndCollectOutput(systemCommand)
    stdoutLines = cmdOut.split("\n")
    unableToObtainYmdInfo(sleepSeconds, stdoutLines)
    

print "UPDATE: current YMD: ", lastYmd

# if the current job has completed, a few things could be true:
# 1. The year is complete and the calling task shouldn't be called again. 
# 2. The year is not complete. The next month is waiting in queue.
# 3. The year is not complete and although the last month finished successfully, the other jobs won't run. 
# Option 3 is tricky to determine. 
dayEndDict = {'12': '31', '11': '30', '10': '31', '09': '30', \
              '08': '31', '07': '31', '06': '30', '05': '31', \
              '04':'30', '03':'31', '02':'28', '01':'31'}

if (completeSuccessfulJob == True):
    
    endDate = extractEnvVariable(expEnvLines, "export CURRENT_END_DATE=")
    
    if endDate == None:
        print "Check CURRENT_END_DATE"
        sys.exit(-1)

    endDateYearMonth = endDate[0:6] 
    secondToLastYearMonth = secondToLastYmd[0:6]
    secondToLastMonth = secondToLastYmd[4:6]
    secondToLastDay = secondToLastYmd[6:8]
    numDaysInMonth =  dayEndDict[secondToLastYmd[4:6]]

    yearComplete = determineIfYearIsComplete(endDateYearMonth, lastYmd[0:6])
                                             #secondToLastYearMonth, \
                                             #secondToLastMonth, secondToLastDay, numDaysInMonth)    
                    
    if (yearComplete == True): sys.exit(1)
    else: sys.exit(0)                    

# has the model crashed?
# if not, sleep and exit
else:
    
    if (lastStdoutLine != None and lastStdoutLine.strip() == newLastStdoutLine.strip()):
        print "The model may have crashed!"
        sys.exit(254)
    else:
        print "The current job appears to be time stepping... sleeping"
        time.sleep(int(sleepSeconds))


print "Exiting DetermineModelTimeStep.py"
sys.stdout.flush()
sys.exit(0)
