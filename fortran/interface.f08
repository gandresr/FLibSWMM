module interface

    use iso_c_binding
    use dll_mod
    ! use data_keys ! (comment if debugging)
    implicit none

    public

    ! interface to C DLL
    abstract interface

        ! --- Simulation

        function api_initialize(inp_file, report_file, out_file)
            use, intrinsic :: iso_c_binding
            implicit none
            character(c_char), dimension(*) :: inp_file
            character(c_char), dimension(*) :: report_file
            character(c_char), dimension(*) :: out_file
            type(c_ptr) :: api_initialize
        end function api_initialize

        subroutine api_finalize(api)
            use, intrinsic :: iso_c_binding
            implicit none
            type(c_ptr), value, intent(in) :: api
        end subroutine api_finalize

        ! --- Property-extraction

        ! * After Initialization

        function api_get_node_attribute(api, k, attr, value)
            use, intrinsic :: iso_c_binding
            implicit none
            type(c_ptr), value, intent(in) :: api
            integer(c_int), value :: k
            integer(c_int), value :: attr
            type(c_ptr), value, intent(in) :: value
            integer(c_int) :: api_get_node_attribute
        end function api_get_node_attribute

        function api_get_link_attribute(api, k, attr, value)
            use, intrinsic :: iso_c_binding
            implicit none
            type(c_ptr), value, intent(in) :: api
            integer(c_int), value :: k
            integer(c_int), value :: attr
            type(c_ptr), value, intent(in) :: value
            integer(c_int) :: api_get_link_attribute
        end function api_get_link_attribute

        function api_get_num_objects(api, obj_type)
            use, intrinsic :: iso_c_binding
            implicit none
            type(c_ptr), value, intent(in) :: api
            integer(c_int), value :: obj_type
            integer(c_int) :: api_get_num_objects
        end function api_get_num_objects

    end interface

    character(len = 1024), private :: errmsg
    integer, private :: errstat
    integer, private :: debuglevel = 0
    integer, private :: debuglevelall = 0
    type(dll_type), private :: dll
    type(os_type) :: os
    type(c_ptr) :: api

    ! Error codes
    integer :: ERROR_FEATURE_NOT_COMPATIBLE = 100001
    integer, parameter :: nullvalueI = -998877
    real, parameter :: nullvalueR = -9.98877e16

    ! Number of objects
    integer :: num_nodes
    integer :: num_links
    integer :: num_curves
    integer :: num_tseries

    ! SWMM objects
    integer :: SWMM_NODE = 2
    integer :: SWMM_LINK = 3
    integer :: SWMM_CURVES = 7
    integer :: SWMM_TSERIES = 8

    ! SWMM XSECT_TYPES
    integer :: SWMM_RECT_CLOSED = 3
    integer :: SWMM_RECT_OPEN = 4
    integer :: SWMM_TRAPEZOIDAL = 5
    integer :: SWMM_TRIANGULAR = 6
    integer :: SWMM_PARABOLIC = 7

    ! SWMM+ XSECT_TYPES - Also defined in data_keys.f08 (uncomment if debugging)
    integer :: lchannel = 1
    integer :: lpipe = 2
    integer :: lRectangular = 1
    integer :: lParabolic = 2
    integer :: lTrapezoidal = 3
    integer :: lTriangular = 4

    ! api_node_attributes
    integer, parameter :: node_ID = 1
    integer, parameter :: node_type = 2
    integer, parameter :: node_invertElev = 3
    integer, parameter :: node_initDepth = 4
    integer, parameter :: node_extInflow_tSeries = 5
    integer, parameter :: node_extInflow_basePat = 6
    integer, parameter :: node_extInflow_baseline = 7
    integer, parameter :: node_depth = 8
    integer, parameter :: node_inflow = 9
    integer, parameter :: node_volume = 10
    integer, parameter :: node_overflow = 11
    integer, parameter :: num_node_attributes = 11

    ! api_link_attributes
    integer, parameter :: link_ID = 1
    integer, parameter :: link_subIndex = 2
    integer, parameter :: link_node1 = 3
    integer, parameter :: link_node2 = 4
    integer, parameter :: link_q0 = 5
    integer, parameter :: link_flow = 6
    integer, parameter :: link_depth = 7
    integer, parameter :: link_volume = 8
    integer, parameter :: link_froude = 9
    integer, parameter :: link_setting = 10
    integer, parameter :: link_left_slope = 11
    integer, parameter :: link_right_slope = 12
    integer, parameter :: conduit_roughness = 13
    integer, parameter :: conduit_length = 14
    integer, parameter :: num_link_attributes = 14
    ! --- xsect attributes
    integer, parameter :: link_type = 15
    integer, parameter :: link_xsect_type = 16
    integer, parameter :: link_geometry = 17
    integer, parameter :: link_xsect_wMax = 18
    integer, parameter :: link_xsect_yBot = 19
    integer, parameter :: num_link_xsect_attributes = 19 - num_link_attributes
    integer, parameter :: num_total_link_attributes = num_link_attributes + num_link_xsect_attributes

    procedure(api_initialize), pointer, private :: ptr_api_initialize
    procedure(api_finalize), pointer, private :: ptr_api_finalize
    procedure(api_get_node_attribute), pointer, private :: ptr_api_get_node_attribute
    procedure(api_get_link_attribute), pointer, private :: ptr_api_get_link_attribute
    procedure(api_get_num_objects), pointer, private :: ptr_api_get_num_objects

