import swmm5_wrapper as swmm5
import os

swmm5.initialize('tanks.inp')
while not swmm5.is_over():
    swmm5.run_step()

# --- Save CSV reports ---
swmm5.save_node_results('N-5')
swmm5.save_link_results('C-1')

errors = swmm5.finish()