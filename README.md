# Font Awesome Minimiser (treeshaker)

Font Awesome is great, but also very large. The 'free version' of the SVG JS file is now well over 1MB, and the 'PRO version' much longer.

Why? Becasue they contain thousands of SVG icon definitions.

This script minimises (treeshakes) Font Awesome 5 down to about 30K (compressed) by just selected the icons you use.

* It works with both the normal and minimised versions of the Font Awesome SVG Javascript.

* It also works with both the free and pro versions.

It is written in Perl. You may need to install some perl libraries for it to work. It quite simple, just
```cpan install YAML```

Or, you can copy the regular expression it uses into the language of your choice.

## What it does

It takes the Javascript SVG Font Awesome file ( `all.js` or `all.min.js`), either the free or the paid for version.

The original files are big, more than 370K (free) / 870K (paid for) compressed, as it contains thousands of SVG icon definitions.

Most websites only use a handful, so make a list of the ones you use, and this little script removes the remainder, leaving you with the SVG definitions you use, together with the actual javascript to use them. This makes about 35K compressed, more if you 'minimise' it as well. 

## How to use

1. Rename `config.yaml.example` to `config.yaml`.

2. Edit the location of the "in" file. For the free version, use its CDN url (an example is given).

3. Edit the the location of your treeshaken "out" file.

4. Edit the list of icons ... just the icons you use.

5. `perl ./fontawesome.pl`

6. If you get a missing library error, try  (e.g. for the YAML module) ```cpan install YAML```

