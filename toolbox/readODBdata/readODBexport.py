### ReadODBexport.py
## Reads the output 'odb' from an abaqus simulation
## Accesses node/element sets, and field outputs
## Exports values to space-delimited text
##
## !!!!!!!!! COORD field output must be included in the simulation !!!!!!!!
## 
## ver info:
## - limited to Std/Explicit models
## - supported field outputs: COORD, U, LE, S
## - 3D only - tet element
##
## version: 1.0.0
## date: 2016-05-02
## 
## author: Philip Wijesinghe
## email: philip.wijesinghe@gmail.com
## 

# Load MATLAB assigned variables
# must inlcude filepath, filename, instance, step, frame
execfile('var.py')
### USER INPUT ###
# Location of 'odb' - leave empty string for default work directory
odbDir = filepath
# Name of 'odb' file
name_odb = filename
# Output name
name_out = filename+'_out'

# Enter the names of all instances to output
# Names can be found in the Abaqus CAE GUI
# Will comprehensively output all field outputs for all node/elem in each instance
name_instance = []
# name_instance.append('PARTLAYER-1')
name_instance.append(instance)

# Enter names of element and node sets to output (include associated instance name)
# Will output element connectivity or node ids 
name_elset_instance = []
name_elementset = []
# name_elset_instance.append('PARTSAMPLE-1')
# name_elementset.append('SAMPLETOPSET')

name_nset_instance = []
name_nodeset = []
# name_nset_instance.append('PARTSAMPLE-1')
# name_nodeset.append('SAMPLETOPSET')

# Enter step names and frame numbers to output
# Negative frame number counts from the back
# i.e., frame -1 is the last frame
name_step = []
num_frame = []
name_step.append(step)
num_frame.append(frame)


# Field outputs to export
# - currently empty - export all

### END USER INPUT ###



### MAIN SCRIPT START ###
## Load abaqus modules
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

## Load odb file
if not odbDir:
	odbDir = os.getcwd()

odb = openOdb(path=odbDir+'/'+name_odb+'.odb')

## Create temporary output directory if required
if not os.path.exists(odbDir+'\\readODBexport\\'+name_out):
	os.makedirs(odbDir+'\\readODBexport\\'+name_out)

