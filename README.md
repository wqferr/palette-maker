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
### Basic Interface and Commands ###
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
change the value of the selected cell. A larger display of the colour can be
found above the sliders. The sliders can also be controlled solely
with he keyboard using the +/- keys with different modifier keys:

* `ALT` for H
* `CTRL` for S
* None for V

You can also reset the S and V sliders to their initial values (0 and 1
respectively) by pressing `del`.

## Basic Cell Interaction ##
By holding different modifiers while using the arrow keys, you can make gradual
transitions between colours. The basic commands are:

* `CTRL`: Increase brightness
* `CTRL + SHIFT`: Decrease brightness
* `ALT`: Increase saturation
* `ALT + SHIFT`: Decrease saturation
* `CTRL + SHIFT + ALT`: Copy colour

The increase commands take a value `x` and take it to `0.1 + (1.1*x)`.

Similarly, the decrease commands take a value `x` and take it to
`(x-0.1) / 1.1`.

The copy command simply copies the H, S and V values into the next cell.

The best way to understand these commands is to just mess around with some
colours and see what happens. Go ahead, it's not hard!

## Colour Interpolation ##
One of the most powerful tools available in PaletteMaker. Suppose your sprite
has reds and blues, but you need some intermediate tones. You can set the first
cell to red, leave a few white cells in the same row or column, then set a blue
cell.
After this setup, select one cell, hold `CTRL + ALT` and press the arrow key in
the direction of the other one.

Like magic, each cell inbetween is set to gradual tones between the two colours!

## Colour Mixing ##
This could be useful for getting intermediate tones given two colours if the
cells which contain these tones are not in the same row nor column, or for
mixing more than two colours.

If you hold `CTRL` while left clicking a cell, the selected cell will gradually
approach the clicked cell's colour.

## Other details ##
### Saving ###
Pressing `CTRL + S` will dump the resulting palette into a 16x16 image, with a
1 to 1 correlation cell-pixel (i.e. each cell dumps its color into the pixel
in the corresponding position). If an argument was given to the program, it will
se that name, otherwise, it will save to `palette.png`. *Note that the name
given to the program does _not_ affect the file format.* If given the file name
"image.jpg", the image will be saved to that file with `png` encoding.