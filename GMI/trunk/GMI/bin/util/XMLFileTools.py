#!/usr/bin/env python

#------------------------------------------------------------------------------
# NASA/GSFC, Software Integration & Visualization Office, Code 610.3
#------------------------------------------------------------------------------
# AUTHORS:      Megan Damon
# AFFILIATION:  NASA GSFC / NGIT / TASC
# DATE:         November 19 2008
#
# DESCRIPTION:
# This class provides routines for handling XML files.
#------------------------------------------------------------------------------

import os
import sys
import re
import string
import xml.dom.minidom

class XMLFileTools:


   BAD_INPUT = -1
   SCP_ERROR = -2
   SSH_ERROR = -3
   IO_ERROR = -4
   SSH_SUCCESS = 0

   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION: 
   # Constructor routine.
   #---------------------------------------------------------------------------  
   def __init__(self):
      self.xmlDoc = None
      self.fileName = None

   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION: 
   # Destructor routine
   #---------------------------------------------------------------------------  
   def __del__(self):
      pass

   def getValueFromFile (self, searchKey, varName):

      if self.fileName == None or not os.path.exists (self.fileName):
         raise self.BAD_INPUT

      xmlDoc= xml.dom.minidom.parse(self.fileName)
      entries=xmlDoc.getElementsByTagName(searchKey)
      
      for entry in entries:
         if re.search(varName, entry.toxml()):
            return entry.firstChild.data 
      
