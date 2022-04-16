#include "hardware/regs/addressmap.h"
#include "hardware/regs/io_bank0.h"
#include "hardware/regs/timer.h"
#include "hardware/regs/m0plus.h"

.syntax unified                         @ Specify unified assembly syntax
.cpu    cortex-m0plus                   @ Specify CPU type is Cortex M0+
.thumb                                  @ Specify thumb assembly for RP2040
.global main_asm                        @ Provide program starting address to the linker
.align 4                                @ Specify code alignment

.equ    DFLT_ALARM_TIME, 1000000        @ Specify the default alarm timeout
.equ    ALRM_ISR_OFFSET, 0x40           @ ALARM0 is int #0 (vector table entry 16)
.equ    ADC_INPUT, 4                    @ Specify the ADC input (input 4 is the onboard temperature sensor)


@ Entry point to the ASM portion of the program
main_asm:
    bl      install_alrm_isr            @ See below
    bl      init_ADC                    @ Initialise the ADC and temperature sensor
    ldr     r4, =DFLT_ALARM_TIME        @ r4 is the register which contains the time delay to be added to the current timer count
loop:
    bl      set_alarm                   @ Set a new alarm
    wfi                                 @ Wait here until the alarm interrupt fires
    movs    r0, r5                      @ Get the raw ADC value from the shared data segement (r5)
    bl      floatTemperatureReading     @ Convert the raw ADC to a float and set the LED to an appropriate colour
    b       loop                        @ Infinite loop

@ Subroutine used to initialise the ADC and temperature sensor
init_ADC:
    push    {lr}                        @ Store the link register to the stack as we will call the init_leds subroutine
    bl      asm_adc_init                @ Call the subroutine to initialise the ADC and enable the temperature sensor
    movs    r0, #ADC_INPUT              @ This value is the ADC input (in this case we want input 4 as that is the timer)
    bl      asm_adc_select_input        @ Call the subroutine to select the input selected in r0
    pop     {pc}                        @ Pop the link register from the stack to the program counter


@ Enable alarm timer interrupts and set an alarm
set_alarm:
    ldr     r2, =(TIMER_BASE + TIMER_INTE_OFFSET)   @ Enable alarm timer interrupts using the (TIMER_BASE + TIMER_INTE_OFFSET) register
    movs    r1, #1
    str     r1, [r2]

    ldr     r2, =(TIMER_BASE + TIMER_TIMELR_OFFSET) @ Get the current timer count from (TIMER_BASE + TIMER_TIMELR_OFFSET) register
    ldr     r3, [r2]
    movs    r1, r4 
    add     r1, r3                                  @ Add the time delay you want to wait for to the current timer count
    ldr     r2, =(TIMER_BASE + TIMER_ALARM0_OFFSET) @ Push the updated value to (TIMER_BASE + TIMER_ALARM0_OFFSET)
    str     r1, [r2]
    bx      lr                                      @ Exit subroutine

@ Sets up the alrm_isr in the RAM vector table and enables the correct interrupt
install_alrm_isr:
    ldr     r2, =(PPB_BASE + M0PLUS_VTOR_OFFSET)      @ Get the address of the RAM vector table using the (PPB_BASE + M0PLUS_VTOR_OFFSET) register
    ldr     r1, [r2]                                
    movs    r2, #ALRM_ISR_OFFSET                      @ Store the address of the alrm_isr handler to the correct offset for ALARM0 in the vector table
    add     r2, r1
    ldr     r0, =alrm_isr                           
    str     r0, [r2]                                

    ldr     r2, =(PPB_BASE + M0PLUS_NVIC_ICPR_OFFSET) @ Disable the ALARM0 IRQ by writing the correct value to (PPB_BASE + M0PLUS_NVIC_ICPR_OFFSET)
    movs    r1, #1 
    str     r1, [r2]

    ldr     r2, =(PPB_BASE + M0PLUS_NVIC_ISER_OFFSET) @ Enable the ALARM0 IRQ by writing the correct value to (PPB_BASE + M0PLUS_NVIC_ISER_OFFSET)
    movs    r1, #1 
    str     r1, [r2]

    bx      lr                                        @ Exit subroutine


@ Service the pending interrupt from the ALARM0 TIMER
.thumb_func 
alrm_isr:
    push    {lr}                        @ Store the link register to the stack as we will call nested subroutines

    bl      readTemperature             @ Read the raw ADC value from the temperature sensor
    movs    r5, r0                      @ Store the raw ADC value from the temperature sensor in a shared data segment (r5)

    @ Disable pending interrupt from TIMER by writing correct value to (TIMER_BASE + TIMER_INTR_OFFSET)
    ldr     r2, =(TIMER_BASE + TIMER_INTR_OFFSET)
    movs    r1, #1
    str     r1, [r2]

    pop     {pc}                        @ Pop the link register from the stack to the program counter 

@ Set data alignment
.data
    .align 4
