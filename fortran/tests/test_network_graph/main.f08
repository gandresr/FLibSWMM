program main

    use interface
    use network_graph

    implicit none

    integer :: x(1)
    type(graph) :: g

    call initialize_api()
    g = get_network_graph()
    print *, 'DONE GRAPH'
    call free_graph(g)
    call finalize_api()
end program main