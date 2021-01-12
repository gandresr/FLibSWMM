import swmm5_wrapper as swmm5
import os
from pprint import pprint
from collections import defaultdict as ddict
import pickle

swmm5.initialize('/home/griano/Documents/Github/SWMMwrapper/swmm_files/tanks.inp')
nodes = ['N-5', 'N-6']
links = ['C-1', 'C-2']

node_results = {n : ddict(list) for n in nodes}
link_results = {l : ddict(list) for l in links}
time = []

while not swmm5.is_over():
    elapsed = swmm5.run_step() * 24
    if not elapsed == 0:
        decimal = elapsed - int(elapsed)
        if decimal < 0.001:
            time.append(elapsed)
            inflows, overflows, depths, volumes = swmm5.get_node_data(nodes)
            for i, node in enumerate(nodes):
                node_results[node]['inflow'].append(inflows[i])
                node_results[node]['overflow'].append(overflows[i])
                node_results[node]['depth'].append(depths[i])
                node_results[node]['volume'].append(volumes[i])
            inflows, volumes, depths  = swmm5.get_link_data(links)
            for i, link in enumerate(links):
                link_results[link]['flow'].append(inflows[i])
                link_results[link]['volume'].append(volumes[i])
                link_results[link]['depth'].append(depths[i])


with open('node_results.pkl', 'wb') as f:
    pickle.dump({'time': time, 'node_results' : node_results}, f)

with open('link_results.pkl', 'wb') as f:
    pickle.dump({'time': time, 'link_results' : link_results}, f)
# --- Save CSV reports ---
# swmm5.save_node_results('3125220_0')
#swmm5.save_link_results('8748')

errors = swmm5.finish()
