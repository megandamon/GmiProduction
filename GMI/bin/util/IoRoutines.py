#!/usr/bin/env python

#------------------------------------------------------------------------------
# NASA/GSFC, Software Integration & Visualization Office, Code 610.3
#------------------------------------------------------------------------------
# AUTHORS:      Megan Damon
# AFFILIATION:  NASA GSFC / NGIT / TASC
# DATE:         February 20th 2007
#
# DESCRIPTION:
# Provides routines for IO.
#------------------------------------------------------------------------------

import os
import sys
import datetime
import re

from GmiAutomationConstants import GmiAutomationConstants

class IoRoutines:
   
   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION: 
   # Constructor routine.
   #---------------------------------------------------------------------------  
   
   def __init__(self):
      self.constants = GmiAutomationConstants ()
 
   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION: 
   # Destructor routine.
   #---------------------------------------------------------------------------    
   
   def __del__(self):
      pass

   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION: 
   # Reads an input file or throws a proper exception.
   #---------------------------------------------------------------------------             
   
   def readFile (self, fileName):
      
      if len (fileName) == 0: 
         raise self.constants.ERROR   
      
      if not os.path.exists (fileName):
         raise self.constants.NOSUCHFILE 
      
      fileContents = []
      
      try:
         fileObject = open (fileName, 'r')
         fileContents = fileObject.read ()
         fileObject.close ()
      except:
         return GmiAutomationTools.constants.READERROR
      
      fileLines = fileContents.splitlines()  
      
      return fileLines

   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION: 
   # Write the array to the file (appends if file exists or creates if not)
   #---------------------------------------------------------------------------    
   
   def writeToFile (self, fileContents, fileName):
      
      mode = 'a'
      
      if not os.path.exists (fileName):
         try:
            self.touchNewFile (fileName)
         except:
          raise self.constants.ERROR  
                     
      fileObject = open (fileName, mode)
      for line in fileContents:
         fileObject.write (line)
         fileObject.write ('\n')
         
      fileObject.close ()        
      
   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION: 
   # This routine simply creates a new file from the fileName
   #---------------------------------------------------------------------------  
   
   def touchNewFile (self, fileName):

      try:
         fileObject = open (fileName, 'w')
         fileObject.close ()
      except:
         raise self.constants.ERROR
      
   
