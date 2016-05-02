# Load abaqus modules
from part import *
from material import *
from section import *
from assembly import *
from step import *
from interaction import *
from load import *
from mesh import *
from optimization import *
from job import *
from sketch import *
from visualization import *
from connectorBehavior import *
from abaqus import *
from abaqusConstants import *
import os
import datetime
import shutil
from odbAccess import *
import time


# Load MATLAB assigned variables
execfile('runJobVar.py')

curDir = os.getcwd()
if os.path.isdir(workDir)==False:
	os.mkdir(workDir)

mdb.JobFromInputFile(activateLoadBalancing=False, atTime=None, explicitPrecision=SINGLE, getMemoryFromAnalysis=True, inputFileName=inpPath, memory=RAM, memoryUnits=GIGA_BYTES, multiprocessingMode=DEFAULT, name=dataName, nodalOutputPrecision=SINGLE, numCpus=4, numDomains=4, parallelizationMethodExplicit=DOMAIN, queue=None, scratch='',type=ANALYSIS, userSubroutine='', waitHours=0, waitMinutes=0)

os.chdir(workDir)
try:
	mdb.jobs[dataName].submit(consistencyChecking=OFF)
	mdb.jobs[dataName].waitForCompletion()
except: pass
os.chdir(curDir)


