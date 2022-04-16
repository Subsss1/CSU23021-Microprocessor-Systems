#include "pico/stdlib.h"

int main() {
    const uint LED_PIN   =  25;                  //set undefined constant LED_PIN as 25 which stands for the blinking LED light     
    const uint SLEEP_TIME   =  1000;             //set undefined constant SLEEP_TIME as 1000 to control the LED light blink in 1000ns
    const uint OFF   =  0;                       //off sign
    const uint ON   =  1;                        //on sign
    gpio_init(LED_PIN);                          //initialize LED light
    gpio_set_dir(LED_PIN, GPIO_OUT);             //set LED light parameter to output?
    while (true) {                               //make the LED light flashing endlessly
        gpio_put(LED_PIN, OFF);                  //turn off the LED light
        sleep_ms(SLEEP_TIME);                    //wait for 1000ns
        gpio_put(LED_PIN, ON);                   //turn on the LED light
        sleep_ms(SLEEP_TIME);                    //wait for 1000ns
        blink();                                 //added a subroutine that do the same thing
    }
}

void blink(){                                    //used a void method, so I need to fill in numbers instead of constants
    gpio_put(25, 0);             
    sleep_ms(1000);
    gpio_put(25, 1);
    sleep_ms(1000);
}