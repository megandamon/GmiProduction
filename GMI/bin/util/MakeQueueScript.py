#!/usr/bin/env python

#------------------------------------------------------------------------------
# AUTHORS:      Megan Damon
# AFFILIATION:  NASA GSFC / NGIT / TASC
# DATE:         June 8th, 2007
#
# DESCRIPTION:
# This script will create a PBS script based on a template.
# 
# Execute this script by typing : 
# python 
#                                   
# NOTE:
#
# ** As input this script excepts a FULL PATH to a run directory; DO NOT
#    use unix/linux variables such as $HOME or relative paths.

# Modification History
#------------------------------------------------------------------------------

__author__ = 'Megan Damon'
__version__ = '0.0'
__date__ = '2008/24/4'


import getopt
import sys
import os
import re
import string
import time
import commands

from GmiProduction import GmiProduction

NUM_ARGS=14

def usage ():
    print "Usage: MakeQueueScript.py [-f][-n][-e][-m][-p][-c][-a][-d][-w][-s][-u][-o][-q]"
    print "-f Full path to queue script template"
    print "-n Number of processes"
    print "-e Number of processors per node"
    print "-m Name of namelist file"
    print "-p Run directory"
    print "-c Charge code"
    print "-a Chemical mechanism"
    print "-d Destination directory"
    print "-w Wall time"
    print "-s scali (true/false)"
    print "-u Use Fortran namelist? (T/F)"
    print "-i Add -d option to run script?"
    print "-o Job ID that needs to complete before job can run"
    print "-q queue name"
    sys.exit (0)

#---------------------------------------------------------------
# Get options from command line
#---------------------------------------------------------------
optList, argList = getopt.getopt(sys.argv[1:],'f:n:e:m:p:c:a:d:w:s:u:i:o:q:')

if len (optList) != NUM_ARGS:
    usage ()


productionObject = GmiProduction ()
productionObject.nameListName = optList[3][1]
productionObject.runDirectory = optList[4][1]
productionObject.fillInYearAndMonth
productionObject.scali = optList[9][1]
productionObject.queueName = optList[13][1]
print "Scali = ",optList[9][1]
print "queue: ", productionObject.queueName

splitString = string.split(productionObject.nameListName, "_")
print "split string: ", splitString
productionObject.year = string.strip (splitString[2])
if not productionObject.year.isdigit():
    print "ERROR: The year is not all digits!"
    sys.exit(-1)

productionObject.month = string.strip (splitString[3])
print "The job to archive is: ", productionObject.month, " ", productionObject.year

if productionObject.nameListName == "gmiWork.in":
    productionObject.storageDirectory = os.environ.get('ARCHIVE_DIR')
    productionObject.archiveSystem = "dirac"

print "Number of processors per node: ", optList[2]

if optList[12][1] == "0000": 
    lastJobId = None
else:
    lastJobId = optList[12][1]

print "last job id: ", lastJobId

productionObject.modifyQueueFile (optList[0][1], optList[1][1], optList[2][1], \
                                      optList[5][1], optList[6][1], optList[7][1], \
                                      optList[8][1], optList[11][1], lastJobId)



