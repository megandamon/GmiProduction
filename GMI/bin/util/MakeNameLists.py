#!/usr/bin/env python

#------------------------------------------------------------------------------
# AUTHORS:      Megan Damon
# AFFILIATION:  NASA GSFC / NGIT / TASC
# DATE:         June 8th, 2007
#
# DESCRIPTION:
# This script will create GMI namelists based on a base namelist
# 
# Execute this script by typing : 
# python MakeNameLists.py -p path to namelist -n namelist name -d current date 
# -r flag to replace restart file -z restart file path
#                                   
# NOTE:
#
# ** As input this script excepts a FULL PATH to a run directory; DO NOT
#    use unix/linux variables such as $HOME or relative paths.

# Modification History
#------------------------------------------------------------------------------

__author__ = 'Megan Damon'
__version__ = '0.0'
__date__ = '2008/21/3'


import getopt
import sys
import os
import time
import commands

from GmiNameLists import GmiNameLists

NUM_ARGS=9
nameListObject = GmiNameLists ()

def usage ():
    print "Usage: MakeNameLists.py [-p][-n][-d][-r][-z][-e][-f]"
    print "-p Full path to namelist directory"
    print "-n Name of namelist file"
    print "-d The current date or start date"
    print "-r Flag to replace restart file"
    print "-z Restart file directory"
    print "-e The end date"
    print "-f Use fortran namelist?"
    print "-s Gmi seconds"
    print "-v Environment file to update gmi seconds with"
    sys.exit (0)

#---------------------------------------------------------------
# Get options from command line
#---------------------------------------------------------------
optList, argList = getopt.getopt(sys.argv[1:],'p:n:d:r:z:e:f:s:v:')

if len (optList) != NUM_ARGS:
    usage ()

theDate = optList[2][1]
month = theDate[4:6]
endDate = optList[5][1]
gmiSeconds = optList[7][1]
envFile = optList[8][1]

monthsOfTheYear = {'01':'jan', \
                       '02':'feb', \
                       '03':'mar', \
                       '04': 'apr', \
                       '05': 'may', \
                       '06': 'jun', \
                       '07': 'jul', \
                       '08': 'aug', \
                       '09': 'sep', \
                       '10': 'oct', \
                       '11': 'nov', \
                       '12': 'dec'}


if ( int (endDate) - int (theDate) ) == 1:
    nameListObject.oneDay = 1
    nameListObject.endDate = endDate

nameListObject.nameListPath = optList [0][1]
nameListObject.nameListFile = optList [1][1]
nameListObject.numberOfNameLists = 1
nameListObject.startMonth = monthsOfTheYear[month]
nameListObject.startYear = theDate[0:4]
nameListObject.startDate = theDate
nameListObject.replaceRestartFile = int (optList[3][1])
nameListObject.restartFileDir = optList[4][1]
nameListObject.fortranNameList = optList[6][1]
nameListObject.gmiSeconds = gmiSeconds
nameListObject.envFile = envFile
print "replaceRestartFile: ", nameListObject.replaceRestartFile

nameListObject.makeNameLists ()
