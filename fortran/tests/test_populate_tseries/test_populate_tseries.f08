program test_populate_tseries

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
    print *, dwf_inflows(1)%monthly_pattern%count
    print *, dwf_inflows(1)%daily_pattern%count
    print *, dwf_inflows(1)%weekly_pattern%count
    print *, dwf_inflows(1)%hourly_pattern%count
    call finalize_api()

end program test_populate_tseries