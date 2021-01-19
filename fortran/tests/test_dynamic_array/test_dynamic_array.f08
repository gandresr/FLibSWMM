
program main
    use dynamic_array
    implicit none
    type(f_array) :: x
    integer i

    do i = 1 , 25
        call append(x, 2.0*i)
        print *, x%arr(x%len), x%len, x%max_size
    end do

    call free_arr(x)
end program main