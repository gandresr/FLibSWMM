#define UPSTREAM 0
#define DOWNSTREAM 1
#define SSIGN(X) (X > 0) - (X < 0)
#define CFTOCM(m) m*0.0283168466 // Cubic feet to cubic meters
#define FT2TOM2(m) m*0.09290304 // Square feet to square meters
#define FTTOM(m) m*0.3048 // Feet to meters
#define nullvalueI -998877

#ifndef INTERFACE_H
#define INTERFACE_H

// --- define WINDOWS

#undef WINDOWS
#ifdef _WIN32
  #define WINDOWS
#endif
#ifdef __WIN32__
  #define WINDOWS
#endif

// --- define DLLEXPORT

#ifdef WINDOWS
    #define DLLEXPORT __declspec(dllexport) __stdcall
#else
    #define DLLEXPORT
#endif

// --- use "C" linkage for C++ programs

#ifdef __cplusplus
extern "C" {
#endif

int DLLEXPORT add_link(int li_idx, int ni_idx, int direction, int* ni_N_link_u, int* ni_Mlink_u1, int* ni_Mlink_u2, int* ni_Mlink_u3, int* ni_N_link_d, int* ni_Mlink_d1, int* ni_Mlink_d2, int* ni_Mlink_d3);
int DLLEXPORT interface_print_info(int units);
void DLLEXPORT interface_save_link_results(char* link_name);
void DLLEXPORT interface_save_node_results(char* node_name);
void DLLEXPORT interface_print_inflow(char* node_name);
void DLLEXPORT interface_get_node_results(char* node_name, float* inflow, float* overflow, float* depth, float* volume);
void DLLEXPORT interface_get_link_results(char* link_name, float* flow, float* depth, float* volume);

#ifdef __cplusplus
}   // matches the linkage specification from above */
#endif

#endif
