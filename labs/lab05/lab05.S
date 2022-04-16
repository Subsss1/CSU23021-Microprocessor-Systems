#include "hardware/regs/addressmap.h"
#include "hardware/regs/m0plus.h"

.syntax unified                 @ Specify unified assembly syntax
.cpu    cortex-m0plus           @ Specify CPU type is Cortex M0+
.thumb                          @ Specify thumb assembly for RP2040
.global main_asm                @ Provide program starting address to the linker
.align 4                        @ Specify code alignment

.equ    SLEEP_TIME, 500         @ Specify the sleep time (in ms)
.equ    LED_GPIO_PIN, 25        @ Specify the pin that the LED is connected to
.equ    LED_GPIO_OUT, 1         @ Specify the direction of the GPIO pin
.equ    LED_VALUE_ON, 1         @ Specify the value that turns the LED "on"
.equ    LED_VALUE_OFF, 0        @ Specify the value that turns the LED "off"
.equ    SVC_ISR_OFFSET, 0x2C    @ The SVC is entry 11 in the vector table
.equ    SVC_MAX_INSTRS, 0x01    @ Maximum allowed SVC subroutines

@ Entry point to the ASM portion of the program
main_asm:
    bl      init_gpio_led       @ Initialise the GPIO LED pin
    bl      install_svc_isr     @ Install the SVC interrupt service routine
loop:
    svc     #0                  @ Call the SVC ISR with value 0 (turns on LED)
    nop                         @ Add a no-op instruction for alignment after SVC
    bl      do_sleep            @ Short pause before proceeding
    svc     #1                  @ Call the SVC ISR with value 1 (turns off LED)
    nop                         @ Add a no-op instruction for alignment after SVC
    bl      do_sleep            @ Add a short pause before proceeding
    b       loop                @ Always jump back to the start of the loop

@ Subroutine used to introduce a short delay in the application
do_sleep:
    push    {lr} 
    ldr     r0, =SLEEP_TIME             @ Set the value of SLEEP_TIME we want to wait for
    bl      sleep_ms                    @ Sleep until SLEEP_TIME has elapsed then toggle the LED GPIO pin
    pop     {pc} 

@ Subroutine used to initialise the PI Pico built-in LED
init_gpio_led:
    push    {lr}
    movs    r0, #LED_GPIO_PIN           @ This value is the GPIO LED pin on the PI PICO board
    bl      asm_gpio_init               @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #LED_GPIO_PIN           @ This value is the GPIO LED pin on the PI PICO board
    movs    r1, #LED_GPIO_OUT           @ We want this GPIO pin to be setup as an output pin
    bl      asm_gpio_set_dir            @ Call the subroutine to set the GPIO pin specified by r0 to state specified by r1
    pop     {pc}

@ Subroutine used to install the SVC interrupt service handler
install_svc_isr:                                    @ The install_svc_isr function puts the entry address of svc_isr in the RAM vector table
    ldr     r2, =(PPB_BASE + M0PLUS_VTOR_OFFSET)    @ add PPB_BASE and M0PLUS_VTOR_OFFSET address to r2 
    ldr     r1, [r2]                                @ set those two addresses to r1 
    movs    r2, #SVC_ISR_OFFSET                     @ free r2 and assign it to SVC_ISR_OFFSET address
    add     r2, r1                                  @ add all three addresses into r2 
    ldr     r0, =svc_isr                            @ free r0 and assign it to svc_isr 
    str     r0, [r2]                                @ put all three addresses into svc_isr function 
    bx      lr                                      @ end function 

@ SVC interrupt service handler routine
.thumb_func                     @ Required for all interrupt service routines
svc_isr:                        @ only the 16 - bit version of the SVC instruction is available
    push    {lr}                @ fetches the SVC opcode that caused the exception to occur
    ldr     r0, [sp, #0x1C]     @ to retrieve the address of the SVC opcode from the PC in the stack 
    subs    r0, #0x2            @ subtract sp address by 0x2 
    ldr     r0, [r0]            @ update ro address that points to sp
    ldr     r1, =#0xFF          @ extracts and verifies the lower 8-bit immediate value from the SVC opcode
    ands    r0, r1              @ using AND instructions(when r0:0 r1:1 or r0:1 r1:0, change r0 into 0)
    cmp     r0, #SVC_MAX_INSTRS @ compare to SVC_MAX_INSTRS to check whether r0 reaches the maximum number or not
    bgt     svc_done            @ if r0 greater than SVC_MAX_INSTRS, then the function should be terminated
    adr     r1, svc_jmptbl      @ Calls the correct pre-defined SVC function from the jump-table
    lsls    r0, #2              @ logical shift left the r0 by two digits after finishing AND statement with r1 and didn't reach to the maximum value
    ldr     r1, [r1, r0]        @ load r1 to r0's address
    mov     pc, r1              @ put r1 into pc thread in order to update?
svc_done:
    pop     {pc}                @using push and pop instructions to protect function 

@ First function of SVC subroutine - turn on the LED
svc_num0:
    movs    r1, #LED_VALUE_ON           @ The LED is currently "off" so we want to turn it "on"
    movs    r0, #LED_GPIO_PIN           @ Set the LED GPIO pin number to r0 for use by asm_gpio_put
    bl      asm_gpio_put                @ Update the the value of the LED GPIO pin (based on value in r1)
    b       svc_done                    @ Branch back to the main ISR when done

@ Second function of SVC subroutine - turn off the LED
svc_num1:
    movs    r1, #LED_VALUE_OFF          @ The LED is currently "on" so we want to turn it "off"
    movs    r0, #LED_GPIO_PIN           @ Set the LED GPIO pin number to r0 for use by asm_gpio_put
    bl      asm_gpio_put                @ Update the the value of the LED GPIO pin (based on value in r1)
    b       svc_done                    @ Branch back to the main ISR when done

@ SVC function entry jump table.
.align 2
svc_jmptbl:
    .word svc_num0              @ Entry zero goes to SVC function #0.
    .word svc_num1              @ Entry one goes to SVC function #1.
    .word 0                     @ Null termination of the jump table.

@ Set data alignment
.data
    .align 4