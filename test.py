import swmm5_wrapper as swmm5
import os

swmm5.initialize('swmm_files/Brazos_SWMM12082020/Brazos_Simple_Geometry.inp')
while not swmm5.is_over():
    elapsed = swmm5.run_step()
    elapsed = int(elapsed * 24 * 60)
    if elapsed % 30 == 0:
        print(f"Elapsed time: {elapsed} minutes")


# --- Save CSV reports ---
swmm5.save_node_results('3125220_0')
#swmm5.save_link_results('8748')

errors = swmm5.finish()
