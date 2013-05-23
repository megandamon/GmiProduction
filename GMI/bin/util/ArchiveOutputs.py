#!/usr/bin/env python

#------------------------------------------------------------------------------
# AUTHORS:      Megan Damon
# AFFILIATION:  NASA GSFC / NGIT / TASC
# DATE:         June 8th, 2007
#
# DESCRIPTION:
# This script will archive GMI segment results on a remote system.
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
import time
import commands

from GmiProduction import GmiProduction

NUM_ARGS=7

def usage ():
    print "Usage: MakeQueueScript.py [-r][-d][-w][-n][-q][-c][-u]"
    print "-r Remote system"
    print "-d Date"
    print "-w Working directory on remote system"
    print "-n Namelist file for segment"
    print "-q Queue id"
    print "-c Local run directory (NED_WORKING_DIR)"
    print "-u User name"
    sys.exit (0)

#---------------------------------------------------------------
# Get options from command line
#---------------------------------------------------------------
optList, argList = getopt.getopt(sys.argv[1:],'r:d:w:n:q:c:u:')

if len (optList) != NUM_ARGS:
    usage ()


productionObject = GmiProduction ()
productionObject.nameListName = optList[3][1]
productionObject.runDirectory = optList[5][1]
productionObject.fillInYearAndMonth ()
productionObject.runDirectory = optList[2][1]
productionObject.queueId = optList[4][1]
productionObject.userName = optList[6][1]
theDate = optList[1][1]
productionObject.year = theDate[0:4]
print "Archving job with id LALA: ", productionObject.queueId

print optList[0][1]

print "Before copyOutputDataToTempArchive"
productionObject.copyOutputDataToTempArchive (optList[0][1])

                                 



