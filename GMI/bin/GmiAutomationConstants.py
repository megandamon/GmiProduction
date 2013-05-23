#!/usr/bin/env python

#------------------------------------------------------------------------------
# NASA/GSFC, Software Integration & Visualization Office, Code 610.3
#------------------------------------------------------------------------------
# AUTHORS:      Megan Damon
# AFFILIATION:  NASA GSFC / NGIT / TASC
# DATE:         November 7th 2006
#
# DESCRIPTION:
# This class contains constants for the Gmi Automation process.
#------------------------------------------------------------------------------

class GmiAutomationConstants:
   
   # TODO_make these static
   ERROR = "ERROR"
   NOERROR = "NOERROR"
   NOSUCHFILE = "NOSUCHFILE"
   READERROR = "READERROR"
   WRITEERROR = "WRITEERROR"
   BADFILENAME = "BADFILENAME"
   INCORRECTNUMBEROFFILES = "INCORRECTNUMBEROFFILES"
   BADSYSTEMRETURNCODE = "BADSYSTEMRETURNCODE"
   INCOMPLETEFILE = "INCOMPLETEFILE"
   INVALIDINPUT = "INVALIDINPUT"
   INVALIDPATTERN = "INVALIDPATTERN"
   INVALIDFILENAMES = "INVALIDFILENAMES"
   INCOMPLETEDATA = "INCOMPLETEDATA"
   NOSUCHPATH = "NOSUCHPATH"
   FILEALREADYEXISTS = "FILEALREADYEXISTS"
   JOBINQUEUE = "JOBINQUEUE"
   JOBNOTINQUEUE = "JOBNOTINQUEUE"
   NOTVALIDRUN = "NOTVALIDRUN"
   VALIDRUN = "VALIDRUN"
   INCOMPLETEDATASET = "INCOMPLETEDATASET"
   
   # this is where files will be stored during the duration of the file processing (not science data)
   DEFAULTRUNPATH = "/discover/nobackup/mrdamon/Devel/RestartGmi/ChainRuns/"
   
   # root directory where metfields are computed
   # it is assumed there are sub directories, such as "DAS" and "Forecast"
   DEFAULTMETFIELDPATH = "/nobackup/mrdamon/GmiMetFields/"
   
   # root directory where metfields are archived
   ARCHIVEMETFIELDPATH = "/g2/mrdamon/GmiMetFields/"
   
   # this is where logs will be stored
   # note: these logs should be shared among all GMI scientists/programmers
   DEFAULTLOGPATH = DEFAULTRUNPATH + "Logs/"
   
   # email address where important messages should be sent to
   MAILTO = "Megan.R.Damon.1@gsfc.nasa.gov"
   
   # binary paths
   MKDIRPATH = "/bin/"
   RMPATH = "/bin/"
   MVPATH = "/bin/"
   CPPATH = "/bin/"
   GREPPATH = "/usr/bin/"
   AWKPATH = "/usr/bin/"
   NCATTEDPATH = "/local/LinuxIA64/nco/3.1.1/bin/"
   NCKSPATH = "/local/LinuxIA64/nco/3.1.1/bin/"
   NCAPPATH = "/local/LinuxIA64/nco/3.1.1/bin/"
   HDFDUMPPATH = ""
   NCRENAMEPATH = "/local/LinuxIA64/nco/3.1.1/bin/"
   NCEAPATH = "/local/LinuxIA64/nco/3.1.1/bin/"
   NCRCATPATH = "/local/LinuxIA64/nco/3.1.1/bin/"
   NCREGRIDPATH = "/local/LinuxIA64/ncregrid/ncregrid/bin/"
   NCKSPATH = "/local/LinuxIA64/nco/3.1.1/bin/"
   MAILPATH = "/usr/bin/"
   DATEPATH = "/bin/"
   QSUBPATH = "/usr/pbs/bin/"
   QSTATPATH = "/usr/pbs/bin/"
   INCRDATEPATH = ""
   
   MAXPBSJOBNAMELENGTH = 15
      
   SPECIALFORECASTINPUTFILENAME = DEFAULTRUNPATH + "SpecialForecastFile.txt"
   SPECIALDASINPUTFILENAME = DEFAULTRUNPATH + "SpecialDasFile.txt"
   
   
   DEFAULTATTEMPTEDDASFILENAME = DEFAULTRUNPATH + "AttemptedDasFile.txt"
   DEFAULTARETHESEDASTASKSCOMPLETEFILENAME = DEFAULTRUNPATH + "AreTheseDasTasksComplete.txt"
   DEFAULTDASLOGFILENAME = DEFAULTLOGPATH + "DasLog.txt"
   DEFAULTFORECASTLOGFILENAME = DEFAULTLOGPATH + "ForecastLog.txt"
   DEFAULTFORECASTSOURCEPATH = "/dao_ops/dao_ops/GEOS-4.0.3/a_flk_04/forecast/"
   DEFAULTFORECASTDESTINATIONPATH = DEFAULTMETFIELDPATH + "FORECAST/"
   DEFAULTDASDESTINATIONPATH = DEFAULTMETFIELDPATH + "DAS/"
   DEFAULTDASSOURCEPATH = "/dao_ops/dao_ops/GEOS-4.0.3/a_llk_04/"
   DEFAULTDASINPUTPATH = DEFAULTRUNPATH + "DasInput/"
   DEFAULTDASARCHIVEMETFIELDPATH = ARCHIVEMETFIELDPATH + "DAS/"
   
   INSTANTSURFACEDAS = "instantaneous surface das"
   AVERAGEDSURFACEDAS = "averaged surface das"
   AVERAGEDETADAS = "averaged eta das"
   
   
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
   # Destructor routine.
   #---------------------------------------------------------------------------    
   
   def __del__(self):
      pass
