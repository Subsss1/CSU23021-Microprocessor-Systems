#include "hardware/regs/addressmap.h"
#include "hardware/regs/io_bank0.h"
#include "hardware/regs/timer.h"
#include "hardware/regs/m0plus.h"

.syntax unified                                                 @ Specify unified assembly syntax
.cpu    cortex-m0plus                                           @ Specify CPU type is Cortex M0+
.thumb                                                          @ Specify thumb assembly for RP2040
.global main_asm                                                @ Provide program starting address to the linker
.align 4                                                        @ Specify code alignment

.equ    DFLT_STATE_STRT, 1                                      @ Specify the value to start flashing
.equ    DFLT_STATE_STOP, 0                                      @ Specify the value to stop flashing
.equ    DFLT_ALARM_TIME, 1000000                                @ Specify the default alarm timeout
.equ    SLEEP_TIME, 5000

.equ    GPIO_BTN_RISE_MSK, 0x00400000                           @ Bit-22 for RISING-edge event on GP21
.equ    GPIO_BTN_FALL_MSK, 0x00800000                           @ Bit-23 for falling-edge event on GP21


.equ    DOT, 255                                                @ Input time for a dot is between 0 and 255 ms
                                                                @ Input time for a dash is 255 ms and greater


.equ    GPIO_BTN,  21                                           @ Specify pin for the button
.equ    GPIO_LED_PIN, 28                                        @ Specify pin for the built-in LED
.equ    GPIO_DIR_IN,   0                                        @ Specify input direction for a GPIO pin
.equ    GPIO_DIR_OUT,  1                                        @ Specify output direction for a GPIO pin


.equ    GPIO_ISR_OFFSET, 0x74                                   @ GPIO is int #13 (vector table entry 29)
.equ    ALRM_ISR_OFFSET, 0x40                                   @ ALARM0 is int #0 (vector table entry 16)


@ Entry point to the ASM portion of the program
main_asm:

    bl      init_btns                                           @ Use asm_gpio_set_irq C function to setup rising and falling-edge interrupts
    bl      install_gpio_isr                                    @ initialise buttons
    bl      install_alrm_isr                                    @ initialise alarm interrupts

restart_game:
    movs    r2, #0
    movs    r6, #1                                              @ Set currentQueation=true
    bl      display_level_choosing                              @ Display message for level choosing
    bl      level_select_true                                   @ Set selecting_level=true
 
level_not_chosen:
    bl      level_input                                         @ Enter the level number in morse code   
    cmp     r6, #0
    bne     level_not_chosen                                    @ Wait until an input entered
    bl      level_select_false

Start:
    cmp     r6, #0                                              @ check if currentQuestion=true
    bne     skip                                                @ if true skip this portion of code
    movs    r6, #1                                              @ else 
    bl      initalizeInputArray                                 @ Initialize array
    bl      get_level                                           @ Get current level
    cmp     r0, #1
    beq     if_level1                                     
    cmp     r0, #2
    beq     if_level2

    cmp     r0, #3
    beq     if_level3
    cmp     r0, #4
    beq     if_level4
    cmp     r0, #5
    beq     end


if_level1:
    bl      level_1_question                                    @ Display level 1 question                         
    b       finish_level_choosing
if_level2:
    bl      level_2_question                                    @ Display level 2 question
    b       finish_level_choosing

if_level3:
    bl      level_3_question
    b       finish_level_choosing

if_level4:
    bl      level_4_question
finish_level_choosing:
    movs    r4, #3                                              @ r4 shows whether a dot (0) or dash (1) has been pressed
    movs    r5, #0                                              @ r5 shows how many interrups/seconds have passed
skip:
    bl      set_alarm                                           @ set the alarm
    wfi                                                         @ wait for alarm/gpio interrupt
    bl      user_input                                          @ insert the user input into the input array
    cmp     r4, #3                                              @ check if input sequence has been started, ie, the button was pressed
    beq     skip2                                               @ if not pressed, skip next instructions 
    movs    r4, #0                                              @ reset r4, which shows whether a dot (0) or dash (1) has been pressed
skip2:
    bl      check_level_complete
    cmp     r0, #1
    beq     level_complete
    cmp     r0, #2
    beq     restart_game
    b       Start                                               @ loop back up to start
