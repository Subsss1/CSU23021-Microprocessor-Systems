#include "hardware/gpio.h"

// Must declare the main assembly entry point before use.
void main_asm();


/**
 * @brief Wrapper to allow the assembly code to call the gpio_init()
 *        SDK function.
 * 
 * @param pin       The GPIO pin number to initialise.
 */
void asm_gpio_init(int pin) {
    gpio_init(pin);
}


/**
 * @brief Wrapper to allow the assembly code to call the gpio_set_dir()
 *        SDK function.
 * 
 * @param pin       The GPIO pin number of which to set the direction.
 * @param dir       Specify the direction that the pin should be set to (0=input/1=output).
 */
void asm_gpio_set_dir(int pin, int dir) {
    gpio_set_dir(pin, dir);
}


/**
 * @brief Wrapper to allow the assembly code to call the gpio_get()
 *        SDK function.
 * 
 * @param pin       The GPIO pin number to read from.
 * @return int      Returns the current value of the GPIO pin.
 */
int asm_gpio_get(int pin) {
    return gpio_get(pin);
}


/**
 * @brief Wrapper to allow the assembly code to call the gpio_put()
 *        SDK function.
 * 
 * @param pin       The GPIO pin number to write to.
 * @param value     Specify the value that the pin should be set to (0/1).
 */
void asm_gpio_put(int pin, int value) {
    gpio_put(pin, value);
}


/**
 * @brief EXAMPLE - BLINK_ASM
 *        Simple example that uses assembly code to initialise
 *        the built-in LED on Raspberry Pi Pico and then flash
 *        it forever using a sleep routine to set the period of
 *        the flash.
 * 
 * @return int      Returns exit-status zero on completion.
 */
int main() {

    // Jump into the main assembly code subroutine.
    main_asm();

    // Returning zero indicates everything went okay.
    return 0;
}
