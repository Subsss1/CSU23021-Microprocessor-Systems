# LAB01 NOTES

See [LAB #01](https://tcd.blackboard.com/webapps/assignment/uploadAssignment?content_id=_2126646_1&course_id=_71874_1&group_id=&mode=cpview) on the module Blackboard site for details of this lab.

Example code for this lab has been tested on both the Raspberry Pi Pico hardware platform as well as the Woki online simulator for the Raspberry Pi Pico. There are some differences between using the Wokwi online simulator and the real Raspberry Pi Pico hardware however.

The `wokwi-pi-pico` component environment option in the `diagram.json` file may also need to be set to use `arduino-community` for the code to work correctly (proably a quirk of the simulator).

To run the demo on the simulator, rename the default `sketch.ino` file to be called `lab01.c` and overwrite the default content with the content of the `lab01.c` file in this repository. Also, make sure to update the `diagram.json` (but do not change the name).
