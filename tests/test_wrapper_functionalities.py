import swmm5_wrapper as swmm5
import os
from pprint import pprint
from collections import defaultdict as ddict
import pickle

fpath = os.path.join('swmm_files', 'tanks.inp')
swmm5.initialize(fpath)


