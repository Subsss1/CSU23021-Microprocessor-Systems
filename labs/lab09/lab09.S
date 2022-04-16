#include "hardware/regs/addressmap.h"
#include "hardware/regs/io_bank0.h"
#include "hardware/regs/timer.h"
#include "hardware/regs/m0plus.h"
#include "hardware/regs/addressmap.h"
#include "hardware/regs/adc.h"

.syntax unified
.cpu    cortex-m0plus
.thumb
.global main_asm
.align  4

.EQU    TEMPADC, 4
.equ    DFLT_STATE_STRT, 1            @ Specify the value to start flashing
.equ    DFLT_STATE_STOP, 0            @ Specify the value to stop flashing
.equ    DFLT_ALARM_TIME, 1000000      @ Specify the default alarm timeout

.equ    ACD_RESULT, 0x04              @ OFFSET FOR READING
.equ    ACD_enable, 0x18              @ 
#.equ    ADC_BASE, 0x4004c000          @ BASE OF ACD TABLE


.equ    GPIO_BTN_DN_MSK, 0x00040000   @ Bit-18 for falling-edge event on GP20
.equ    GPIO_BTN_EN_MSK, 0x00400000   @ Bit-22 for falling-edge event on GP21
.equ    GPIO_BTN_UP_MSK, 0x04000000   @ Bit-26 for falling-edge event on GP22


.equ    GPIO_BTN_DN,  20              @ Specify pin for the "down" button
.equ    GPIO_BTN_EN,  21              @ Specify pin for the "enter" button
.equ    GPIO_BTN_UP,  22              @ Specify pin for the "up" button
.equ    GPIO_LED_PIN, 28              @ Specify pin for the built-in LED
.equ    GPIO_DIR_IN,   0              @ Specify input direction for a GPIO pin
.equ    GPIO_DIR_OUT,  1              @ Specify output direction for a GPIO pin


.equ    LED_VAL_ON,    1              @ Specify value that turns the LED "on"
.equ    LED_VAL_OFF,   0              @ Specify value that turns the LED "off"

.equ    GPIO_ISR_OFFSET, 0x74         @ GPIO is int #13 (vector table entry 29)
.equ    ALRM_ISR_OFFSET, 0x40         @ ALARM0 is int #0 (vector table entry 16)

.EQU TEMPADC, 4


@ Entry point to the ASM portion of the program
main_asm:
    bl    init_leds                              @ call subroutine to initailize the LEDS
    bl    install_alrm_isr                       @ call subroutine to initailize the alarm isr
    bl    initTempSensor
    ldr   r4, =DFLT_ALARM_TIME                   @ define alarm delay
    bl    set_alarm                              @ Set a new alarm
    ldr   r2, =(TIMER_BASE + TIMER_INTE_OFFSET)  @enable alarm
    movs  r1,#1                                  @enable alarm
    str   r1, [r2]                               @enable alarm
loop:
    wfi                                          @Wait here for interrupt
    b     loop                
//main_asm:
//    ldr   r5, =#LED_VAL_ON
//    ldr   r4, =#DFLT_ALARM_TIME
//    bl    init_leds                   // Same as previous labs
//    bl    init_btns                   // Use asm_gpio_set_irq C function to setup falling-edge interrutps
//    bl    install_alrm_isr            // See below
//    bl    install_gpio_isr            // See below
//loop:        
//    bl    set_alarm                   // Set a new alarm
//    wfi                               // Wait here until any interrupt fires
//    b     loop                        // Always branch back to loop





init_leds:
    push    {lr}                         @ Store the link register to the stack
    
    movs    r0, #GPIO_LED_PIN            @ This value is the GPIO BUTTON pin on the PI PICO board
    bl      asm_gpio_init                @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #GPIO_LED_PIN            @ This value is the GPIO LED pin on the PI PICO board
    movs    r1, #GPIO_DIR_OUT            @ We want this GPIO pin to be setup as an output pin
    bl      asm_gpio_set_dir             @ Call the subroutine to set the GPIO pin specified by r0 to state specified by r1
    
    pop     {pc}                         @ Pop the link register from stack counter

set_alarm:
           
    ldr     r1, =(TIMER_BASE + TIMER_TIMELR_OFFSET) 
    ldr     r2,[r1]                                     // Get the current timer count from (TIMER_BASE + TIMER_TIMELR_OFFSET) register
    movs    r1, r4                                  
    add     r1, r1, r2                                  // Add the time delay you want to wait for to the current timer count
    ldr     r2, =(TIMER_BASE + TIMER_ALARM0_OFFSET)     // Push the updated value to (TIMER_BASE + TIMER_ALARM0_OFFSET)
    str     r1, [r2]                                
    bx      lr 

  //ldr   r1, =(TIMER_BASE + TIMER_INTE_OFFSET)         // Enable alarm timer interrupts using the (TIMER_BASE + TIMER_INTE_OFFSET) register
  //ldr   r2, [r1]      
  //ldr   r1, =0x1      
  //orrs  r2, r2, r1                                      
  //ldr   r1, =(TIMER_BASE + TIMER_INTE_OFFSET)         
  //str   r2, [r1]      
  //pop   {pc}                                          // Exit subroutine



