#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if(argc<=1) {
        printf("0\n");
        return 0;
    }

    printf("0x%lx\n", strtol(argv[1], 0, 0));
}
