#include "winsize.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#ifdef _WIN32
#include <windows.h>
#else
#include <unistd.h>
#include <sys/ioctl.h>
#endif

// free wrapper that is explicitly exported
void free_memory(void* ptr) {
    free(ptr);
}

#ifdef _WIN32
int set_console_mode(int enable_echo) {
    HANDLE hStdin = GetStdHandle(STD_INPUT_HANDLE);
    DWORD mode;

    if (hStdin == INVALID_HANDLE_VALUE) return 0;

    if (!GetConsoleMode(hStdin, &mode)) return 0;

    if (enable_echo) {
        mode |= (ENABLE_ECHO_INPUT | ENABLE_LINE_INPUT);
    } else {
        mode &= ~(ENABLE_ECHO_INPUT | ENABLE_LINE_INPUT);
    }

    if (!SetConsoleMode(hStdin, mode)) return 0;

    return 1;
}

int get_console_mode() {
    HANDLE hStdin = GetStdHandle(STD_INPUT_HANDLE);
    DWORD mode;

    if (hStdin == INVALID_HANDLE_VALUE) return -1;

    if (!GetConsoleMode(hStdin, &mode)) return -1;

    return mode;
}
#else
int set_console_mode(int enable_echo) {
    return 0;  // Not implemented for non-Windows
}

int get_console_mode() {
    return -1;  // Not implemented for non-Windows
}
#endif

uint16_t* winsize() {
    uint16_t* dim = (uint16_t*)malloc(sizeof(uint16_t) * 2);

    if (dim == NULL) {
        perror("malloc failed");
        return NULL;
    }

#ifdef _WIN32
    CONSOLE_SCREEN_BUFFER_INFO csbi;

    if (GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi)) {
        dim[0] = csbi.srWindow.Bottom - csbi.srWindow.Top + 1; // Rows
        dim[1] = csbi.srWindow.Right - csbi.srWindow.Left + 1;  // Columns
    } else {
        dim[0] = 0;
        dim[1] = 0;
    }

#else
    struct winsize w;

    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == -1) {
        perror("ioctl TIOCGWINSZ");
        free(dim);
        return NULL;
    }

    dim[0] = w.ws_row;
    dim[1] = w.ws_col;
#endif

    return dim;
}
