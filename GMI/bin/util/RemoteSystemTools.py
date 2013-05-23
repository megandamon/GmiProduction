#!/usr/bin/env python

#------------------------------------------------------------------------------
# NASA/GSFC, Software Integration & Visualization Office, Code 610.3
#------------------------------------------------------------------------------
# AUTHORS:      Megan Damon
# AFFILIATION:  NASA GSFC / NGIT / TASC
# DATE:         May 8 2008
#
# DESCRIPTION:
# This class provides routine for connecting to remote systems.
#------------------------------------------------------------------------------

import os
import sys
import string

class RemoteSystemTools:


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
       pass

   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION: 
   # Destructor routine
   #---------------------------------------------------------------------------  
   def __del__(self):
      pass

   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION: 
   # Will copy the local file to a remote server and attempt to execute it.
   #---------------------------------------------------------------------------  
   def copyLocalFileAndExecute (self, scriptFile, scriptPath, userName, remoteSys, remotePath):

       if not os.path.exists(scriptPath + "/" + scriptFile) or len(userName) <= 0 \
               or len(remoteSys) <= 0:
           raise self.BAD_INPUT

       status = os.system ("scp " + scriptPath + "/" + scriptFile + " " + userName + "@" + \
                               remoteSys + ":" + remotePath)
       if status != 0:
           raise self.SCP_ERROR


       systemCommand = "ssh " + userName + "@" + remoteSys + " chmod 700 " + \
           remotePath + scriptFile
       status = os.system (systemCommand)
       if status != 0:
           raise self.SSH_ERROR

       systemCommand = "ssh " + userName + "@" + remoteSys + " ./" + \
                               remotePath + "/" + scriptFile
       status = os.system (systemCommand)
       if status != 0:
           raise self.SSH_ERROR

       systemCommand = "ssh " + userName + "@" + remoteSys + " rm " + \
           remotePath + scriptFile
       status = os.system (systemCommand)
       if status != 0:
           raise self.SSH_ERROR
                          

   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION: 
   # This routine will submit a remote pbs file to a remote pbs system.
   # The returned job ID and realUser name will be recorded in the 
   # accountingFile.
   #---------------------------------------------------------------------------  
   def submitJobAndRecord (self, remoteWorkingDir, remotePbsFile, qsubCommand, \
                              accountingFile, nedUser, realUser, \
                              workflowEnvFile, remoteSystem):

      
      # check that files exist
      if not os.path.exists (accountingFile) or \
             not os.path.exists (workflowEnvFile):
         raise BAD_INPUT


      # construct ssh command to submit the job to pbs
      systemCommand = "ssh " + nedUser + "@" + remoteSystem + " 'cd " + \
           remoteWorkingDir + ";" + qsubCommand + " " + remotePbsFile + "'"


      # start a process to submit the job to pbs
      # and collection the process output
      subProcess = os.popen(systemCommand)
      processOutput = subProcess.read()
      closeReturn = subProcess.close ()
      if closeReturn != None:
         raise SSH_ERROR


      # create an entry for accounting
      jobId = string.strip(processOutput)
      newEntry = jobId + ", " + realUser + "\n"
      
      # add job id to workflow env file
      try:

         wkEnvFileHandle = open (workflowEnvFile, 'a')
         wkEnvFileHandle.write ('#Model segment job ID\n')
         newJobId = jobId.replace ('.pbsa1', '')
         wkEnvFileHandle.write ('export jobID=' + newJobId + '\n')
         wkEnvFileHandle.close ()
      except:
         raise IO_ERROR

      # if ned user and the real user are not the same, 
      # do the accounting
      if nedUser != realUser:
         
         print "nedUser: ", nedUser
         print "realUser: ", realUser

         try:
            accFileHandle = open (accountingFile, 'a')
            accFileHandle.write (newEntry)
            accFileHandle.close ()
            
         except:
            raise IO_ERROR

      return jobId
