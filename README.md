# font-awesome-minimiser
Minimise (treeshake) Font Awesome 5 down to about 30K by just selected the icons you use

This should work with any reasonable version of Perl.

Or you can copy the regular expression into the language of your choice.

## What it does

It takes the Javascript SVG Font Awesome file ( `all.js` ), either the free or the paid for version (i.e. not `all-min.js` !).

This file is big, more than 300K compressed, as it contains thousands of SVG icon definitions.

Most websites only use a handful, so make a list of the ones you use, and this little script removes the remainder, leaving you with the SVG definitions you use, together with the actual javascript to use them. This makes about 30K compressed, more if you 'minimise' it as well. 

## How to use

1. edit the list of icons in the file... include your favourite icons

2. edit the location of the "in" and "out" files

3. `perl fontawesome.pl`
