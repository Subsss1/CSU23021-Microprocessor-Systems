# Specify the name of the executable.
add_executable(assign01)

# Specify the source files to be compiled.
target_sources(assign01 PRIVATE assign01.c assign01.S)

# Pull in commonly used features.
target_link_libraries(assign01 PRIVATE pico_stdlib)

# Create map/bin/hex file etc.
pico_add_extra_outputs(assign01)

# Add the URL via pico_set_program_url.
apps_auto_set_url(assign01)
