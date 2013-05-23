#!/usr/bin/env python 

#------------------------------------------------------------------------------
# NASA/GSFC, Software Integration & Visualization Office, Code 610.3
#------------------------------------------------------------------------------
# AUTHORS:      Megan Damon
# AFFILIATION:  NASA GSFC / NGIT / TASC
# DATE:         Nov 19 2008
#
# DESCRIPTION: 
#------------------------------------------------------------------------------

__author__ = 'Megan Damon'
__version__ = '0.0'
__date__ = '2008/11/19'

import re
import sys
import xml.dom.minidom
import getopt
import os
from XMLFileTools import XMLFileTools

NUM_ARGS = 4

def usage ():
    print "Usage: ReadValueFromXMLFile.py [-f] [-s] [-n] [-w]"
    print "-f full path to remote XML file"
    print "-s search key"
    print "-n variable name"
    print "-w workflow env file"
    sys.exit (0)

optList, argList = getopt.getopt(sys.argv[1:], 'f:s:n:w:')

if len (optList) != NUM_ARGS:
    usage ()


fileName = optList[0][1]
searchKey = optList[1][1]
varName = optList[2][1]
workflowEnvFile = optList[3][1]

xmlObject = XMLFileTools ()

if not os.path.exists (workflowEnvFile):
    sys.stderr.write ("\nThe file: " + workflowEnvFile + " does not exist" + "\n")
    sys.exit (-1)

try:
    
    xmlObject.fileName = fileName
    theValue = xmlObject.getValueFromFile (searchKey, varName)

      # add job id to workflow env file
    wkEnvFileHandle = open (workflowEnvFile, 'a')
    wkEnvFileHandle.write ('#' + varName + '\n')
    varName = varName.replace (' ', '_')
    wkEnvFileHandle.write ('export ' + varName + '="' + theValue + '"\n')
    wkEnvFileHandle.close ()
    
except:
    sys.stderr.write ("\nProblem getting the value of the variable: " + varName + "\n")
    sys.exit (-1)
    
