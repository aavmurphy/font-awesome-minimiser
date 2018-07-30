#!/usr/bin/perl

use strict;
use warnings;

# ----------------------------------------------------------------------------------------------------------------------------------------
#
# (C) Andrew Murphy / www.walkingclub.org.uk
#
# No warranty... :)
#
# edit the params in the top section, then
# perl ./fontawesome.pl
#
# ----------------------------------------------------------------------------------------------------------------------------------------

## this is your fontawesome 5 ( free or pro ) all.js file
my $IN_FONT_AWESOME		= "$ENV{SWC}/swc/node_modules/\@fortawesome/fontawesome-pro/js/all.js";

## this is your shrunk ooutput file
my $OUT_TREESHAKER_JS	= "$ENV{SWC}/swc/public_html/site/font-awesome-tree-shaker.js";

## these are the icons you want to KEEP
my @ICONS	 = qw( 

	__javascript__

	comment-alt-lines
	trash-alt
	edit
	external-link-alt
	home
	info-circle
	crown
	user
	sort
	amazon
	github
	twitter

	__templates__

	cloud-download-alt
	comment-alt-lines
	desktop
	edit
	external-link-alt
	flickr
	font
	home
	info-circle
	print
	star
	tag
	trash-alt
	twitter
	youtube

	__html__

	comment-alt-lines
	edit
	wrench
	external-link-alt
	facebook
	location
	home
	info-circle
	arrows-alt
	map
	arrows-alt-h
	compress
	arrows-alt-v
	print
	graduation-cap
	twitter
	video
	images

	__html_to_do__

	spinner
	home
	external-link-alt
	commenting-o
	cloud-download-alt
	
	);

## ------------------------------------------------------------------------------------------------------------------------------------------

use IO::All -utf8;

##
warn "Font Awesome Tree Shaker\n";

## e.g. (fa-one|fa-two)
my @icons = sort grep ! /__/ , @ICONS ;
my %unique = map { $_, 1 } @icons;

my $svg_list = '(' . join( "|", sort keys %unique ) . ')'; 

warn ". icon list: $svg_list\n";

##
my $javascript = io( $IN_FONT_AWESOME )->slurp;

warn sprintf ". in  : %8d K\n", ( -s $IN_FONT_AWESOME) / 1024;

## nasty regex
## 	/x allow whitespace in regex
##	/g global
##	/m ^ matches on each line
##
## so remove any line (the ^...\n ) matching the icon list linesa(  [2 spaces] "fa-icon-name": .... \n)
##	except ones matching (fa-one fa-two) etc (see above)
##	(?:xxx) means not followed by xxx
##		here, xxx is a "group" of icons names
## 
## note the comma at the end
##	so  will not match the last icon in each icon list (e.g. yen-sign), so the js list will not have a dangling comma at the end!

$javascript =~ s# ^ \s\s" (?!$svg_list") [^"]* ":\s [^\n]* ,\n ##xmg,

$javascript > io( $OUT_TREESHAKER_JS );

warn sprintf ". out : %8d K\n" , ( -s $OUT_TREESHAKER_JS ) / 1024;

