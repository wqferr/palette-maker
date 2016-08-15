# PaletteMaker #
Made using LÖVE 0.10.1

## Overview ##

### What is this? ###
This is an application to help make colour palettes, targeted mainly at pixel
artists.

### How do I install it? ###
If you already have LÖVE 0.10.1 or higher installed, you can:
* Download the repo and run the source code
* Download the .love file provided
If not, and you're on Windows, you can download the 32 bits exe provided.
If you're not on Windows or are too paranoid to donwload an exe, you'll have to
install LÖVE.

### How do I run it? ###
Just run the exe, or use LÖVE as you normally would. If an argument is provided,
it will try to import it (WILL crash if exists and not a 16x16 image).
If the file doesn't exist, it will remember the given name as the output file
when the save command is given.
Furthermore, if no argument is given, it will NOT import any palette, and the
output file will be `palette.png`.

## TOO MANY BUTTONS, HALP ##
All the commands are listed below the grid, but here's a more detailed
explanation:

### Grid & Selection ###
The software is made to manipulate a 16x16 grid of cells. Out of these 256
cells, only 1 is selected at a time, marked by a white frame. The selected cell
is the one that will be manipulated directly, or interacted through other
commands. The selection can be moved by left clicking on a cell, or by using
the arrow keys.

### Sliders ###
On the right side of the window, you'll see 3 sliders representing the 3
components of the HSV encoding. By changing the values of these sliders, you'll
change the value of the selected cell. The sliders can also be controlled solely
with the keyboard using the +/- keys with different modifier keys:

* ALT for H
* CTRL for S
* None for V

More help coming soon...