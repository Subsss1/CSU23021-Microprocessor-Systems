//#define WOKWI             // Uncomment if running on Wokwi RP2040 emulator.

#include <stdio.h>
#include <stdlib.h>
#include "pico/stdlib.h"


/**
 * @brief EXAMPLE - HELLO_C
 *        Simple example to initialise the IOs and then 
 *        print a "Hello World!" message to the console.
 * 
 * @return int  Application return code (zero for success).
 */
int main() {

#ifndef WOKWI
    // Initialise the IO as we will be using the UART
    // Only required for hardware and not needed for Wokwi
    stdio_init_all();
#endif

    // Print a console message to inform user what's going on.
    printf("Hello World!\n");

    // Returning zero indicates everything went okay.
    return 0;
}
