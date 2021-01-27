
program main
    use dynamic_array
    implicit none
    type(real_array) :: x
    integer i

    do i = 1 , 25
        call dyna_real_append(x, 2.0*i)
        print *, x%array(x%len), x%len, x%max_size
    end do

    call free_arr(x)
end program main