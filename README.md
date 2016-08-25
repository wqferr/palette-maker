# PaletteMaker #
Made using LÖVE 0.10.1

## Overview ##
### What is this? ###
This is an application to help make colour palettes, targeted mainly at pixel
artists.

---

## Pretty important introduction to HSV ##
If you aren't already familiar with it, you could try to read the
[wikipedia article](https://en.wikipedia.org/wiki/HSL_and_HSV) on the HSV color
space. If That was too much math and too little color, here's the TL;DR:

HSV is an alternative to the
[RGB color space](https://en.wikipedia.org/wiki/RGB_color_model) which tries to
mimic the human concept of "similar colours". That means that two colours will
differ little in our perception if they have similar HSV values.

Now on to each of the three letters:

* H:

    Stands for "hue". Basically, "which part of the rainbow" that colour is in.

    Usually represented from 0-359 as if the rainbow was weirdly distorted into
    a circle and the hue is the angle that represents the colour
    (blame the ones who came up with this, I just follow conventions).

* S:

    Stands for "saturation". The less saturated a colour is, the closer it is
    to white.

    Values range from 0 to 1.

* V:

    Stands for "value". Equivalent to brightness in the sense that the lower
    the value, the darker the color.

#### Some notes on HSV ####

* If any color has 0 saturation, it will be somewhere along the grayscale,
with the determining factor being the value of the color.

* If any color has 0 value, it will be black independently of hue or saturation.

Now, onto the application.

---

### How do I install it? ###
If you already have LÖVE 0.10.1 or higher installed, you can:

* Download the repo and run the source code
* [Download the .love file provided](https://gitlab.com/wqferr/palette-maker/tags)

If not, and you're on Windows, you can
[download the zip](https://gitlab.com/wqferr/palette-maker/tags) containing a
32 bit exe and required libs.

If you're not on Windows or are too paranoid to donwload an exe, you'll have to
install LÖVE.

### How do I run it? ###
Just run the exe, or use LÖVE as you normally would.
The .dll files zipped with the .exe are required for the app to run. If you wish
to run it from somewhere else, you could always create a shortcut.

### OK, I opened it. Now what? ###
You'll see a mostly black screen with (probably) just one square. That's the
palette selection screen. The one white square you see is the button to create
a new palette, and if there were any saved palettes in the save directory, the
app would list them side by side with their respective names underneath. Click
on the palette you want to edit, or the `new` button to create a new palette.

And now that you've entered the real application, I expect you to say something
along the lines of:

## TOO MANY BUTTONS, HALP ##
### Basic Interface and Commands ###
You can press <kbd>H</kbd> in edit mode to get a cheatsheet, but here comes a
more detailed explanation:

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
with he keyboard using the <kbd>+</kbd>/<kbd>-</kbd> keys with different modifier
keys:

* <kbd>ALT</kbd> for H
* <kbd>CTRL</kbd> for S
* None for V

You can also reset the S and V sliders to their initial values (0, i.e. black)
by pressing <kbd>DEL</kbd>. Note that this operation does not reset the hue to 0,
mainly because:

1. That doesn't change the RGB values at all
2. That could be useful when combined to other operations

## Basic Cell Interaction ##
By holding different modifiers while using the arrow keys, you can make gradual
transitions between colours. The basic commands are:

* <kbd>CTRL</kbd>: Increase brightness
* <kbd>CTRL</kbd> + <kbd>SHIFT</kbd>: Decrease brightness
* <kbd>ALT</kbd>: Increase saturation
* <kbd>ALT</kbd> + <kbd>SHIFT</kbd>: Decrease saturation
* <kbd>CTRL</kbd> + <kbd>SHIFT</kbd> + <kbd>ALT</kbd>: Copy colour

The increase commands take a value `x` and take it to `0.1 + (1.1*x)`.

Similarly, the decrease commands take a value `x` and take it to
`(x-0.1) / 1.1`.

The copy command simply copies the H, S and V values into the next cell.

The best way to understand these commands is to just mess around with some
colours and see what happens. Go ahead, it's not hard!

---

Now that you've gotten used to the basic commands you can perform, we can
talk about cool stuff:

## Colour Interpolation ##
One of the most powerful tools available in PaletteMaker. Suppose your sprite
has reds and blues, but you need some intermediate tones. You can set the first
cell to red, leave a few white cells in the same row or column, then set a blue
cell.
After this setup, select one cell, hold <kbd>CTRL</kbd> + <kbd>ALT</kbd> and press
the arrow key in the direction of the other one.

Like magic, each cell inbetween is set to gradual tones between the two colours!

## Colour Mixing ##
This could be useful for getting intermediate tones given two colours if the
cells which contain these tones are not in the same row nor column, or for
mixing more than two colours.

If you hold <kbd>CTRL</kbd> while left clicking a cell, the selected cell will
gradually approach the clicked cell's colour.

---

## Other details ##
### Returning to Palette Selection ###
***WILL DELETE UNSAVED CHANGES WITHOUT WARNING***

If you wish to return to the palette selection screen, you can press
<kbd>ESC</kbd>, but be warned that it will _***not***_ prompt you even if there
are unsaved changes.

### Changing the Palette Name ###
While in edit mode, you'll see a rectangle above the cell grid with some text in it.
That is the palette name, that will also translate to the output file. You can edit
it by clicking anywhere inside the rectangle. After you're done, press <kbd>return</kbd>
or <kbd>enter</kbd> to confirm the name.

### The Save Directory ###
Above the palette name you'll see a file path ending in `palette-maker`. That's the
directory palettes can be saved to or loaded from. **Please note I do not control this,**
**and I cannot make it so it saves to any directory you want.** It may work on some
systems but for now I have not been able to get it right on any more than 1 at once.

### Saving ###
Pressing <kbd>CTRL</kbd> + <kbd>S</kbd> will dump the resulting palette into a
16x16 png image, with each cell mapping to the pixel in its corresponding position.

### Reading ###
The app will recognize any files that follow the criteria:

1. They must be in the app save directory
2. They must have the `.png` extension
3. They must have a png encoded image in them
4. The image they contain must be 16x16 pixels

If your file follows all of the above, then it should appear as a thumbnail in the palette
selection screen.

## Who are you anyway? ##
I'm a Computer Sciences student at USP (University of São Paulo, Brazil), and
aspirant game designer and developer. If need be, you may email me at
`wqferr@gmail.com`
