# Specify the name of the executable.
add_executable(lab06)

# Specify the source files to be compiled.
target_sources(lab06 PRIVATE lab06.c lab06.S)

# Pull in commonly used features.
target_link_libraries(lab06 PRIVATE pico_stdlib pico_multicore)

# Create map/bin/hex file etc.
pico_add_extra_outputs(lab06)

# Add the URL via pico_set_program_url.
apps_auto_set_url(lab06)
