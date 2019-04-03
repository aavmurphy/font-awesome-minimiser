#!/usr/bin/perl

use IO::All -utf8;
use YAML;
use Data::Dumper;

use strict;
use warnings;

# ----------------------------------------------------------------------------------------------------------------------------------------
#
# (C) Andrew Murphy / www.walkingclub.org.uk
#
# No warranty... :)
#
# edit the params in config.yaml
#
# how to install perl modules
#	cpanm YAML::XS
#
# run the script
#	perl ./fontawesome.pl
#
# ----------------------------------------------------------------------------------------------------------------------------------------

my $config = YAML::LoadFile( 'config.yaml' );

## this is your fontawesome 5 ( free or pro ) all.js file
my $IN_FONT_AWESOME		= $config->{SVG_JS_FILES}->{IN};

## this is your shrunk output file
my $OUT_TREESHAKER_JS	= $config->{SVG_JS_FILES}->{OUT};

$IN_FONT_AWESOME = "https://use.fontawesome.com/releases/v5.7.0/js/all.js" ;
$OUT_TREESHAKER_JS = "/tmp/andrew.js";

## these are the icons you want to KEEP
my @ICONS	 			= @{ $config->{ICONS} };

## ------------------------------------------------------------------------------------------------------------------------------------------

warn "Font Awesome Tree Shaker\n";

## convert icon list to a hash (which also de-duplicates it)
my %icons = map { $_, 1 } @ICONS;

my @icons = sort keys %icons;
warn ". icons: " . scalar( @icons ) ."\n";
warn ". . @icons\n";

##
my $javascript;

warn ". svg js\n";

if ( $IN_FONT_AWESOME !~ m#^https?://#i )
	{
	warn ". . file : $IN_FONT_AWESOME\n";
	$javascript <  io( $IN_FONT_AWESOME );
	}
else
	{
	warn ". . url : $IN_FONT_AWESOME\n";
	$javascript < io( $IN_FONT_AWESOME )->http;
	}

die "missing svg javascript: $javascript" if ! $javascript or length( $javascript ) < 10000 ;

warn ". treeshake\n";

warn sprintf ". in  : %8d K\n", length( $javascript ) / 1024;

## nasty regex
## 	/e allow whitespace in regex
##	/g global
##	/m ^ and $ matches on each line
##
## note the comma at the end
##	so will not match the last icon in each icon list (e.g. yen-sign), so the js list will not have a dangling comma at the end!

sub remove_icons
	{
	my ( $svg_line, $icon_name ) = @_;

	return $icons{ $icon_name } ? $svg_line : '';
	};

## minified 
$javascript	=~ s/\b([-\w]+):\[\d+,\d+,\[[^\]]*\],[^\]]+\],/ remove_icons( $&, $1 ) /eg;
$javascript	=~ s/"([-\w]+)":\[\d+,\d+,\[[^\]]*\],[^\]]+\],/ remove_icons( $&, $1 ) /eg;

## normal 
$javascript	=~ s/^\s+"([-\w]+)": \[\d+, \d+, \[[^\]]*\], [^\]]+\],\s*?\n/ remove_icons( $&, $1 ) /emg;

##
$javascript > io( $OUT_TREESHAKER_JS );

warn sprintf ( ". out : %8d K : $OUT_TREESHAKER_JS \n" , ( -s $OUT_TREESHAKER_JS ) / 1024 );

