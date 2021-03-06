module errors

    implicit none
    public

    ! Interface errors
    integer, parameter :: ERROR_FEATURE_NOT_COMPATIBLE = 100001
    character(40) :: MSG_FEATURE_NOT_COMPATIBLE = "ERROR [100001]: feature not compatible"

    ! Parameter errors
    integer, parameter :: ERROR_INCORRECT_PARAMETER = 200001
    character(40) :: MSG_INCORRECT_PARAMETER = "ERROR [200001]: incorrect parameter"

end module errors