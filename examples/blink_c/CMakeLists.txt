# Specify the name of the executable.
add_executable(blink_c)

# Specify the source files to be compiled.
target_sources(blink_c PRIVATE blink_c.c)

# Pull in commonly used features.
target_link_libraries(blink_c PRIVATE pico_stdlib)

# Create map/bin/hex file etc.
pico_add_extra_outputs(blink_c)

# Add the URL via pico_set_program_url.
apps_auto_set_url(blink_c)
