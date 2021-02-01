module network_graph

    use interface
    use dynamic_array

    implicit none

    type graph_node
        integer :: node_id
        type(integer_array) :: neighbors
    end type graph_node

    type graph
        integer :: num_vertices
        type(graph_node), allocatable, dimension(:) :: g ! graph linked lists
        integer, allocatable, dimension(:) :: in_degree ! list with in-degrees of node
    end type graph

contains

    function new_graph(num_vertices)
        integer, intent(in) :: num_vertices
        type(graph) :: new_graph
        new_graph%num_vertices = num_vertices
        allocate(new_graph%g(num_vertices))
        allocate(new_graph%in_degree(num_vertices))
        new_graph%in_degree(:) = 0
    end function

    subroutine add_graph_link(g, source, destination)
        type(graph), intent(inout) :: g
        integer, intent(in) :: source, destination
        call dyna_integer_append(g%g(source)%neighbors, destination)
    end subroutine add_graph_link

    subroutine free_graph(g)
        type(graph), intent(inout) :: g
        deallocate(g%g)
        deallocate(g%in_degree)
    end subroutine free_graph

    function get_network_graph()
        type(graph) :: get_network_graph
        integer :: i, src, dest

        call initialize_api()

        get_network_graph = new_graph(num_nodes)

        do i = 1, num_links
            src = int(get_link_attribute(i, link_node1)) + 1
            dest = int(get_link_attribute(i, link_node2)) + 1
            get_network_graph%in_degree(dest) = get_network_graph%in_degree(dest) + 1
            call add_graph_link(get_network_graph, src, dest)
        end do

        call finalize_api()

    end function get_network_graph
end module network_graph