# LAB05 NOTES

See [LAB #05](https://tcd.blackboard.com/webapps/assignment/uploadAssignment?content_id=_2128951_1&course_id=_71874_1&group_id=&mode=cpview) on the module Blackboard site for details of this lab.

Example code for this lab has been tested on both the Raspberry Pi Pico hardware platform as well as the Woki online simulator for the Raspberry Pi Pico. There are some differences between using the Wokwi online simulator and the real Raspberry Pi Pico hardware however.

The `wokwi-pi-pico` component environment option in the `diagram.json` file may also need to be set to use `arduino-community` for the code to work correctly (proably a quirk of the simulator).

To run the demo on the simulator, rename the default `sketch.ino` file to be called `lab05.c` and overwrite the default content with the content of the `lab05.c` file in this repository. Create a new file and call it `lab05.S` (capital S in the extension is important) for the assembly code. Finally, make sure to update the `diagram.json` if required (but do not change the name).
