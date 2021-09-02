#!/usr/bin/env python

#------------------------------------------------------------------------------
# AUTHORS:      Bruce Van Aartsen
# AFFILIATION:  NASA GSFC / SSAI
# DATE:         July 31, 2013
#
# DESCRIPTION:
# This script will increment the input date by one day
# 
# Execute this script by typing : 
# python incrdate.py <yyyymmdd>
#                                   
#------------------------------------------------------------------------------

__author__ = 'Bruce Van Aartsen'
__version__ = '0.0'
__date__ = '2013/31/07'

import datetime
import sys

#Parse 8-digit input
inputDate = sys.argv[1]
inYr = int(inputDate[0:4])
inMonth = int(inputDate[4:6])
inDay = int(inputDate[6:8])

date = datetime.datetime(inYr, inMonth, inDay)

#Increment by one day
nextDate = date + datetime.timedelta(days=1)

#Output in proper format
print nextDate.strftime('%Y%m%d')
 