end:
level_complete:
    bl      get_level
    cmp     r0, #1
    beq     level1_complete
	
    cmp     r0, #2
    beq     level2_complete
    cmp     r0, #3
    beq     level3_complete
    cmp     r0, #4
    beq     level4_complete

level1_complete:
    bl     level_success
    movs    r0, #2
    bl      set_level
    b      finish_level
level2_complete:
    bl     level_success
    movs    r0, #3
    bl      set_level
    b      finish_level
level3_complete:
    bl     level_success
    movs    r0, #4
    bl      set_level
    b      finish_level
level4_complete:
    bl     level_success
    movs   r0, #5 
    bl     set_level
    b      finish_level

finish_level:
    bl      gameStart
    b       Start
/*
    bl      Display_Welcome_Messages        @print welcome screen
    bl      watchdog_update
    bl      Set_Initial_LED                 @set led blue
    bl      select_level


select_level:
    //awaiting for user input in here
    wfi                                     @wait for interrupt
    //compare user input
    //if user press as "." 
    //ldr     r2, =(TIMER_BASE + TIMER_INTE_OFFSET)  obtain user input time. need to subtract registers before and after the button pressed
    //bl      detectInput
    //cmp     r0, "."                                                 
    beq       level1                          //level 1 can upgrade to level 2
    //if user press as "-"
    //ldr     r2, =(TIMER_BASE + TIMER_INTE_OFFSET)  obtain user input time. need to subtract registers before and after the button pressed
    //bl      detectInput
    //cmp     r0, "."
    beq       level2                          ////level 2 can only keep in level 2

level1:
    bl      game_continue 
    cmp     r0, #0        
    beq     game_over     
    bl      level_success  
    cmp     r0, #1        
    beq     level2  
    bl      level_1_question 
    bl      display_user_input  
    bl      watchdog_update  
    wfi                
    bl      watchdog_update
    //in need of user input          
    bl      update_remaining_lives  
    b       level1

level2:
    bl      game_continue 
    cmp     r0, #0        
    beq     game_over     
    bl      level_success  
    cmp     r0, #1        
    beq     game_won      
    bl      level_2_question
    bl      watchdog_update  
    wfi                
    bl      watchdog_update   
    //in need of user input   
    bl      display_user_input
    bl      update_remaining_lives   
    b       level2
 */

game_won:
    bl      game_won_display
    b       restart_game

game_over: 
    bl      game_over_display             
    b       restart_game


@ Get level input
level_input:
Push    {lr}                                                    @ Store the link register to the stack as we will call the init_btns subroutine

    bl      initalizeInputArray                                 @ Initialize array
    movs    r4, #3                                              @ r4 shows whether a dot (0) or dash (1) has been pressed
    movs    r5, #0                                              @ r5 shows how many interrups/seconds have passed
    
input_not_complete:
    bl      set_alarm                                           @ set the alarm
    wfi                                                         @ wait for alarm/gpio interrupt
    bl      user_input                                          @ insert the user input into the input array
    cmp     r4, #3                                              @ check if input sequence has been started, ie, the button was pressed
    beq     skip3                                               @ if not pressed, skip next instructions 
    movs    r4, #0                                              @ reset r4, which shows whether a dot (0) or dash (1) has been pressed
skip3:
    cmp     r5, #2                                              @ loop if the input is not completed
    bne     input_not_complete

// possible optmization
    cmp     r0, #1
    beq     level1
    cmp     r0, #2
    beq     level2
    cmp     r0, #3
    beq     level3
    cmp     r0, #4
    beq     level4
    cmp     r0, #5
    beq     level5

level1:
    ldr     r0, =1  
    b       level_selection_input_entered

level2:
    ldr     r0, =2  
    b       level_selection_input_entered

level3:
    ldr     r0, =3  
    b       level_selection_input_entered

level4:
    ldr     r0, =4     
    b       level_selection_input_entered

level5:
    bl      level_selection_invalid
    b       restart_game

level_selection_input_entered:

    bl      set_level                                           @ Set level to the value in r0
    bl      initalizeInputArray                                 @ Initialize array
    movs    r6, #0
    //bl      gameStart

pop     {pc}                                                @ Pop the link register from the stack to the program counter


