#!/usr/bin/env python

#------------------------------------------------------------------------------
# NASA/GSFC, Software Integration & Visualization Office, Code 610.3
#------------------------------------------------------------------------------
# AUTHORS:      Megan Damon
# AFFILIATION:  NASA GSFC / NGIT / TASC
# DATE:         April 9th, 2007
#
# DESCRIPTION:
# This class contains the routines for performing GMI production tasks.
# NOTE: the problem_name under the ESM namelist section should be the
# same as the name of the namelist file excluding the ".in".  For example:
# namelist file: mar04.in
# problem_name: mar04
#------------------------------------------------------------------------------

import os
import re
import commands
import sys
import string
import datetime
import math

from GmiExceptions import GmiExceptions
from IoRoutines import IoRoutines
from GmiAutomationConstants import GmiAutomationConstants
from GmiAutomationTools import GmiAutomationTools

class GmiProduction:
   
   
   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION: 
   # Constructor routine.
   #---------------------------------------------------------------------------  
   
   def __init__(self):

      self.queueFileName = ""
      self.nameListName = ""
      self.queueJobName = ""
      self.runDirectory = ""
      self.storageDirectory = ""
      self.longDescription = ""
      self.segmentDescription = ""
      self.modelVersion = ""
      self.mailTo = ""
      self.queueId = ""
      self.base = ""
      self.year = ""
      self.month = ""
      self.archiveSystem = ""
      self.scali = None
      
      self.exceptions = GmiExceptions ()
      self.constants = GmiAutomationConstants ()
      self.automationObject = GmiAutomationTools ()
      self.ioObject = IoRoutines ()
      
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
   # This routine will modify the file name specified by queueFileName.
   # The job name and the namelist file in the mpirun
   # command will be changed.
   #---------------------------------------------------------------------------    
   
   def modifyQueueFile (self, defaultQueueFile, numProcessors, numProcessorsPerNode, \
                           chargeCode, chemicalMechanism, destinationDirectory, wallTime, \
                           useNlInMpi, lastJobId):

      print "numProcessorsPerhNOde: ", numProcessorsPerNode
      print "useNlInMpi: ", useNlInMpi

      if len (self.nameListName) <= 0:
          raise self.exceptions.BADOBJECTDATA
          return

      if len (self.runDirectory) <= 0:
          raise self.exceptions.BADOBJECTDATA
          return

      if numProcessors <= 0:
	raise self.exceptions.ERROR
       
      if not os.path.exists (defaultQueueFile):
         raise self.exceptions.NOSUCHFILE
         return
      
      extension = self.nameListName[len(self.nameListName)-len('.in'):len(self.nameListName)]
      if extension != ".in":
         raise self.exceptions.BADOBJECTDATA
         return
      
      self.base = self.nameListName[0:len(self.nameListName)-len(extension)]

      print "self.base: ", self.base

      # create the new queue file
      if len (self.base) > self.constants.MAXPBSJOBNAMELENGTH:
         self.queueJobName = self.base[0:self.constants.MAXPBSJOBNAMELENGTH]
      else:
         self.queueJobName = self.base
      
      if self.nameListName != "transfer.in":
         self.queueFileName = destinationDirectory + "/" + self.base + '.qsub'
      else: 
         self.queueFileName = destinationDirectory + "/transfer.qsub"

      print self.queueFileName
      
      systemCommand = self.constants.CPPATH + 'cp ' + defaultQueueFile + ' ' + self.queueFileName
      systemReturnCode = os.system (systemCommand)
      if systemReturnCode != 0:
         print "\nThere was an error copying the file ", defaultQueueFile, " to ", self.queueFileName
         sys.exit (1)
      
      print "reading the file: ", self.queueFileName

      # read the new file
      fileLines = self.ioObject.readFile (self.queueFileName)
      
      print "files lines from file: ", fileLines

      print "numProcessors, ", numProcessors
      print "numProcessorsPerNode, ", numProcessorsPerNode

      numberOfNodes=math.ceil(float(numProcessors)/float(numProcessorsPerNode))
      print "numberOfNodes = ", numberOfNodes

      # change the new file
      lineCounter = 0
      for line in fileLines:
         if line[0:7] == "#PBS -N":
            fileLines [lineCounter] = "#PBS -N " + self.queueJobName
         elif line[0:7] == "#PBS -q":
            fileLines [lineCounter] = "#PBS -q " + self.queueName
         elif re.search ("mpirun", line):
            fileLines [lineCounter] = line + " " + \
                " -perhost " + str(numProcessorsPerNode) + \
                " -np " + str(numProcessors) + \
                " $GEMHOME/gmi.x " 
            if useNlInMpi == "T":
               fileLines [lineCounter] = fileLines [lineCounter] + \
                   " -d " + self.nameListName
            fileLines [lineCounter] = fileLines [lineCounter] + \
                "| tee stdout.log"
         elif re.search ("MOCK", line):
            fileLines [lineCounter] = " $GEMHOME/./gmi.x " + \
                " -d " + self.nameListName  +  "| tee stdout.log"          
         elif re.search ("#PBS -W group_list", line):
            fileLines [lineCounter] = "#PBS -W group_list=" + chargeCode
         elif re.search ("#PBS -W depend", line):
            print "found depend line"
            if lastJobId != None:
               print "job id is not none"
               fileLines [lineCounter] = "#PBS -W depend=afterok:" + lastJobId         
            else:
               print "IN ELSE"
               fileLines [lineCounter] = ""
         elif re.search ("CHEMCASE", line):
            fileLines [lineCounter] = "setenv CHEMCASE " + chemicalMechanism
         elif re.search ("setenv workDir", line):
            fileLines [lineCounter] = "setenv workDir " + self.runDirectory
         elif re.search ("setenv GEMHOME", line):
            fileLines [lineCounter] = "setenv GEMHOME " + self.runDirectory
         elif re.search ("select=", line):
            print "replacing select line"
            fileLines [lineCounter] = "#PBS -l select=" + str (int(numberOfNodes)) + ":ncpus=" + numProcessorsPerNode + ":mpiprocs=" + numProcessorsPerNode
            if self.scali != None:
               if self.scali == "true":
                  fileLines [lineCounter] = fileLines [lineCounter]  + ":scali=true"
         elif re.search ("walltime", line):
            fileLines [lineCounter] = "#PBS -l walltime=" + wallTime
         elif re.search ("cp namelist.list gmiResourceFile.rc", line):
            fileLines [lineCounter] = "cp " + self.nameListName + " gmiResourceFile.rc"
         elif re.search ("bbscp", line):
            if re.search ("bbscp year/diagnostics", line):
               fileLines [lineCounter] = "bbscp " + self.year + "/diagnostics/*" + \
                   self.year + "*" + self.month + "* " + self.archivesystem +  ":" \
                   + self.storageDirectory
            else:
               filesLines [lineCounter] = ""
         lineCounter = lineCounter + 1
         

      # write the file
      self.ioObject.touchNewFile (self.queueFileName)
      self.ioObject.writeToFile (fileLines, self.queueFileName)


   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION: 
   # This routines submits the job using the queueFileName in the object.
   # The job id is both returned and set in the object as queueId.
   #---------------------------------------------------------------------------

   def submitJobToQueue (self):

      if len (self.queueFileName) <= 0:
         raise self.exceptions.BADOBJECTDATA
         return
         
      if not os.path.exists (self.queueFileName):
         raise self.exceptions.NOSUCHFILE
         return

      self.queueId = commands.getoutput (self.constants.QSUBPATH + "qsub " + self.queueFileName)

      return self.queueId

   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION: 
   # This routine returns the status of a queue job either JOBINQUEUE or
   # JOBNOTINQUEUE.
   #---------------------------------------------------------------------------

   def isJobInQueue (self):

      if len (self.queueId) <= 0:
         raise self.exceptions.BADOBJECTDATA
         return

      qstatCommand = self.constants.QSTATPATH + "qstat -p | " + self.constants.GREPPATH + "grep " + self.queueId + " | " + self.constants.AWKPATH +"awk \'{print $1}\' "
      status = commands.getoutput (qstatCommand)

      if status == '':
         return self.constants.JOBNOTINQUEUE

      if status == self.queueId:
         return self.constants.JOBINQUEUE


   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION: 
   # This routine checks for specific files that are expected from a GMI run.
   #---------------------------------------------------------------------------

   def checkForValidRun (self):

      if len (self.nameListName) <= 0:
         raise self.exceptions.BADOBJECTDATA
         return

      if len (self.runDirectory) <= 0:
         raise self.exceptions.BADOBJECTDATA
         return

      extension = self.nameListName[len(self.nameListName)-len('.in'):len(self.nameListName)]
      if extension != ".in":
         raise self.exceptions.BADOBJECTDATA
         return

      fileList = self.automationObject.getMatchingFiles (self.runDirectory, ".asc")
      if len (fileList) <= 0:
         return self.constants.NOTVALIDRUN

      # read the standard output file
      splitString = string.split (self.queueId, ".")
      queueNumber = splitString [0]
      if queueNumber == "":
         return self.constants.NOTVALIDRUN

      fileList = self.automationObject.getMatchingFiles (self.runDirectory, queueNumber)
      if len (fileList) <= 0:
         return self.constants.NOTVALIDRUN
            
      standardOutFile = fileList [0]
      fileLines = self.ioObject.readFile (self.runDirectory + "/" + standardOutFile)
      if len (fileLines) <= 0:
         return self.constants.NOTVALIDRUN

      # now search the file for the following string:
      searchString = "Successful completion of the run"

      foundIt = 0
      for line in fileLines:
         if re.search (searchString, line):
            foundIt = 1
            break

      if foundIt == 0:
         return self.constants.NOTVALIDRUN
            
      return self.constants.VALIDRUN

   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION:
   # This routine transfers data to a "completed" dieectory under a run
   # directory and catalogs them by job segment.
   #---------------------------------------------------------------------------

   def copyOutputDataToTempArchive (self, remoteSystem):

      print "top of copyOutputData"
      
      if len (self.nameListName) <= 0:
         raise self.exceptions.BADOBJECTDATA
         return

      if len (self.runDirectory) <= 0:
         raise self.exceptions.BADOBJECTDATA
         return
      
      if len (remoteSystem) == 0:
         if not os.path.exists (self.runDirectory):
            print "The runDirectory is : ", self.runDirectory
            raise self.exceptions.NOSUCHPATH
            return
         
      status = [] # contains status return codes and information

      if len (self.base) <= 0:
         self.base = self.nameListName[0:len(self.nameListName)-len('.in')]
      
      # "completed/YYYY" directory
      self.storageDirectory = self.runDirectory + "/completed" + "/" + self.year
      if len (remoteSystem) == 0:
         self.automationObject.createDirectoryStructure (self.storageDirectory)
      else:
         systemCommand = "ssh " + remoteSystem + " mkdir -p " + \
             self.storageDirectory
         print systemCommand
         os.system (systemCommand)
                    
      # "run_info/PET"
      runInfoDirectory = self.storageDirectory + "/run_info"
      petDirectory = runInfoDirectory + "/PET"
      if len (remoteSystem) == 0:
         self.automationObject.createDirectoryStructure (petDirectory)
      else:
         status.append (os.system ("ssh " + remoteSystem + " mkdir -p " + \
                                      petDirectory))

      # move the PET files
      systemCommand = "mv -f " + self.runDirectory + "/PET* " + petDirectory 
      print systemCommand
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      # move all .nc files to the storageDirectory for now
      systemCommand = "mv -f " + self.runDirectory + "/*.nc " + self.storageDirectory
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      # move the restart file
      if len (remoteSystem) == 0:
         status.append (self.moveFileToDirectory (self.storageDirectory + "/" + \
                                                     self.base + ".rst.nc", #
                                                  runInfoDirectory))
      else:
         status.append (os.system ("ssh " + remoteSystem + " mv -f " + \
                                      self.storageDirectory + "/" + self.base \
                                      + ".rst.nc " + runInfoDirectory))

      # now copy it back for the next segment
      systemCommand = "cp " + runInfoDirectory + "/*" + self.base + "*.rst.nc " + \
          self.runDirectory
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))


      # move the standard error/output file from the run directory
      # and rename it to $base.out in the run_info directory
      # get the numerical part of the queueId
      # POSSIBLE BUG for non discover NCCS systems
      splitString = string.split (self.queueId, ".")
      queueNumber = splitString [0]
      systemCommand = "mv -f " + self.runDirectory + "/*.e" + queueNumber + " " +  \
          runInfoDirectory + "/" + self.base + ".out"
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      # ascii file
      systemCommand = "mv -f " + self.runDirectory + "/*" + self.base + "*.asc " + runInfoDirectory
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      # qsub file
      systemCommand = "mv -f " + self.runDirectory + "/*" + self.base + "*.qsub " + runInfoDirectory
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      # log directory
      systemCommand = "mv -f " + self.runDirectory + "/*" + "esm_log_*" + self.base + " " + \
          runInfoDirectory
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      # timing file
      systemCommand = "mv -f " + self.runDirectory + "/*" + "esm_timing.*" + self.base + " " + \
          runInfoDirectory
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      # ftiming file
      systemCommand = "mv -f " + self.runDirectory + "/ftiming* " + runInfoDirectory
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      # namelist file
      systemCommand = "mv -f " + self.runDirectory + "/" + self.nameListName + " " + runInfoDirectory
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      # metfields file
      metFileDirectory = self.runDirectory + "/completed/" + "/metfile_lists/"
      if len (remoteSystem) == 0:
         self.automationObject.createDirectoryStructure (metFileDirectory)
      else:
         status.append (os.system ("ssh " + remoteSystem + " mkdir -p " + \
                                      metFileDirectory))

      systemCommand = "cp " + self.runDirectory + "/*" + self.month + self.year + \
          "*.list " + metFileDirectory
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      # diagostics files
      diagnosticsDirectory = self.storageDirectory + "/diagnostics"
      if len (remoteSystem) == 0:
         self.automationObject.createDirectoryStructure (diagnosticsDirectory)
      else:
         status.append (os.system ("ssh " + remoteSystem + " mkdir -p " + \
                                      diagnosticsDirectory))

      # flux file
      systemCommand = "mv -f " + self.storageDirectory + "/*" + self.base + "*_flux.nc " + \
          diagnosticsDirectory
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      # tend file
      systemCommand = "mv -f " + self.storageDirectory + "/*" + self.base + "*.tend.nc " + \
          diagnosticsDirectory
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      # qk file
      systemCommand = "mv -f " + self.storageDirectory + "/*" + self.base + "*.qk.nc " \
          + diagnosticsDirectory
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      # qj file
      systemCommand = "mv " + self.storageDirectory + "/*" + self.base + "*.qj.nc " + \
          diagnosticsDirectory
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      # qqjk file
      systemCommand = "mv -f " + self.storageDirectory + "/*" + self.base + "*.qqjk.nc " + \
          diagnosticsDirectory
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      # station output
      stationDirectory = self.storageDirectory + "/stations/" + self.month + "/"
      if len (remoteSystem) == 0:
         self.automationObject.createDirectoryStructure (stationDirectory)
      else:
         status.append (os.system ("ssh " + remoteSystem + " mkdir -p " + \
                                      stationDirectory))
      
      systemCommand = "mv -f " + self.storageDirectory + "/*" + self.base + \
          "*.profile.nc " + stationDirectory
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      # summary folders
      systemCommand = "mv -f " + self.runDirectory + "/completed/gmic_* " + runInfoDirectory
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      systemCommand = "mv -f " + self.runDirectory + "/stdout.log " + runInfoDirectory
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      systemCommand = "cp  " + self.runDirectory + "/gmi.x " + runInfoDirectory
      if len (remoteSystem) == 0:
         status.append (os.system (systemCommand))
      else:
         status.append (os.system ("ssh " + remoteSystem + " " + systemCommand))

      
      return status


   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION:
   # This routine simple copies the file to the directory specified.
   #---------------------------------------------------------------------------

   def moveFileToDirectory (self, file, directory):

      status = self.constants.NOERROR

      if not os.path.exists (file):
         status = self.constants.INCOMPLETEDATASET
      else:
         output = commands.getoutput (self.constants.MVPATH + "mv " + file + " " + directory)
         if output != "":
            status = self.constants.WRITEERROR

      print "here-last"
      return status


   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION:
   # This routine takes information from the GmiProduction object and writes
   # a summary to the "completed" directory.
   # Precondition: nameListName defined, runDirectory, what about qsubFile?
   #---------------------------------------------------------------------------

   def writeSummary (self) :

      if len (self.nameListName) <= 0:
         raise self.exceptions.BADOBJECTDATA
         return

      if len (self.runDirectory) <= 0:
         raise self.exceptions.BADOBJECTDATA
         return
      
      if not os.path.exists (self.runDirectory):
         raise self.exceptions.NOSUCHPATH
         return

      if len (self.base) <= 0:
         self.base = self.nameListName[0:len(self.nameListName)-len('.in')]

      if not os.path.exists (self.runDirectory + "/completed/`" + self.base):
         self.automationObject.createDirectoryStructure (self.runDirectory + "/completed/" + self.base)

      summaryFile = self.runDirectory + "/completed/" + self.base + "/summary.txt"
      self.ioObject.touchNewFile (summaryFile)

      fileLines = []

      if len (self.longDescription) <= 0:
         fileLines.append ("Long description: none")
      else:
         fileLines.append ("Long description: " + self.longDescription)

      if len (self.segmentDescription) <= 0:
         fileLines.append ("Segment description: " + self.base)
      else:
         fileLines.append ("Segment description: " + self.segmentDescription)

      if len (self.modelVersion) <= 0:
         fileLines.append ("Model version: none")
      else:
         fileLines.append ("Model version: " + self.modelVersion)

      if len (self.queueFileName) <= 0:
         fileLines.append ("Qsub file: none")
      else:
         fileLines.append ("Qsub file: " + self.queueFileName)

      fileLines.append ("Run directory: " + self.runDirectory)

      if len (self.mailTo) <= 0:
         fileLines.append ("Mail to: none")
      else:
         fileLines.apend ("Mail to: " + self.mailTo)

      if len (self.queueId) <= 0:
          fileLines.append ("Queue Id: none")
      else:
          fileLines.append ("Queue Id: " + self.queueId)

      fileLines.append ("Base: " + self.base)
      
         
      self.ioObject.writeToFile (fileLines, summaryFile)



   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION:
   #
   # This routine reads the namelist file and fills in the year and month
   # variables in the object.
   #---------------------------------------------------------------------------
   def fillInYearAndMonth (self):

      if len (self.runDirectory) <= 0 or len (self.nameListName) <= 0:
         raise self.exceptions.BADOBJECTDATA
         return
      
      # read the new file
      fileLines = self.ioObject.readFile (self.runDirectory + "/" + self.nameListName)
      if len (fileLines) <= 0:
         raise self.exceptions.ERROR

      for line in fileLines:

         if re.search ("begGmiDate", line):

            # get the part after the =
            splitString = string.split(line, "=")

            # get rid of comma and white spce
            date = string.strip (splitString[1])
            splitString = string.split (date, ",")
            ymd = splitString [0]
            
            if len(ymd) != 8:
               print "length of ymd is not 8\n";
               raise self.exceptions.ERROR 

            self.year = ymd [0:4]

            # get the month (first 3 letters in the month)
            when = datetime.date (string.atoi (self.year), #
                                  string.atoi (date[4:6]), string.atoi (date[6:8]))
            self.month = string.lower (when.strftime("%b"))
