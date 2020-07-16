# Font Awesome Minimiser (treeshaker)

Font Awesome is great, but also very large. The 'free version' of the SVG JS file is now well over 1MB, and the 'PRO version' is nearly 5.7MB.

Why? Becasue they contain thousands of SVG icon definitions.

This script minimises (treeshakes) Font Awesome 5 down to about 30K (compressed) by just selected the icons you use.

* It works with both the normal and minimised versions of the Font Awesome SVG Javascript.

* It also works with both the free and pro versions.

It is written in Perl. You may need to install some perl libraries for it to work. It quite simple, just
```cpan install YAML```
```cpan install IO::All```

Or, you can copy the regular expression it uses into the language of your choice.

## What it does

It takes the Javascript SVG Font Awesome file ( `all.js` or `all.min.js`), from either the free or the paid for version.

The original files are big, even compressed, as they contain thousands of SVG icon definitions.

Most websites only use a handful, so make a list of the ones you use, and this little script removes the remainder, leaving you with the SVG definitions you use, together with the actual javascript to use them. This makes about 35K compressed, more if you 'minimise' it as well. 

Step 1 : Get a list of icons, and optionally, grep your code for them.

Step 2 : List the items (by code) and (by yaml list) so you can check

Step 3 : Group your icons by style (duotone, brands etc.)

Step 4 : Splits the FA javascript into sections (light, regular, brands, duotone), then discards non-matching icon definitions in each section

Step 5 : Save to a file

## How to use

1. Rename `config.yaml.example` to `config.yaml`.

2. Edit the location of the "in" file. For the free version, use its CDN url (an example is given).

3. Edit the the location of your treeshaken "out" file.

4. Edit the list of icons ... just the icons you use.

4.1 (Optional) Enter the directories and extensions your project uses, to do a ```find``` then ```grep``` to look for ```fa-classes```

5. `perl ./fontawesome.pl`

6. If you get a missing library error, try  (e.g. for the YAML module) ```cpan install YAML```