contains

    ! --- Simulation

    subroutine initialize_api()

        integer :: ppos, num_args
        character(len=256) :: inp_file ! absolute path to .inp
        character(len=256) :: rpt_file ! absolute path to .rpt
        character(len=256) :: out_file ! absolute path to .out
        character(len = 256) :: cwd
        character(64) :: subroutine_name

        subroutine_name = 'initialize_api'

        if ((debuglevel > 0) .or. (debuglevelall > 0)) print *, '*** enter ', subroutine_name

        ! Initialize C API
        api = c_null_ptr
        call init_os_type(1, os)
        call init_dll(dll)

        ! Get current working directory
        call getcwd(cwd)

        ! Retrieve .inp file path from args
        num_args = command_argument_count()
        if (num_args < 1) then
            print *, "error: path to .inp file was not defined"
            stop
        end if

        call get_command_argument(1, inp_file)

        ppos = scan(trim(inp_file), '.', back = .true.)
        if (ppos > 0) then
            rpt_file = inp_file(1:ppos) // "rpt"
            out_file = inp_file(1:ppos) // "out"
        end if

        inp_file = trim(inp_file) // c_null_char
        rpt_file = trim(rpt_file) // c_null_char
        out_file = trim(out_file) // c_null_char

        dll%filename = "libswmm5.so"

        ! Initialize API
        dll%procname = "api_initialize"
        call load_dll(os, dll, errstat, errmsg)
        call print_error(errstat, 'error: loading api_initialize')
        call c_f_procpointer(dll%procaddr, ptr_api_initialize)
        api = ptr_api_initialize(inp_file, rpt_file, out_file)

        num_links = get_num_objects(SWMM_LINK)
        num_nodes = get_num_objects(SWMM_NODE)
        num_curves = get_num_objects(SWMM_CURVES)
        num_tseries = get_num_objects(SWMM_TSERIES)

        if ((debuglevel > 0) .or. (debuglevelall > 0))  print *, '*** leave ', subroutine_name

    end subroutine initialize_api

    subroutine finalize_api()
        character(64) :: subroutine_name

        subroutine_name = 'finalize_api'

        if ((debuglevel > 0) .or. (debuglevelall > 0)) print *, '*** enter ', subroutine_name

        dll%procname = "api_finalize"
        call load_dll(os, dll, errstat, errmsg )
        call print_error(errstat, 'error: loading api_finalize')
        call c_f_procpointer(dll%procaddr, ptr_api_finalize)
        call ptr_api_finalize(api)
        if (errstat /= 0) then
            call print_error(errstat, dll%procname)
            stop
        end if
        if ((debuglevel > 0) .or. (debuglevelall > 0))  print *, '*** leave ', subroutine_name

    end subroutine finalize_api

    ! --- Property-extraction

    ! * After Initialization

    function get_node_attribute(node_idx, attr)

        integer :: node_idx, attr, error
        real, pointer :: ptr_node_attr
        real :: get_node_attribute
        character(64) :: subroutine_name
        type(c_ptr) :: value

        subroutine_name = 'get_node_attr'

        if ((debuglevel > 0) .or. (debuglevelall > 0)) print *, '*** enter ', subroutine_name

        if ((attr > num_node_attributes) .or. (attr < 1)) then
            print *, "error: unexpected node attribute value", attr
            stop
        end if

        if ((node_idx > num_nodes) .or. (node_idx < 1)) then
            print *, "error: unexpected node index value", node_idx
            stop
        end if

        dll%procname = "api_get_node_attribute"
        call load_dll(os, dll, errstat, errmsg)
        call print_error(errstat, 'error: loading api_get_node_attribute')
        call c_f_procpointer(dll%procaddr, ptr_api_get_node_attribute)
        ! Fortran index starts in 1, whereas in C starts in 0
        error = ptr_api_get_node_attribute(api, node_idx-1, attr, value)
        call print_swmm_error_code(error)
        call c_f_pointer(value, ptr_node_attr)

        get_node_attribute = ptr_node_attr

        if ((debuglevel > 0) .or. (debuglevelall > 0))  print *, '*** leave ', subroutine_name

    end function get_node_attribute

    function get_link_attribute(link_idx, attr)

        integer :: link_idx, attr, error
        real, pointer :: ptr_link_attr
        real :: get_link_attribute
        real, pointer :: xsect_type
        character(64) :: subroutine_name
        type(c_ptr) :: cptr_value
        real (c_double), target :: link_value

        cptr_value = c_loc(link_value)

        subroutine_name = 'get_link_attr'

        if ((debuglevel > 0) .or. (debuglevelall > 0)) print *, '*** enter ', subroutine_name

        if ((attr > num_total_link_attributes) .or. (attr < 1)) then
            print *, "error: unexpected link attribute value", attr
            stop
        end if

        if ((link_idx > num_links) .or. (link_idx < 1)) then
            print *, "error: unexpected link index value", link_idx
            stop
        end if

        dll%procname = "api_get_link_attribute"
        call load_dll(os, dll, errstat, errmsg )
        call print_error(errstat, 'error: loading api_get_link_attribute')
        call c_f_procpointer(dll%procaddr, ptr_api_get_link_attribute)

        if (attr <= num_link_attributes) then
            ! Fortran index starts in 1, whereas in C starts in 0
            error = ptr_api_get_link_attribute(api, link_idx-1, attr, cptr_value)
            call print_swmm_error_code(error)
            get_link_attribute = link_value
        else
            error = ptr_api_get_link_attribute(api, link_idx-1, link_xsect_type, cptr_value)
            call print_swmm_error_code(error)
            get_link_attribute = link_value
            if (xsect_type == SWMM_RECT_CLOSED) then
                if (attr == link_geometry) then
                    get_link_attribute = lRectangular
                else if (attr == link_type) then
                    get_link_attribute = lpipe
                else if (attr == link_xsect_wMax) then
                    error = ptr_api_get_link_attribute(api, link_idx-1, link_xsect_wMax, cptr_value)
                    call print_swmm_error_code(error)
                    get_link_attribute = link_value
                else
                    get_link_attribute = nullvalueR
                end if
            else if (xsect_type == SWMM_RECT_OPEN) then
                if (attr == link_geometry) then
                    get_link_attribute = lRectangular
                else if (attr == link_type) then
                    get_link_attribute = lchannel
                else if (attr == link_xsect_wMax) then
                    error = ptr_api_get_link_attribute(api, link_idx-1, link_xsect_wMax, cptr_value)
                    call print_swmm_error_code(error)
                    get_link_attribute = link_value
                else
                    get_link_attribute = nullvalueR
                end if
            else if (xsect_type == SWMM_TRAPEZOIDAL) then
                if (attr == link_geometry) then
                    get_link_attribute = lTrapezoidal
                else if (attr == link_type) then
                    get_link_attribute = lchannel
                else if (attr == link_xsect_wMax) then
                    error = ptr_api_get_link_attribute(api, link_idx-1, link_xsect_yBot, cptr_value)
                    call print_swmm_error_code(error)
                    get_link_attribute = link_value
                else
                    get_link_attribute = nullvalueR
                end if
            else if (xsect_type == SWMM_TRIANGULAR) then
                if (attr == link_geometry) then
                    get_link_attribute = lTriangular
                else if (attr == link_type) then
                    get_link_attribute = lchannel
                else if (attr == link_xsect_wMax) then
                    error = ptr_api_get_link_attribute(api, link_idx-1, link_xsect_wMax, cptr_value)
                    call print_swmm_error_code(error)
                    get_link_attribute = link_value
                else
                    get_link_attribute = nullvalueR
                end if
            else if (xsect_type == SWMM_PARABOLIC) then
                if (attr == link_geometry) then
                    get_link_attribute = lParabolic
                else if (attr == link_type) then
                    get_link_attribute = lchannel
                else if (attr == link_xsect_wMax) then
                    error = ptr_api_get_link_attribute(api, link_idx-1, link_xsect_wMax, cptr_value)
                    call print_swmm_error_code(error)
                    get_link_attribute = link_value
                else
                    get_link_attribute = nullvalueR
                end if
            else
                get_link_attribute = nullvalueR
            end if
        end if

        if ((debuglevel > 0) .or. (debuglevelall > 0))  print *, '*** leave ', subroutine_name
    end function get_link_attribute

    function get_num_objects(obj_type)

        integer :: obj_type
        integer :: get_num_objects
        character(64) :: subroutine_name

        subroutine_name = 'get_num_objects'

        if ((debuglevel > 0) .or. (debuglevelall > 0)) print *, '*** enter ', subroutine_name

        dll%procname = "api_get_num_objects"
        call load_dll(os, dll, errstat, errmsg )
        call print_error(errstat, 'error: loading api_get_num_objects')
        call c_f_procpointer(dll%procaddr, ptr_api_get_num_objects)
        get_num_objects = ptr_api_get_num_objects(api, obj_type)
        if ((debuglevel > 0) .or. (debuglevelall > 0))  print *, '*** leave ', subroutine_name

    end function get_num_objects

    ! --- Utils
    subroutine print_swmm_error_code(error)
        integer, intent(in) :: error
        if (error .ne. 0) then
            print *, "Error code: " , error
            stop
        end if
    end subroutine print_swmm_error_code

end module interface
