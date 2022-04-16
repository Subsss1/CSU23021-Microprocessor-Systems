# Specify the name of the executable.
add_executable(blink_asm)

# Specify the source files to be compiled.
target_sources(blink_asm PRIVATE blink_asm.c blink_asm.S)

# Pull in commonly used features.
target_link_libraries(blink_asm PRIVATE pico_stdlib)

# Create map/bin/hex file etc.
pico_add_extra_outputs(blink_asm)

# Add the URL via pico_set_program_url.
apps_auto_set_url(blink_asm)
