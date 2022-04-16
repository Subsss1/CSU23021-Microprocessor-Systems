add_executable(hello_c)

target_sources(hello_c PRIVATE hello_c.c)

# Pull in our pico_stdlib which pulls in commonly used features
target_link_libraries(hello_c PRIVATE pico_stdlib)

# create map/bin/hex file etc.
pico_add_extra_outputs(hello_c)

# add url via pico_set_program_url
apps_auto_set_url(hello_c)
