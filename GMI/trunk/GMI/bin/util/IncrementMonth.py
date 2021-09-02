#!/usr/bin/env python

#------------------------------------------------------------------------------
# AUTHORS:      Megan Damon
# AFFILIATION:  NASA GSFC / NGIT / TASC
# DATE:         October 28th, 2010
#
# DESCRIPTION:
# This script will increment the date given by one month
# 
# Execute this script by typing : 
# python  IncrementMonth.py -d YYYYMMDD
#                                   
# NOTE:
#
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

NUM_ARGS=1

def usage ():
    print "Usage: IncrementMonth.py [-d YYYYMMDD]"
    sys.exit (-1)

#---------------------------------------------------------------
# Get options from command line
#---------------------------------------------------------------
optList, argList = getopt.getopt(sys.argv[1:],'d:')

if len (optList) != NUM_ARGS:
    usage ()

theDate = optList[0][1]
theYear = theDate[0:4]
theMonth = theDate[4:6]
theDay = theDate[6:8]

if len(theDate) != 8 or \
        int(theMonth) > 12 or int(theMonth) < 1:
    usage ()

if int(theMonth) < 12:
    nextMonth = int(theMonth) + 1
    nextYear = theYear
else:
    nextMonth = 1
    nextYear = int(theYear) + 1

if nextMonth > 9:
    nextMonth = str(nextMonth)
else:
    nextMonth = "0" + str(nextMonth)

nextYear = str(nextYear)
nextDate = nextYear + nextMonth + theDay
print nextDate
