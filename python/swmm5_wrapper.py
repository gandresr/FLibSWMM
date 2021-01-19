import math, re # Used to create .rpt and .out paths
import six
import platform

from ctypes import c_double, CDLL, c_void_p, c_float, pointer, c_char_p # Required to handle with DLL variable
import os
from time import time # Required to get computational times.

# ------------------------ CONSTANTS ---------------------------

# Types of objects
JUNCTION = 0
SUBCATCH = 1
NODE = 2
LINK = 3
STORAGE = 4

# Node Subtypes
ORIFICE = 414
OUTFALL = 417

# Unit system
US = 0
SI = 1
DIMENSIONLESS = 0

# Attributes
DEPTH = 200			# [LINK] && [NODE]
VOLUME = 201		# [LINK] && [NODE]
FLOW = 202			# [LINK]
SETTING = 203		# [LINK]
FROUDE = 204		# [LINK]
INFLOW = 205		# [NODE]
FLOODING = 206		# [NODE]
PRECIPITATION = 207	# [SUBCATCHMENT]
RUNOFF = 208		# [SUBCATCHMENT]
LINK_AREA = 209		# [LINK]

# Start options
NO_REPORT = 0
WRITE_REPORT = 1

# Input file constants
INVERT = 400		# [NODE]
DEPTH_SIZE = 401	# [LINK] [NODE]
STORAGE_A = 402		# [NODE]
STORAGE_B = 403		# [NODE]
STORAGE_C = 404		# [NODE]
LENGTH = 405		# [LINK]
ROUGHNESS = 406		# [LINK]
IN_OFFSET = 407		# [LINK]
OUT_OFFSET = 408	# [LINK]
AREA = 409			# [SUBCATCHMENTS]
IMPERV = 410		# [SUBCATCHMENTS]
WIDTH = 411			# [SUBCATCHMENTS]
SLOPE = 412			# [SUBCATCHMENTS]
OUTLET = 413		# [SUBCATCHMENTS]
FROM_NODE = 415		# [LINK]
TO_NODE = 416		# [LINK]

# ------------------- GLOBAL PRIVATE CONSTANTS -----------------

_ERROR_PATH = -300
_ERROR_ATR = -299
_ERROR_TYPE = -298
_ERROR_NFOUND = -297
_ERROR_INCOHERENT = -296
_ERROR_IS_NUMERIC = -295
_ERROR_INVALID_TOPOLOGY = -400
_ERROR_SYS = -500

_ERROR_MSG_NFOUND = AttributeError("Error: Object not found")
_ERROR_MSG_TYPE = AttributeError("Error: Type of object not compatible")
_ERROR_MSG_ATR = AttributeError("Error: Attribute not compatible")
_ERROR_MSG_PATH = AttributeError("Error: Incorrect file path")
_ERROR_MSG_INCOHERENT = TypeError("Error: Incoherent parameter")
_ERROR_MSG_IS_NUMERIC = TypeError("Error: This function just handle numerical attributes")
_ERROR_MSG_INVALID_TOPOLOGY = AttributeError("Error: Invalid network, a node can have 3 upstream and 3 downstream links at most")
_ERROR_MSG_SYS = SystemError("Error: The system crashed, check the API")

# ------------------- GLOBAL PRIVATE VARIABLES -----------------

if platform.system() == 'Windows':
	libpath =  'libswmm5.dll'
else:
	libpath =  'libswmm5.so'

_SWMM5 = CDLL(os.path.join(os.getcwd(),libpath)) # C library
_SWMM5.api_initialize.restype = c_void_p
_api = c_void_p()
_elapsedTime = c_double(0.000001) # Elapsed time in decimal days
_ptrTime = pointer( _elapsedTime ) # Pointer to elapsed time
_start_time = time() # Simulation start time
_end_time = time() # Simulation end time
_type_constants = (JUNCTION, SUBCATCH, NODE, LINK, STORAGE, ORIFICE, OUTFALL,)
_unit_constants = (US, SI, DIMENSIONLESS, )
_attribute_constants = (DEPTH, VOLUME, FLOW, SETTING, FROUDE, INFLOW, FLOODING, PRECIPITATION, RUNOFF, LINK_AREA,)
_report_constants = (NO_REPORT, WRITE_REPORT,)
_input_file_constants = (INVERT, DEPTH_SIZE, STORAGE_A, STORAGE_B, STORAGE_C, LENGTH, ROUGHNESS, IN_OFFSET, OUT_OFFSET,
						AREA, IMPERV, WIDTH, SLOPE, OUTLET, FROM_NODE, TO_NODE,)

