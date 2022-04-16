// Must declare the main assembly entry point before use.
void main_asm();


/**
 * @brief LAB #08 - TEMPLATE
 *        Main entry point for the code - calls the main assembly
 *        function where the body of the code is implemented.
 * 
 * @return int      Returns exit-status zero on completion.
 */
int main() {

    // Jump into the main assembly code subroutine.
    main_asm();

    // Returning zero indicates everything went okay.
    return 0;
}
