import swmm5_wrapper as swmm5
import os
from pprint import pprint
from collections import defaultdict as ddict
import pickle

SWMM = swmm5.SWMM5()
SWMM.initialize('/home/griano/Documents/Github/SWMMwrapper/swmm_files/block.inp')
num_nodes = SWMM.get_num_objects(swmm5.NODE)
SWMM.finalize()