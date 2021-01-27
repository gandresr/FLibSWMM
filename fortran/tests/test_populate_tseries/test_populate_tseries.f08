program test_populate_tseries

    use tables
    use interface
    use inflow

    implicit none

    real :: i = 0

    call initialize_api()

    call inflow_populate_inflows()

    print *, allocated(ext_inflows)
    print *, allocated(dwf_inflows)

    call finalize_api()


end program test_populate_tseries