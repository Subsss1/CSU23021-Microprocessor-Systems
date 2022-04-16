# Specify the name of the executable.
add_executable(ws2812_rgb)

# Specify the source files to be compiled.
target_sources(ws2812_rgb PRIVATE ws2812_rgb.c)

# Generate the PIO header file from the PIO source file.
pico_generate_pio_header(ws2812_rgb ${CMAKE_CURRENT_LIST_DIR}/ws2812.pio)

# Pull in commonly used features.
target_link_libraries(ws2812_rgb PRIVATE pico_stdlib hardware_pio)

# Create map/bin/hex file etc.
pico_add_extra_outputs(ws2812_rgb)

# Add the URL via pico_set_program_url.
apps_auto_set_url(ws2812_rgb)