DEBUG = True

# --- Simulation

def initialize(inp):
	global _api
	# Creates paths for the report and the output files
	rpt = inp.replace('.inp', '.rpt')
	out = inp.replace('.inp', '.out')
	_api = _SWMM5.api_initialize(c_char_p(six.b(inp)), c_char_p(six.b(rpt)), c_char_p(six.b(out))) # Step 1

def finalize():
	_SWMM5.api_finalize(_api)

def run_step():

	'''
	Inputs:  None
	Outputs: None
	Purpose: advances the simulation by one routing time step. Raise Exception
			 if there is an error.
	'''

	error = _SWMM5.swmm_step(_ptrTime)
	if (error != 0):
		raise SystemError ("Error %d ocurred at time %.2f" % (error, _elapsedTime.value))
	return _elapsedTime.value

def is_over():
	'''
	Inputs: None
	Outputs: _ (Bool) -> True if the simulation is over, False otherwise
	Purpose: determines if the simulation is over or not.
	'''
	return _elapsedTime.value == 0.0

def get_time():
	'''
	Inputs: None
	Outputs: _ (float) -> Value of the current time of the simulation in hours.
	Purpose: returns the current hour of the simulation.
	'''
	return _elapsedTime.value*24

def save_report(msg=False):

	'''
	Inputs:  msg (Bool)-> Display message in the terminal if True.
	Outputs: None
	Purpose: writes simulation results to report file. Raise Exception if there is an error.
	'''

	error = _SWMM5.swmm_report()

	if (error != 0):
		raise SystemError ("Error %d: The report file could not be written correctly" % error)
	if DEBUG:
		print( ("Report file correctly written!"))

def get_mass_bal_error():

	'''
	Inputs: None.
	Outputs: _ (tuple) -> Values of the errors related to mass balance.
			 			  [0] -> Runoff error
			 			  [1] -> Flow error
			 			  [2] -> Quality error
	Purpose: gets the mass balance errors of the simulation.
	'''

	runOffErr = c_float(0)
	flowErr = c_float(0)
	qualErr = c_float(0)
	ptrRunoff = pointer(runOffErr)
	ptrFlow = pointer(flowErr)
	ptrQual = pointer(qualErr)

	error = _SWMM5.swmm_getMassBalErr(ptrRunoff, ptrFlow, ptrQual)
	if (error != 0):
		raise SystemError ("Error %d: The errors can not be retrieved" % error)

	return (runOffErr.value, flowErr.value, qualErr.value)

# --- Property-extraction

# * During Simulation

def get_node_results(nodes):
	inflows = []
	overflows = []
	depths = []
	volumes = []

	for node in nodes:
		inflow = c_float(0)
		overflow = c_float(0)
		depth = c_float(0)
		volume = c_float(0)

		ptr_inflow = pointer(inflow)
		ptr_overflow = pointer(overflow)
		ptr_depth = pointer(depth)
		ptr_volume = pointer(volume)
		_SWMM5.api_get_node_results(
			_api,
			c_char_p(six.b(node)),
			ptr_inflow,
			ptr_overflow,
			ptr_depth,
			ptr_volume)

		inflows.append(inflow.value)
		overflows.append(overflow.value)
		depths.append(depth.value)
		volumes.append(volume.value)
	return inflows, overflows, depths, volumes

def get_link_results(links):
	flows = []
	depths = []
	volumes = []

	for link in links:
		flow = c_float(0)
		depth = c_float(0)
		volume = c_float(0)

		ptr_flow = pointer(flow)
		ptr_depth = pointer(depth)
		ptr_volume = pointer(volume)
		_SWMM5.api_get_link_results(
			_api,
			c_char_p(six.b(link)),
			ptr_flow,
			ptr_depth,
			ptr_volume)

		flows.append(flow.value)
		depths.append(depth.value)
		volumes.append(volume.value)
	return flows, depths, volumes

