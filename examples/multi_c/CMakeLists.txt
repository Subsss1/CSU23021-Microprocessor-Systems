add_executable(multi_c)

target_sources(multi_c PRIVATE multi_c.c)

# Pull in pico_stdlib for common features and pico_multicore
target_link_libraries(multi_c PRIVATE pico_stdlib pico_multicore)

# create map/bin/hex file etc.
pico_add_extra_outputs(multi_c)

# add url via pico_set_program_url
apps_auto_set_url(multi_c)