@ Gets the user input 
user_input:
    Push    {lr}                                                @ Store the link register to the stack as we will call the init_btns subroutine

    cmp     r5, #1                                              @ if alarm interrupt has gone off once
    beq     add_space                                           @ add space to input
    cmp     r5, #2                                              @ else if alarm interrupt has gone off twice successively 
    beq     enter                                               @ input is complete
    cmp     r4, #1                                              @ if gpio interrupt returns a 1
    beq     dot                                                 @ add dot to input
    cmp     r4, #2                                              @ if gpio interrupt returns a 2
    beq     dash                                                @ add dash to input
    b       input_entered                                       @ input entered

dot:
    ldr     r0, =1                                              @ 1 = "."
    bl      detectInput                                         @ add dot to input sequence
    b       input_entered                                       @ input entered

dash:
    ldr     r0, =2                                              @ 2 = "-"
    bl      detectInput                                         @ add dash to input sequence 
    b       input_entered                                       @ input entered

add_space:
    ldr     r0, =3                                              @ 3 = " "
    bl      detectInput                                         @ add space to input sequence 
    b       input_entered                                       @ input entered 

enter:
    ldr     r0, =4                                              @ 4 = "enter"
    bl      detectInput                                         @ delete last space in input & set input to complete 
    movs    r6, #0                                              @ r6 shows whether there's a current question or not
input_entered:
    
    //bl      check_level_complete
    //cmp     r0, #1
    //beq     level_complete
    //cmp     r0, #2
    //beq     restart_game
    pop     {pc}                                                @ Pop the link register from the stack to the program counter


@ Subroutine used to setup falling-edge interrupts
init_btns:
    push    {lr}                                                @ Store the link register to the stack as we will call the init_btns subroutine   

    movs    r0, #GPIO_BTN                                       @ This value is the button pin on the PI PICO board
    bl      asm_gpio_init                                       @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #GPIO_BTN                                       @ This value is the "enter button" pin on the PI PICO board
    movs    r1, #GPIO_DIR_IN                                    @ We want this GPIO pin to be setup as an input pin
    bl      asm_gpio_set_dir                                    @ Call the subroutine to set the GPIO pin specified by r0 to state specified by r1
    movs    r0, #GPIO_BTN                                       @ This value is the button pin on the PI PICO board
    bl      asm_gpio_set_irq                                    @ Call this subroutine to enable rising and falling-edge interrupt on the pin specified by r0

    pop     {pc}                                                @ Pop the link register from the stack to the program counter

@ Enable alarm timer interrupts and set an alarm
set_alarm:
    ldr     r2, =(TIMER_BASE + TIMER_INTE_OFFSET)   @ Enable alarm timer interrupts using the (TIMER_BASE + TIMER_INTE_OFFSET) register
    movs    r1, #1
    str     r1, [r2]

    ldr     r2, =(TIMER_BASE + TIMER_TIMELR_OFFSET) @ Get the current timer count from (TIMER_BASE + TIMER_TIMELR_OFFSET) register
    ldr     r3, [r2]
    ldr     r1, =DFLT_ALARM_TIME
    add     r1, r3                                  @ Add the time delay you want to wait for to the current timer count
    ldr     r2, =(TIMER_BASE + TIMER_ALARM0_OFFSET) @ Push the updated value to (TIMER_BASE + TIMER_ALARM0_OFFSET)
    str     r1, [r2]
    bx      lr                                      @ Exit subroutine

@ Sets up the alrm_isr in the RAM vector table and enables the correct interrupt
install_alrm_isr:
    ldr     r2, =(PPB_BASE + M0PLUS_VTOR_OFFSET)    @ Get the address of the RAM vector table using the (PPB_BASE + M0PLUS_VTOR_OFFSET) register
    ldr     r1, [r2]                                
    movs    r2, #ALRM_ISR_OFFSET                    @ Store the address of the alrm_isr handler to the correct offset for ALARM0 in the vector table
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

    @ Disable pending interrupt from TIMER by writing correct value to (TIMER_BASE + TIMER_INTR_OFFSET)
    ldr     r2, =(TIMER_BASE + TIMER_INTR_OFFSET)
    movs    r1, #1
    str     r1, [r2]

    cmp     r7, #0                      @ If there is a time stored in r7, then the button is still being held
    bne     gpio_interrupt_in_progress
    cmp     r4, #3
    beq     gpio_interrupt_in_progress

    @ Add 1 to the number of iterations the timer has gone off in r5
    ldr     r3, =1
    add     r5, r5, r3

