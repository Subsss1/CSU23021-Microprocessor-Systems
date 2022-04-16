# Specify the name of the executable.
add_executable(lab09)

# Specify the source files to be compiled.
target_sources(lab09 PRIVATE lab09.c lab09.S)

# Generate the PIO header file from the PIO source file.
pico_generate_pio_header(lab09 ${CMAKE_CURRENT_LIST_DIR}/lab09.pio)

# Pull in commonly used features.
target_link_libraries(lab09 PRIVATE pico_stdlib hardware_pio hardware_adc)

# Create map/bin/hex file etc.
pico_add_extra_outputs(lab09)

# Add the URL via pico_set_program_url.
apps_auto_set_url(lab09)
