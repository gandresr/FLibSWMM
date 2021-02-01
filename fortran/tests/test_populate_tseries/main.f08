program main

    use tables
    use interface
    use inflow

    implicit none

    integer :: i = 0

    call initialize_api()

    i = get_link_attribute(1, conduit_roughness)
    call inflow_populate_inflows()
    print *, allocated(ext_inflows)
    do i = 1, ext_inflows(1)%t_series%table%len
        print *, ext_inflows(1)%t_series%table%x%array(i), ext_inflows(1)%t_series%table%y%array(i)
    end do
    print *, allocated(dwf_inflows)
    call finalize_api()

end program main