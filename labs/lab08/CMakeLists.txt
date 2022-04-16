# Specify the name of the executable.
add_executable(lab08)

# Specify the source files to be compiled.
target_sources(lab08 PRIVATE lab08.c lab08.S)

# Pull in commonly used features.
target_link_libraries(lab08 PRIVATE pico_stdlib)

# Create map/bin/hex file etc.
pico_add_extra_outputs(lab08)

# Add the URL via pico_set_program_url.
apps_auto_set_url(lab08)
