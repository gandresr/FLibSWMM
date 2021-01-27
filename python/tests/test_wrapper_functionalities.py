import swmm5_wrapper as swmm5
import os
from pprint import pprint
from collections import defaultdict as ddict
import pickle

SWMM = swmm5.SWMM5()
fpath = os.path.join('/swmm_files/tanks.inp')
SWMM.initialize(fpath)
SWMM.finalize()