## for step and frame
for fout in range(len(name_step)):
	# load all field outputs in specified frame
	frame_obj = odb.steps[name_step[fout]].frames[num_frame[fout]]
	COORD = frame_obj.fieldOutputs['COORD']
	S = frame_obj.fieldOutputs['S']
	LE = frame_obj.fieldOutputs['LE']
	U = frame_obj.fieldOutputs['U']
	# for instance
	for inst in range(len(name_instance)):
		# specify relevant node/elem region
		reg = odb.rootAssembly.instances[name_instance[inst]]
		localCOORD = COORD.getSubset(region = reg)
		localS = S.getSubset(region = reg)
		localLE = LE.getSubset(region = reg)
		localU = U.getSubset(region = reg)
		# output to a text file
		tf_COORD = open(odbDir+'\\readODBexport\\'+name_out+'\\'+name_out+'_'+name_step[fout]+'_'+str(num_frame[fout])+'_'+name_instance[inst]+'_COORD.txt','w')
		tf_S = open(odbDir+'\\readODBexport\\'+name_out+'\\'+name_out+'_'+name_step[fout]+'_'+str(num_frame[fout])+'_'+name_instance[inst]+'_S.txt','w')
		tf_LE = open(odbDir+'\\readODBexport\\'+name_out+'\\'+name_out+'_'+name_step[fout]+'_'+str(num_frame[fout])+'_'+name_instance[inst]+'_LE.txt','w')
		tf_U = open(odbDir+'\\readODBexport\\'+name_out+'\\'+name_out+'_'+name_step[fout]+'_'+str(num_frame[fout])+'_'+name_instance[inst]+'_U.txt','w')
		tf_elset = open(odbDir+'\\readODBexport\\'+name_out+'\\'+name_out+'_'+name_step[fout]+'_'+str(num_frame[fout])+'_'+name_instance[inst]+'_EL.txt','w')
		nelcon = len(reg.elements[0].connectivity)
		for ii in range(len(localCOORD.values)):
			COORD_N = localCOORD.values[ii].data
			COORD_L = localCOORD.values[ii].nodeLabel
			tf_COORD.write('%d %1.10f %1.10f %1.10f\n' % (COORD_L,COORD_N[0],COORD_N[1],COORD_N[2]))
		for ii in range(len(localS.values)):
			S_tens = localS.values[ii].data
			S_elem = localS.values[ii].elementLabel
			tf_S.write('%d %1.10f %1.10f %1.10f %1.10f %1.10f %1.10f %d\n' % (S_elem,S_tens[0],S_tens[1],S_tens[2],S_tens[3],S_tens[4],S_tens[5], localS.values[ii].integrationPoint))
		for ii in range(len(localLE.values)):
			LE_tens = localLE.values[ii].data
			LE_elem = localLE.values[ii].elementLabel
			tf_LE.write('%d %1.10f %1.10f %1.10f %1.10f %1.10f %1.10f %d\n' % (LE_elem,LE_tens[0],LE_tens[1],LE_tens[2],LE_tens[3],LE_tens[4],LE_tens[5],localLE.values[ii].integrationPoint))
		for ii in range(len(localU.values)):
			U_vec = localU.values[ii].data
			U_node = localU.values[ii].nodeLabel
			tf_U.write('%d %1.10f %1.10f %1.10f\n' % (U_node,U_vec[0],U_vec[1],U_vec[2]))
		for ii in range(len(reg.elements)):
			el_lab = reg.elements[ii].label
			el_con = reg.elements[ii].connectivity
			if nelcon == 4:
				tf_elset.write('%d %d %d %d %d\n' % (el_lab,el_con[0],el_con[1],el_con[2],el_con[3]))
			if nelcon == 8:
				tf_elset.write('%d %d %d %d %d %d %d %d %d\n' % (el_lab,el_con[0],el_con[1],el_con[2],el_con[3],el_con[4],el_con[5],el_con[6],el_con[7]))
			if nelcon == 10:
				tf_elset.write('%d %d %d %d %d %d %d %d %d %d %d\n' % (el_lab,el_con[0],el_con[1],el_con[2],el_con[3],el_con[4],el_con[5],el_con[6],el_con[7],el_con[8],el_con[9]))

		# close handles
		tf_COORD.close()
		tf_S.close()
		tf_LE.close()
		tf_U.close()
		tf_elset.close()




## for element set
if name_elementset:
	for n_elset in range(len(name_elementset)):
		elset_obj = odb.rootAssembly.instances[name_elset_instance[n_elset]].elementSets[name_elementset[n_elset]]
		# write to text
		tf_elset = open(odbDir+'\\readODBexport\\'+'name_out\\'+name_out+'_'+name_elset_instance[n_elset]+'_'+name_elementset[n_elset]+'_elset.txt','w')
		for ii in range(len(elset_obj.elements)):
			el_lab = elset_obj.elements[ii].label
			el_con = elset_obj.elements[ii].connectivity
			tf_elset.write('%d %d %d %d %d\n' % (el_lab,el_con[0],el_con[1],el_con[2],el_con[3]))
		tf_elset.close()




if name_nodeset:
	for n_nset in range(len(name_nodeset)):
		nset_obj = odb.rootAssembly.instances[name_nset_instance[n_nset]].nodeSets[name_nodeset[n_nset]]
		# write to text
		tf_nset = open(odbDir+'\\readODBexport\\'+'name_out\\'+name_out+'_'+name_nset_instance[n_nset]+'_'+name_nodeset[n_nset]+'_nset.txt','w')
		for ii in range(len(elset_obj.elements)):
			n_lab = elset_obj.elements[ii].label
			tf_nset.write('%d\n' % (n_lab))
		tf_nset.close()







# output element connectivity

## for node set

# output nodes



