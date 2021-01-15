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


#define nullvalue -998877022E8
#define NUM_API_VARS 2
#define NUM_API_TABLES 1

enum api_node_attributes {
  node_ID = 1,
  node_type,
  node_invertElev,
  node_initDepth,
  node_extInflow_tSeries,
  node_extInflow_basePat,
  node_extInflow_baseline,
  node_depth,
  node_inflow,
  node_volume,
  node_overflow
};

enum api_link_attributes {
  link_ID = 1,
  link_subIndex,
  link_type,
  link_node1,
  link_node2,
  link_xsect_type,
  link_xsect_wMax,
  link_xsect_yBot,
  link_q0,
  link_geometry,
  conduit_roughness,
  conduit_length,
  link_flow,
  link_depth,
  link_volume,
  link_froude,
  link_setting,
  link_left_slope,
  link_right_slope
};

// API vars are those necessary for external applications
//   but have not been stored in the original SWMM data structures
//   These variables are found in the input file but are either
//   discarded or summarized
enum api_vars {
  api_left_slope,
  api_right_slope,
};

enum api_tables {
  api_time_series
};

typedef struct {
  int IsInitialized;
  double elapsedTime;
  double* vars[NUM_API_VARS];
} Interface;

// --- use "C" linkage for C++ programs

#ifdef __cplusplus
extern "C" {
#endif

// --- Simulation

void* DLLEXPORT api_initialize(char* f1, char* f2, char* f3);
void DLLEXPORT api_finalize(void* f_api);

// --- Property-extraction

// * During Simulation

int DLLEXPORT api_get_node_results(void* f_api, char* node_name, float* inflow, float* overflow, float* depth, float* volume);
int DLLEXPORT api_get_link_results(void* f_api, char* link_name, float* flow, float* depth, float* volume);

// * After Initialization

int DLLEXPORT api_get_node_attribute(void* f_api, int k, int attr, double* value);
int DLLEXPORT api_get_link_attribute(void* f_api, int k, int attr, double* value);
int DLLEXPORT api_get_num_objects(void* f_api, int object_type);

// --- Print-out

int add_link(int li_idx, int ni_idx, int direction, int* ni_N_link_u, int* ni_Mlink_u1, int* ni_Mlink_u2, int* ni_Mlink_u3, int* ni_N_link_d, int* ni_Mlink_d1, int* ni_Mlink_d2, int* ni_Mlink_d3);
int DLLEXPORT interface_export_linknode_properties(void* f_api, int units);
int DLLEXPORT interface_export_link_results(void* f_api, char* link_name);
int DLLEXPORT interface_export_node_results(void* f_api, char* node_name);

// --- Utils

int check_api_is_initialized(Interface* api);
int api_load_vars(void * f_api);
int getTokens(char *s);
int api_findObject(int type, char *id);

#ifdef __cplusplus
}   // matches the linkage specification from above */
#endif

#endif