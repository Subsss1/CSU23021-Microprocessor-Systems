# Specify the name of the executable.
add_executable(lab10)

# Specify the source files to be compiled.
target_sources(lab10 PRIVATE lab10.c lab10.S)

# Pull in commonly used features.
target_link_libraries(lab10 PRIVATE pico_stdlib)

# Create map/bin/hex file etc.
pico_add_extra_outputs(lab10)

# Add the URL via pico_set_program_url.
apps_auto_set_url(lab10)
