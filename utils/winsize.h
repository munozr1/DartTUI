#ifndef WINSIZE_H
#define WINSIZE_H

#include <stdint.h>

/**
 * @brief Retrieves the terminal window size (rows and columns).
 *
 * @return A pointer to a dynamically allocated array of two uint16_t values:
 * - The first element (index 0) is the number of rows.
 * - The second element (index 1) is the number of columns.
 * Returns NULL if an error occurs (ioctl or malloc failure).
 * The caller is responsible for freeing the allocated memory.
 */
uint16_t* winsize();

#endif // WINSIZE_H
