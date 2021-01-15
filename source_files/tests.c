#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#include "headers.h"
#include "tests.h"

void DLLEXPORT interface_print_inflow(char* node_name)
{
    int j;
    j = project_findObject(NODE, node_name);
    printf("%f FLOW\n", Node[j].inflow);
}