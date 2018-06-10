import os
import glob
from zipfile import ZipFile
from itertools import chain
from subprocess import call

def main():
    create_love()
    create_exe()
    create_zips()


def create_love():
    create_zip('dist/palette-maker.love',
        glob.iglob('./*.lua'),
        glob.iglob('./**/*.lua'),
        glob.iglob('./**/*.png'),
        glob.iglob('./LICENSE.txt'))


def create_exe():
    with open('dist/palette-maker.exe', 'w') as out:
        call([
            'cat',
            '/mnt/c/Program Files/LOVE/love.exe',
            'dist/palette-maker.love'],
            stdout=out)


def create_zips():
    create_zip('dist/palette-maker-exe.zip',
        glob.iglob('dist/*.dll'),
        glob.iglob('dist/*.exe'),
        glob.iglob('dist/license.txt'))
    create_zip('dist/palette-maker-love.zip', 
        glob.iglob('dist/*.love'),
        glob.iglob('dist/license.txt'))


def create_zip(fname, *files):
    with ZipFile(fname, 'w') as zf:
        for file in chain(*files):
            zf.write(file)

if __name__ == '__main__':
    main()