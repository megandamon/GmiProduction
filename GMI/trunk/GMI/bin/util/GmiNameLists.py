#!/usr/bin/env python

#------------------------------------------------------------------------------
# NASA/GSFC, Software Integration & Visualization Office, Code 610.3
#------------------------------------------------------------------------------
# AUTHORS:      Megan Damon
# AFFILIATION:  NASA GSFC / NGIT / TASC
# DATE:         May 3th, 2007
#
# DESCRIPTION:
#------------------------------------------------------------------------------

import string
import os
import re
import commands
import sys
from GmiExceptions import GmiExceptions
from IoRoutines import IoRoutines
from GmiAutomationTools import GmiAutomationTools

class GmiNameLists:
   
   
   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION: 
   # Constructor routine.
   #---------------------------------------------------------------------------  
   
   def __init__(self):
      
      self.nameListPath = ''
      self.nameListFile = ''
      self.numberOfNameLists = 0 
      self.startMonth = ''
      self.startYear = ''
      self.replaceRestartFile = 0
      self.restartFileDir = ''
      self.oneDay = 0
      self.endDate = ''
      self.exceptions = GmiExceptions ()
      self.fortranNameList = None
      self.gmiSeconds = None
      self.envFile = None

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
   # Prints objects contents 
   #---------------------------------------------------------------------------    
   
   def printMe (self):
      print "name list path: ", self.nameListPath
      print "name list file: ", self.nameListFile 
      print "number of name lists: ", self.numberOfNameLists
      print "start month: ", self.startMonth
      print "start year: ", self.startYear
      print "replace restart file?: ", self.replaceRestartFile
      print "restart file directory: ", self.restartFileDir

   #---------------------------------------------------------------------------  
   # AUTHORS: Megan Damon NASA GSFC / NGIT / TASC
   #
   # DESCRIPTION: 
   # This routine will create namelists based upon the example namelist. 
   # Orginally created by Gary Wojcik
   # Modified by Megan Damon
   # Pass "1" to replaceRestartFile to specify to only create one namelist
   # The script will work otherwise, but if you pass "1" - the restart file
   # will be replaced each time.
   #---------------------------------------------------------------------------  
   
   def makeNameLists (self):

      if self.fortranNameList == None:
         raise "Set fortranNameList before proceeding"
         return
      
      if len (self.nameListPath) <= 0: 
         raise self.exceptions.BADOBJECTDATA
         return
      
      if len (self.nameListFile) <= 0: 
         raise self.exceptions.BADOBJECTDATA
         return
      
      if self.numberOfNameLists <= 0: 
         raise self.exceptions.BADOBJECTDATA
         return
      
      if len (self.startMonth) <= 0: 
         raise self.exceptions.BADOBJECTDATA
         return
      
      if len (self.startYear) <= 0: 
         raise self.exceptions.BADOBJECTDATA
         return

      if not os.path.exists (self.nameListPath + "/" + self.nameListFile):
         raise self.exceptions.NOSUCHFILE
         return 


      autoTool = GmiAutomationTools ()
      
      pathToNameList = self.nameListPath
      namelistfile = self.nameListFile
      numNameLists = self.numberOfNameLists
      startmonth = self.startMonth
      startyear = self.startYear 
      

      
      #---------------------------------------------------------------------------  
      # Begin Gary Wojcik section
      # Modified by Megan Damon 3/20/2008
      #---------------------------------------------------------------------------  
   
      daysPerMonth=[31,28,31,30,31,30,31,31,30,31,30,31]
      monthNames=['jan', 'feb','mar','apr','may','jun','jul',\
                 'aug','sep','oct','nov', 'dec']
      
      ioObject = IoRoutines ()
      fileLines = ioObject.readFile (self.envFile)
      for line in fileLines:
          
          if re.search ('MATCH', line):
              
              splitString = line.split("=") 
              options = splitString[0].split(" ")
              option = options[1]
              value = splitString[1]
              
              
              
              if option == "MATCH_BC_TO_YEAR":
                  matchBcToYear = bool(1)
                  if value == "F":
                      matchBcToYear = bool(0)     
                       
              elif option == "MATCH_SAD_TO_YEAR":
                  matchSadToYear = bool(1)
                  if value == "F":
                      matchSadToYear = bool(0)
                      
              elif option == "MATCH_EMISS_TO_YEAR":
                  matchEmissToYear = bool(1)
                  if value == "F":
                      matchEmissToYear = bool(0)
                      
              elif option == "MATCH_AERDUST_TO_YEAR":
                  matchAerToYear = bool(1)
                  if value == "F":
                      matchAerToYear = bool(0)
                    
              elif option == "MATCH_LIGHT_TO_YEAR":
                  matchLightToYear = bool(1)
                  if value == "F":
                      matchLightToYear = bool(0)
              else:
                print "I don't understand this MATCH option and this could be a problem."
            
          elif re.search ('INITIAL', line):
              
              splitString = line.split("=") 
              options = splitString[0].split(" ")
              option = options[1]
              value = splitString[1]
              
              
              if option == "INITIAL_YEAR_FORC_BC":
                  initialYearForcBc = value
              
              elif option == "INITIAL_YEAR_LIGHT":
                  initialYearLight = value
            
              else:
                  print "I don't understand this INITIAL option and this could be a problme"
            
                
                


      # read the starting namelist file
      infil='%s/%s' % (pathToNameList, namelistfile)
      nfil=open(infil,"r")
      namelistContent=nfil.readlines()
      nfil.close()

      if self.fortranNameList == "true":
         splitter = "="
         endLine = ",\n"
      else:
         splitter = ":"
         endLine = "\n"

      # get orginal problem name
      # it is assumed the month is in the name
      foundIt = -1
      for line in namelistContent:
         if re.search ('problem_name', line):
            origproblemname=line.split(splitter)[1]
            origproblemname.strip()
            foundIt = 0



      if foundIt != 0:
         print "Problem finding the problem_name.  Check the namelist"
         sys.exit (-1)

      splitProblemName=origproblemname.split("_")
      counter = 0
      for word in splitProblemName: 
         string.join(word.split(), "")
         splitProblemName[counter] = word.strip()
         splitProblemName[counter] = word.strip("'")
         splitProblemName[counter] = word.strip("',\n")
         counter = counter + 1

      # get orginal problem name
      # it is assumed the month is in the name
      # baseProblemName=namelistContent[1].split("'")[1]
      # splitProblemName=baseProblemName.split("_")
      
      # find the month to start on
      for monthNumber in xrange(0,12,1):
         if startmonth == monthNames[monthNumber]:
            istartmonth=monthNumber

      monthId=istartmonth
      yearFlag=0
      currentYear=startyear
      restartYear=currentYear


      

      
      # will be used to make the namelists file
      listOfNamelists = []

      # for each namelist
      currentYear=str(int(startyear))

      for currentNameListCount in xrange(0,numNameLists,1):

         # open the file
         nfil=open(infil,"r")

         # flag for a new year (11->DEC
         if istartmonth == 11:
            yearFlag = 1

         if yearFlag == 1:
            restartYear=str(int(currentYear)+1)
            yearFlag=0

         if monthId == 0:
            restartYear=str(int(currentYear)-1)
         else:
            restartYear=str(int(currentYear))

         currentMonth = monthNames[monthId]
         metfilelist = '%s%s.list' % (currentMonth, currentYear)
         finaldays = daysPerMonth[monthId]
         if monthId < 9:
            strmonthId='0'+str(monthId+1)
         else:
            strmonthId=str(monthId+1)
         

         # create namelist variables
         if self.oneDay == 1:
            endymd = self.endDate
            startymd = self.startDate
         else:
            endymd = currentYear[0:4] + strmonthId + str(daysPerMonth[monthId])
            endymd = autoTool.incrementDate (endymd)
            if endymd[4:8] == "0229":
                newendymd = endymd[0:4]+"0301"
                endymd = newendymd
            
         startymd = currentYear[0:4] + strmonthId + '01'

         print "endymd: ", endymd

         problemName1 = splitProblemName[0].strip()
         problemName2 = splitProblemName[1].strip()

         restartName = problemName1 + '_' + problemName2 + \
             '_' + restartYear + '_'+ \
             monthNames[monthId-1]
         restartFileName = '%s.rst.nc' % (restartName)

         newProblemName = problemName1 + '_' + problemName2 + \
             '_' + currentYear + '_' + currentMonth

         directoryPath = '%s/' % (pathToNameList)
         dflag = os.path.exists(directoryPath)
         if dflag == 0:
            os.makedirs(directoryPath)

         listOfNamelists.append (newProblemName+".in")
         newProblemNameFullPath = '%s%s.in' % (directoryPath,newProblemName)
         ofil = open(newProblemNameFullPath,"w")

         
         if self.fortranNameList == "true":
            newProblemName = "'" + newProblemName + "'"
            metfilelist = "'" + metfilelist + "'"

         print "newProblemName: ", newProblemName


         # create new file
         for inline in nfil.readlines():

            # find the variable name / keyWord
            splitLine = inline.split()

            # skip if there are no items
            if len(splitLine) == 0:
               continue

            keyWord = splitLine[0]
            splitKeyWord = re.split(splitter, keyWord) 
            
            keyWord = splitKeyWord[0] 
            
            if len(splitLine) == 2:
                value = splitLine[1]
                


            if keyWord == 'problem_name':
               print "newProblemName: ", newProblemName
               ofil.write('problem_name' + splitter + newProblemName + endLine)
               
            elif keyWord == 'BEG_YY':
               print "BEG_YY: ", currentYear[0:4]
               ofil.write('BEG_YY' + splitter + currentYear[0:4] + endLine)
               
            elif keyWord == 'BEG_MM':
               print "BEG_MM: ", str(int(strmonthId))
               ofil.write('BEG_MM' + splitter + str(int(strmonthId)) + endLine)
               
            elif keyWord == 'BEG_DD':
               print "BEG_DD: 0"
               ofil.write('BEG_DD' + splitter + ' 1' + endLine)

            elif keyWord == 'BEG_H':
               print "BEG_H: 0"
               ofil.write('BEG_H' + splitter + ' 0' + endLine)

            elif keyWord == 'BEG_M':
               print "BEG_M: 0"
               ofil.write('BEG_M' + splitter + ' 0' + endLine)

            elif keyWord == 'BEG_S':
               print "BEG_S: 0"
               ofil.write('BEG_S' + splitter + ' 0' + endLine)

            elif keyWord == "END_YY":
               ofil.write('END_YY' + splitter + endymd[0:4] + endLine)
            
            elif keyWord == "END_MM":
               ofil.write('END_MM' + splitter + str(int(endymd[4:6])) + endLine)

            elif keyWord == "END_DD":
               ofil.write('END_DD' + splitter + str(int(endymd[6:8])) + endLine)

            elif keyWord == 'END_H':
               ofil.write('END_H' + splitter + ' 0' + endLine)

            elif keyWord == 'END_M':
               ofil.write('END_M' + splitter +  ' 0' + endLine)

            elif keyWord == 'END_S':
               ofil.write('END_S' + splitter + ' 0' + endLine)
            
            elif keyWord == 'met_filnam_list':
               ofil.write('met_filnam_list' + splitter + metfilelist + endLine)

            elif keyWord == 'restart_infile_name' and \
                   self.replaceRestartFile != 0:
               print "changing restart!" 
               ofil.write('restart_infile_name' + splitter + restartFileName + endLine)

            elif keyWord == 'forc_bc_start_num' and \
                    matchBcToYear == True:
                forcBcStartNum = int(startymd[0:4]) - int(initialYearForcBc)
                
                if forcBcStartNum < 0: 
                    print "forcBcStartNum cannot be less than 0!"
                    sys.exit (-1)
                    
                print "forcBcStartNum: ", forcBcStartNum
                ofil.write('forc_bc_start_num' + splitter + str(forcBcStartNum) + endLine)
                #ofil.write('forc_bc_start_num' + splitter + str(int(startymd[0:4]) - 1949) + endLine)

            elif keyWord == 'lightYearDim' and \
                    matchLightToYear == True:
                lightYearStartNum = int(startymd[0:4]) - int(initialYearLight)
                
                if lightYearStartNum < 0: 
                    print "lightYearStartNum cannot be less than 0!"
                    sys.exit (-1)
                
                print "lightYearStartNum: ", lightYearStartNum
                ofil.write('lightYearDim' + splitter + str(lightYearStartNum) + endLine)
                #ofil.write('lightYearDim' + splitter + str(int(startymd[0:4]) - 1989) + endLine)
            
            elif keyWord == 'lbssad_infile_name' and \
                    matchSadToYear == True:
                print "changing lbssad"
                splitLbssad = re.split("_", value)
                # 0 /discover/nobackup/projects/gmi/gmidata2/input/chemistry/surfareadens/CMIP6/sad_
                # 1 wt_
                # 2 CMIP6_
                # 3 1x72_
                # 4 2005.nc
                if len(splitLbssad) == 5:
                    print ("Found 5 lbssad tokens!")
                    newLbssad = splitLbssad[0] + "_" + splitLbssad[1] + "_" + splitLbssad[2] + "_" + \
                                splitLbssad[3]+ "_" + startymd[0:4] + ".nc"
                else:
                    newLbssad = splitLbssad[0] + "_" + splitLbssad[1] + "_" + splitLbssad[2] + "_" + startymd[0:4] + ".nc"
                ofil.write('lbssad_infile_name' + splitter + newLbssad + endLine)   

            elif keyWord == 'emiss_infile_name' and \
                    matchEmissToYear == True:
                splitEmiss = re.split("_", value) 
                newEmiss = splitEmiss[0] + "_" + startymd[0:4] + "_" + splitEmiss[2]+ "_" + splitEmiss[3] + "_" + splitEmiss[4]
                print "newEmiss: ", newEmiss
                ofil.write('emiss_infile_name' + splitter + newEmiss + endLine)

            # /discover/nobackup/projects/gmi/gmidata2/input/chemistry/aerodust/aerodust_MERRA2_1x1.25x72_20190101.nc
            elif keyWord == 'AerDust_infile_name' and \
                        matchAerToYear == True:

                print "Modified"
                splitAer = re.split("_", value)
                newAer = splitAer[0] + "_" + splitAer[1] + "_" + splitAer[2] + "_" + startymd[0:6] + "01.nc"
                print "newAer: ", newAer
                ofil.write('AerDust_infile_name' + splitter + newAer + endLine)


            elif keyWord == 'begGmiDate':
               ofil.write('begGmiDate' + splitter + currentYear + strmonthId \
                             + '01'  + endLine)

            elif keyWord == 'begGmiTime':
               ofil.write('begGmiTime' + splitter + '000000' + endLine)

            elif keyWord == 'endGmiDate':
               ofil.write('endGmiDate' + splitter + str(int(endymd[0:8])) + endLine)

            elif keyWord == 'endGmiTime':
               ofil.write('endGmiTime' + splitter + '000000' + endLine)

            elif keyWord == 'gmi_sec':
               ofil.write('gmi_sec' + splitter + self.gmiSeconds + endLine)
            
            elif keyWord == 'rd_restart' and \
                   self.replaceRestartFile != 0:
               ofil.write('rd_restart' + splitter + 'T' + endLine) 

            else:
               data=inline.replace('\r','') #Removes ^M character from strings written
               ofil.write(data)


 
         
         intYear = int (currentYear)
         monthId = monthId + 1
         if monthId == 12:
            currentYear = str (intYear + 1)
            monthId = 0
         
      
      ioObject.writeToFile (listOfNamelists,pathToNameList+"/namelists.list")


      
      if int(currentYear)% 4 == 0 and monthId == 2:
         print "leap year!"
         daysInMonth = 29
      else:
         daysInMonth = int(daysPerMonth[monthId-1])

      gmiSeconds = int(self.gmiSeconds) + (daysInMonth * 24 * 3600)
      # write new gmiSeconds to file
      ioObject.writeToFile (["export gmi_sec=" + str(gmiSeconds)], self.envFile)

      
      for nameList in listOfNamelists:
         print nameList
 
