// setuid_example.c

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
    // Setuid to root (0) for elevated permissions
    if (setuid(0) != 0) {
        perror("setuid");
        return 1;
    }

    // Execute command with elevated permissions
    system("/path/to/command");

    return 0;
}
