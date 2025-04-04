#ifndef WINSIZE_H
#define WINSIZE_H

#include <stdint.h>

#ifdef _WIN32
    #define EXPORT __declspec(dllexport)
#else
    #define EXPORT
#endif

/**
 * @brief Retrieves the terminal window size (rows and columns).
 *
 * @return A pointer to a dynamically allocated array of two uint16_t values:
 * - The first element (index 0) is the number of rows.
 * - The second element (index 1) is the number of columns.
 * Returns NULL if an error occurs (ioctl or malloc failure).
 * The caller is responsible for freeing the allocated memory.
 */
EXPORT uint16_t* winsize();

EXPORT void free_memory(void* ptr);  // wrapper for free

EXPORT int set_console_mode(int enable_echo);  // New function to control echo mode
EXPORT int get_console_mode();  // New function to get current mode

#endif // WINSIZE_H
