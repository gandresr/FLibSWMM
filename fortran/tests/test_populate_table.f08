program test_populate_table

    use interface

    implicit none

    integer :: i
    real, allocatable :: link_table(:,:)
    real, allocatable :: node_table(:,:)

    call initialize_api()

    allocate(link_table(num_links, num_total_link_attributes))
    allocate(node_table(num_nodes, num_node_attributes))

    do i = 1, num_links
        link_table(i, link_ID) = i
        link_table(i, link_subIndex) = get_link_attribute(i, link_subIndex)
        link_table(i, link_node1) = get_link_attribute(i, link_node1)
        link_table(i, link_node2) = get_link_attribute(i, link_node2)
        link_table(i, link_q0) = get_link_attribute(i, link_q0)
        link_table(i, link_flow) = get_link_attribute(i, link_flow)
        link_table(i, link_depth) = get_link_attribute(i, link_depth)
        link_table(i, link_volume) = get_link_attribute(i, link_volume)
        link_table(i, link_froude) = get_link_attribute(i, link_froude)
        link_table(i, link_setting) = get_link_attribute(i, link_setting)
        link_table(i, link_left_slope) = get_link_attribute(i, link_left_slope)
        link_table(i, link_right_slope) = get_link_attribute(i, link_right_slope)
        link_table(i, conduit_roughness) = get_link_attribute(i, conduit_roughness)
        link_table(i, conduit_length) = get_link_attribute(i, conduit_length)
        print *, link_table(i,1:14)
    end do


    call finalize_api()

    deallocate(link_table)
    deallocate(node_table)

end program test_populate_table