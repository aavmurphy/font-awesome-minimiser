# Font Awesome V5 Minimiser (treeshaker)

## Introduction

Font Awesome is great, but also very large. The 'free version' of the SVG JS file is now well over 1MB, and the 'PRO version' is nearly 5.7MB.

Even minimised (webserver's do this behind the scenes) they are still pretty large files, especially for mobile data users.

Why so large? Because it contain thousands of SVG icon definitions.

This script minimises (treeshakes) Font Awesome 5 down to about 30K (compressed) by removing the vast majority of icons that you don't use, and just keeping the ones you do.

* It works with both the normal and minimised versions of the Font Awesome SVG Javascript.

* It works with both the free and pro versions.

Version  |Number of Icons|Size   |Compressed Size|
---------|--------------:|------:|--------------:|
Free     |1,598          |1,182 K|428 K|
Pro      |7,848          |5,700 K|1,900 K|
Minimised|34             |82 K   |25 K|

## Install

It is written in Perl. You may need to install some perl libraries for it to work. Its quite simple, just

```
cpan install YAML
cpan install IO::All
```

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

1. Rename `config.yaml.example` to `config.yaml`, and edit it.

2. Set the location of the "svg js" file. For the free version, use its CDN url (an example is given). For the 'Pro' version, it might be in `node_modules/@fontawesome`

3. Set the the location of your treeshaken "out" file.

4. Edit the list of the icons in your project ... just the ones you use :)

5. (Optional) Enter the directories and extensions your project uses. The script does a ```find``` then ```grep``` to look for ```fa-icon-name-classes```

6. `perl ./fontawesome.pl`

7. If you get a missing library error, try  (e.g. for the YAML module) ```cpan install YAML```