gpio_interrupt_in_progress:

    pop     {pc}                        @ Pop the link register from the stack to the program counter 

@ Sets up the gpio_isr in the RAM vector table and enables the correct interrupt
install_gpio_isr:
    ldr     r2, =(PPB_BASE + M0PLUS_VTOR_OFFSET)                @ Get the address of the RAM vector table using the (PPB_BASE + M0PLUS_VTOR_OFFSET) register
    ldr     r1, [r2]                                            
    movs    r2, #GPIO_ISR_OFFSET                                @ Store the address of the gpio_isr handler to the correct offset for GPIO in the vector table
    add     r2, r1
    ldr     r0, =gpio_isr                           
    str     r0, [r2]                                

    ldr     r2, =(PPB_BASE + M0PLUS_NVIC_ICPR_OFFSET)           @ Disable the GPIO IRQ by writing the correct value to (PPB_BASE + M0PLUS_NVIC_ICPR_OFFSET)
    ldr     r1, =8192           
    str     r1, [r2]            

    ldr     r2, =(PPB_BASE + M0PLUS_NVIC_ISER_OFFSET)           @ Enable the GPIO IRQ by writing the correct value to (PPB_BASE + M0PLUS_NVIC_ISER_OFFSET)
    ldr     r1, =8192           
    str     r1, [r2]

    bx      lr                                                  @ Exit subroutine

@ Service the pending interrupt from the GPIO
@ Returns the time difference between rising and falling edge in ms in r4
.thumb_func                                                     @ Required for all interrupt service routines
gpio_isr:
    push    {lr}                                                @ Store the link register to the stack as we will call the svc_isr routine

    ldr     r5, =0                                              @ Reset the interrupt count

    ldr     r2, =(IO_BANK0_BASE + IO_BANK0_PROC0_INTS2_OFFSET)  @ Read the interrupt status event from the (IO_BANK0_BASE + IO_BANK0_PROC0_INTS2_OFFSET) register
    ldr     r1, [r2]
    ldr     r0, =8192
    str     r0, [r2]

    ldr     r2,=GPIO_BTN_RISE_MSK
    CMP     r1, r2                                              @ Detect if it is a rising edge
    beq     rising_edge

    ldr     r2, =GPIO_BTN_FALL_MSK
    CMP     r1, r2                                              @ Detect if it is a falling edge
    beq     falling_edge
    b       end_input

rising_edge: 
    ldr     r2, =(IO_BANK0_BASE + IO_BANK0_INTR2_OFFSET)        @ Disable the pending interrupt from GPIO by writing the correct value to (IO_BANK0_BASE + IO_BANK0_INTR2_OFFSET)
    ldr     r1, =GPIO_BTN_RISE_MSK
    str     r1, [r2]

    bl      get_time_in_ms
    movs    r7, r0                                              @ Store the start time in r7

    b       end_input

falling_edge:
    ldr     r2, =(IO_BANK0_BASE + IO_BANK0_INTR2_OFFSET)        @ Disable the pending interrupt from GPIO by writing the correct value to (IO_BANK0_BASE + IO_BANK0_INTR2_OFFSET)
    ldr     r1, =GPIO_BTN_FALL_MSK
    str     r1, [r2]
    
    bl      get_time_in_ms
    movs    r1, r7                                              @ Load the start time
    bl      get_time_difference
    movs    r7, r0
    bl      watchdog_update
    
    movs    r0, r7
    movs    r7, #0                                              @ Clear the time stored in r7
    cmp     r0, #DOT                                            @ If(time < 255ms)
    blt     input_dot                                                 @   input = dot
    bge     input_dash                                                @ else
    b       end_input                                           @   input = dash

input_dot:
    ldr     r4, =1                                              @ 1 = "."
    b       end_input

input_dash:
    ldr     r4, =2                                              @ 2 = "-"

end_input:

    pop     {pc}                                                @ Exit ISR   
@ Set data alignment
.data
    .align 4
print_dot:    .asciz ".\n"
print_dash:   .asciz "-\n"
print_space:  .asciz " \n"
print_enter:  .asciz "n\n"