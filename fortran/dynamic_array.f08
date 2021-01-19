module dynamic_array

    implicit none

    integer :: MAX_DARRAY_SIZE = 10

    type f_array
        integer :: max_size = 0
        integer :: len = 0
        real, allocatable :: arr(:)
    end type f_array
contains
    subroutine free_arr(this)
        type(f_array), intent(inout) :: this
        deallocate(this%arr)
    end subroutine

    subroutine append(this, x)
        type(f_array), intent(inout) :: this
        real, intent(in) :: x
        real, allocatable :: resized_arr(:)

        if (this%max_size == 0) then
            allocate(this%arr(MAX_DARRAY_SIZE))
            this%max_size = MAX_DARRAY_SIZE
        else if (this%len == this%max_size) then
            allocate(resized_arr(this%max_size * 2))
            resized_arr(1:this%max_size) = this%arr(1:this%max_size)
            this%max_size = this%max_size * 2
            call free_arr(this)
            this%arr = resized_arr
        end if

        this%len = this%len + 1
        this%arr(this%len) = x
    end subroutine append
end module