# * After Initialization

def get_node_attribute(nodes, attr):
	values = np.zeros(len(nodes))
	value = c_double(0.0) # Elapsed time in decimal days
	ptr_value = pointer( value )
	for i, node in enumerate(nodes):
		j = find_object(NODE, node)
		error = _SWMM5.api_get_node_attribute(_api, j, attr, ptr_value)
		if error != 0:
			raise Exception(f"ERROR CODE [{error}]")
		values[i] = value.value
	return values

def get_link_attribute(links, attr):
	values = np.zeros(len(links))
	value = c_double(0.0) # Elapsed time in decimal days
	ptr_value = pointer( value )
	for i, link in enumerate(links):
		j = find_object(LINK, link)
		error = _SWMM5.api_get_link_attribute(_api, j, attr, ptr_value)
		if error != 0:
			raise Exception(f"ERROR CODE [{error}]")
		values[i] = value.value
	return values

def get_num_objects(obj_type):
	return _SWMM5.api_get_num_objects(_api, obj_type)

# --- Print-out

def export_linknode_properties(inp, units):

	'''
	Inputs:  inp (str) -> Path to the input file .inp
			 units (int) -> unit system (US, SI)
	Outputs: None
	Purpose: creates CSV files with information for SWMM6 FORTRAN engine

	Creates two files:

		node_properties.csv
			(int) n_left: number of nodes left in the list
				(the first row tells the total number of nodes)
			(string) node_id: id of the node
			(int) ni_idx: index of the node in SWMM's data structure for nodes
			(int) ni_node_type: code for node type according to SWMM
				(0) JUNCTION
				(1) OUTFALL
				(2) STORAGE
				(3) DIVIDER
			(int) ni_N_link_u: number of links connected upstream to the node
			(int) ni_N_link_d: number of links connected downstream to the node
			(int) ni_Mlink_u1: id of first link connected upstream to the node
			(int) ni_Mlink_u2: id of second link connected upstream to the node
			(int) ni_Mlink_u3: id of thrid link connected upstream to the node
			(int) ni_Mlink_d1: id of first link connected downstream to the node
			(int) ni_Mlink_d2: id of second link connected downstream to the node
			(int) ni_Mlink_d3: id of third link connected downstream to the node

		link_properties.csv
			(int) l_left: number of links left in the list
			(string) link_id
			(int) li_idx
			(int) li_link_type
			(int) li_geometry
			(int) li_Mnode_u
			(int) li_Mnode_d
			(float) lr_Length: length of the link (0 if type != CONDUIT)
			(float) lr_Slope: average slope of the link, estimated with extreme points
			(float) lr_Roughness: Manning coefficient of the link (0 if type != CONDUIT)
			(float) lr_InitialFlowrate: initial flow rate
			(float) lr_InitialUpstreamDepth: initial upstream depth
			(float) lr_InitialDnstreamDepth: initial downstream depth
	'''

	open_file(inp)  # Step 1
	start(WRITE_REPORT)  # Step 2
	error = _SWMM5.api_export_linknode_properties(_api, units)
	if (error == _ERROR_INVALID_TOPOLOGY):
		raise(_ERROR_MSG_INVALID_TOPOLOGY)
	elif (error == _ERROR_INCOHERENT):
		raise(_ERROR_MSG_INCOHERENT)
	elif (error == _ERROR_SYS):
		raise(_ERROR_MSG_SYS)
	if DEBUG:
		print ("\nPrinting FORTRAN file -  OK")

def export_link_results(link_id):
	_SWMM5.interface_save_link_results(_api, c_char_p(six.b(link_id)))

def export_node_results(node_id):
	_SWMM5.interface_save_node_results(_api, c_char_p(six.b(node_id)))

# --- Tests

def find_object(obj_type, obj_name):
	return _SWMM5.api_findObject(obj_type, c_char_p(six.b(obj_name)))

def print_inflow(node_id):
	_SWMM5.interface_print_inflow(c_char_p(six.b(node_id)))