install_alrm_isr:
    ldr     r2, =(PPB_BASE + M0PLUS_VTOR_OFFSET)        // Get the address of the RAM vector table using the (PPB_BASE + M0PLUS_VTOR_OFFSET) register 
    ldr     r1, [r2]                                    // Store the address of the alrm_isr handler to the correct offset for ALARM0 in the vector table
    movs    r2, #ALRM_ISR_OFFSET                       
    add     r2, r1                                     
    ldr     r0, =alrm_isr                              
    str     r0, [r2]  

    ldr     r2, =(PPB_BASE + M0PLUS_NVIC_ICPR_OFFSET)   // Disable the ALARM0 IRQ by writing the correct value to (PPB_BASE + M0PLUS_NVIC_ICPR_OFFSET)
    movs    r1, #0x1                                   
    str     r1 ,[r2]                                   
    ldr     r2, =(PPB_BASE + M0PLUS_NVIC_ISER_OFFSET)  
    movs    r1, #0x1                                   
    str     r1 ,[r2]                                   
    bx      lr        

  //ldr     r1, =(PPB_BASE + M0PLUS_NVIC_ISER_OFFSET)   // Enable the ALARM0 IRQ by writing the correct value to (PPB_BASE + M0PLUS_NVIC_ISER_OFFSET)
  //ldr     r2, [r1]
  //movs    r1, #0x1
  //orrs    r2, r2, r1
  //ldr     r1, =(PPB_BASE + M0PLUS_NVIC_ISER_OFFSET)
  //str     r2, [r1]


initTempSensor:
    push {lr}   	                                  
    movs r1, #TEMPADC                                 @ Intialise the temp sensor
    lsls r1, #ADC_CS_AINSEL_LSB
    adds r1, (ADC_CS_TS_EN_BITS+ADC_CS_EN_BITS)
    ldr  r2, =ADC_BASE
    str  r1, [R2, #ADC_CS_OFFSET]

NotReady: 
    ldr  r1, [r2, #ADC_CS_OFFSET]                      @ wait until starts to read
    movs r3, #1
    lsls r3, #ADC_CS_READY_LSB
    ands r1, r3
    beq  NotReady                                      @ if it is not ready, start looping
    pop {pc}



.thumb_func
alrm_isr:
 
    push    {lr}                                     
    ldr     r1, =(TIMER_BASE+TIMER_INTR_OFFSET)      
    movs    r0 ,#1                                   
    str     r0,[r1]                                  
                                                     
    ldr     r2, =ADC_BASE
    ldr     r1, [r2, #ADC_CS_OFFSET]                 
    adds    r1, #ADC_CS_START_ONCE_BITS              
    str     r1, [r2, #ADC_CS_OFFSET]
notReady:
    ldr     R1, [R2, #ADC_CS_OFFSET]       
    movs    R3, #1
    lsls    R3, #ADC_CS_READY_LSB           
    ands    R1, R3
    beq     notReady
    LDR     R0, [R2, #ADC_RESULT_OFFSET]             
    bl      temperature
    bl      set_alarm                                
    ldr     r2, =(TIMER_BASE + TIMER_INTE_OFFSET)    
    movs    r1,#1                                    
    str     r1, [r2]                                 

    pop     {pc}                                     @ Pop the link register from the stack to the program counter


adcbase: .word ADC_BASE 
//.thumb_func 
//alrm_isr:
//    push    {lr}
//                                                   // Perform required functionality (e.g. toggle the LED)
//    movs    r0, #GPIO_LED_PIN                      // Set the LED GPIO pin number to r0 for use by asm_gpio_get
//    bl      asm_gpio_get                           // Get current the value of the LED GPIO pin (returns to r0)
//    cmp     r0, #LED_VAL_OFF                       // Check if the LED GPIO pin value is "off"
//    beq     led_set_on                             // If it is "off" then then jump code to to turn it on
//led_set_off:          
//    movs    r1, #LED_VAL_OFF                       // The LED is currently "on" so we want to turn it "off"
//    b       led_set_state                          // Jump to portion of code where we set the state of the LED
//led_set_on:          
//    movs    r1, r5                                 // The LED is currently "off" so we want to turn it "on"
//led_set_state:          
//    movs    r0, #GPIO_LED_PIN                      // Set the LED GPIO pin number to r0 for use by asm_gpio_put
//    bl      asm_gpio_put                           // Update the the value of the LED GPIO pin (based on value in r1)//
//    ldr     r1, =(TIMER_BASE + TIMER_INTR_OFFSET)  // Disable pending interrupt from TIMER by writing correct value to (TIMER_BASE + TIMER_INTR_OFFSET)
//    ldr     r2, [r1]
//    ldr     r1, =#0x1
//    orrs    r2, r2, r1
//    ldr     r1, =(TIMER_BASE + TIMER_INTR_OFFSET)
//    str     r2, [r1]
//    pop     {pc}                                   // Pop the link register from the stack to the program counter