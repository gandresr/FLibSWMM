program main

    use network_graph

    implicit none
    integer :: x(1)
    type(graph) :: g
    g = get_network_graph() 
    x = findloc(g%in_degree, value = 1) ! first occurrence
    print *, x, g%in_degree(x(1):)
    print *, findloc(g%in_degree(x(1)+1:), value = 1)
    call free_graph(g)
end program main