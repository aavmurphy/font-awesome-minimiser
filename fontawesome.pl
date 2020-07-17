#!/usr/bin/perl

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

# perl 7 ready
use utf8;
use strict;
use warnings;
use open qw(:std :utf8);
#no feature qw(indirect);
use feature qw(signatures);
no warnings qw(experimental::signatures);

# -----------------------------------------------------------------------------------

#
our $CONFIG = "config.yaml";

#
our %STYLES = (
	fab	=> 'brand',
	fal	=> 'light',
	fas	=> 'solid',
	fad	=> 'duotone',
	far	=> 'regular',
	);
	
our $IGNORE_REGEX = '(fa-xl|fa-lg)';

# -----------------------------------------------------------------------------------

package FA_MINIMISER;
	{
	use IO::All -utf8;
	use YAML;
	use Data::Dumper;

	sub new( $class )
		{ 
		warn "Font Awesome Minimiser\n";
		warn "----------------------\n";

		bless {}, $class;
	 	}

	sub read_yaml( $self )
		{
		warn "read yaml: $CONFIG\n";

		$self->{config} = YAML::LoadFile( $CONFIG );
		}

	sub read_js ( $self )
		{
		my $in_js  = $self->{config}->{SVG_JS_FILES}->{IN};
		
		if ( $in_js !~ m#^https?://#i )
			{
			warn "read svg js - file: $in_js\n";
			$self->{javascript} =  io( $in_js )->slurp;
			}
		else
			{
			## e.g. https://use.fontawesome.com/releases/v5.14.0/js/all.js
			warn "get svg js - url: $in_js\n";
			$self->{javascript} = io( $in_js )->get->content;
			}

		warn sprintf ". in  : %8d K\n", length( $self->{javascript} || ''  ) / 1024;

		die "missing svg javascript" if ! $self->{javascript} or length( $self->{javascript} ) < 10000 ;
		}

	sub find ( $self )
		{
		warn "grep the repo for fa icons\n";

		$self->{find_icons} = {};

		warn ". use find to get a list of files\n";

		my $dirs	= $self->{config}->{FIND_DIRS} || [];
		my $exts	= $self->{config}->{FIND_EXTENSIONS} || [];

		my $dir_list = join " ", @{ $dirs };
		my $ext_regex	= join '\|', @{ $exts } ;

		$ext_regex =~ s/\./\\./g;

		my $cmd		= qq# find $dir_list -type f -iregex ".*\\($ext_regex\\)" | xargs grep -E "\\bfa\[sbdrl\]\\sfa-" #;
 
		warn ". . .cmd: $cmd\n";

		my @lines	= qx( $cmd );

		warn ". lines matched: " . scalar( @lines ) . "\n";

		my $text = "@lines";

		$text =~ s/fa-(xl|lg|fw)//g;

		my @matches = ( $text =~ m#fa[sbdrl]\s+fa-[\w\d\-]+#g );
	
		warn ". icons matches: " . scalar( @matches ) . "\n";

		foreach my $match ( @matches )
			{
			my ($style, $fa_name) = split /\s+/, $match, 2 ;
			$fa_name =~ s/fa-//;

			$self->{find_icons}{ "$style $fa_name"} = 1; # e.g. fab twitter
			}
		}

	sub merge_find_list ( $self )
		{
		warn "merge yaml and find icon lists together\n";

		## list icons
		my @list_icons = $self->{config}{ICONS} ?  @{ $self->{config}{ICONS} } : ();

		## convert to a hash (which also de-duplicates it)
		map { $self->{list_icons}{ $_ } = 1 } @list_icons;

		## merge together
		my %all_icons = ( %{ $self->{list_icons} }, %{ $self->{find_icons} } ); 

		## store, and pivot for printing
		$self->{all_icons} = {};

		my %print_icons =  ();

		foreach my $icon ( keys %all_icons )
			{
			my ( $style, $name ) = split / /, $icon ; 
		
			$self->{all_icons}{ $style }{ $name } = 1;

			$print_icons{ "$name $style" } =  "$style $name";
			}

		## print 'em out
		warn sprintf ( ". %-27s %5s %5s\n", 'icons', 'yaml', 'find' );

		foreach my $i ( sort keys %print_icons )
			{
			my $icon = $print_icons{ $i } ;

			warn sprintf ( ". . %-25s %5s %5s\n", $icon, ( $self->{list_icons}{ $icon } ? 'x' : ' ' ), ( $self->{find_icons}{ $icon } ? 'x' : ' ' ) );
			}
		}

	sub minimise  ( $self )
		{
		warn "treeshake\n";

		##
		warn ". icons to keep\n";
		
		foreach my $k ( sort keys %{ $self->{all_icons}} )
			{
			my @style_icons = keys %{ $self->{all_icons}{ $k } };

			warn sprintf( ". . $k : %4d : %s\n", scalar( @style_icons ), join (" ", sort @style_icons) );
			}

		## is the lib normal or minimised ?
		$self->{is_fa_js_minimised} = ( $self->{javascript} =~ /bunker/ ) ? 0 : 1;

		warn ". is fa js minimised : $self->{is_fa_js_minimised}\n";

		## split the lib into (preamble) brands solid regular light duotone
		warn ". the lib is in sections : preamble, n x svg definitions, js code\n";

		my @bits = split /(?=use strict)/, $self->{javascript} ;
		warn ". . split fa lib in to bits: " . scalar( @bits ) . " (want 5=free or 7=pro)\n";

		die "something has changed in this version (no. of bits)" if @bits != 7 and @bits != 5 ; ## free or pro version

		warn ". remove unwanted definitions\n";

		foreach my $i ( 0 .. $#bits )
			{
			my $js = $bits[ $i ];

			$self->{javascript_small } .= (  $i == 0 || $i == $#bits ) ? $js :  $self->minimise_bit ( $js  );
			}
		}

	## nasty regex
	## 	/e allow whitespace in regex
	##	/g global
	##	/m ^ and $ matches on each line
	##
	## note the comma at the end
	##	so will not match the last icon in each icon list (e.g. yen-sign), so the js list will not have a dangling comma at the end!

	## brand
	##  "twitter": [512, 512, [], "f099", "M459.37 151.716c.325 4.548.325 9.097.325 13.645 0 138.72-105.583 298.558-298.558 298.558-59.452 0-114.68-17.219-161.137-47.106 8.447.974 16.568 1.299 25.34 1.299 49.055 0 94.213-16.568 130.274-44.832-46.132-.975-84.792-31.188-98.112-72.772 6.498.974 12.995 1.624 19.818 1.624 9.421 0 18.843-1.3 27.614-3.573-48.081-9.747-84.143-51.98-84.143-102.985v-1.299c13.969 7.797 30.214 12.67 47.431 13.319-28.264-18.843-46.781-51.005-46.781-87.391 0-19.492 5.197-37.36 14.294-52.954 51.655 63.675 129.3 105.258 216.365 109.807-1.624-7.797-2.599-15.918-2.599-24.04 0-57.828 46.782-104.934 104.934-104.934 30.213 0 57.502 12.67 76.67 33.137 23.715-4.548 46.456-13.32 66.599-25.34-7.798 24.366-24.366 44.833-46.132 57.827 21.117-2.273 41.584-8.122 60.426-16.243-14.292 20.791-32.161 39.308-52.628 54.253z"],
	## normal  - not the second [ "", "" ] group
	## "map-marker-slash": [640, 512, [], "f60c", ["M157.4 89.88A191.85 191.85 0 0 1 320 0c106 0 192 86 192 192 0 46.83-9.88 73.25-49.83 133.43zM300.8 502.4a24 24 0 0 0 38.4 0c18.6-26.69 35.23-50.32 50.14-71.47L131.47 231.62c10.71 52.55 50.15 99.78 169.33 270.78z", "M3.37 31.45L23 6.18a16 16 0 0 1 22.47-2.81L633.82 458.1a16 16 0 0 1 2.82 22.45L617 505.82a16 16 0 0 1-22.46 2.81L6.18 53.9a16 16 0 0 1-2.81-22.45z"]],

	## minimised differences :
	## \s* for 0+ spaces
	## "map-marker-slash" but twitter (no speechmarks)

	sub minimise_bit ( $self, $js )
		{
		## get style for this bit of js
		my $style = '';

		# we're looking for (say) \bfab\b, but there are some style names in comments, and in an if statement before each set of svg definitions 
		my $check_js = $js;
		$check_js =~ s#/\*.*?\*/##sg; 				# remove comments - normal
		$check_js =~ s#"fas"===##sg;				# remove if (prefix === 'fas') - minimised
		$check_js =~ s#prefix === 'fas'##sg;		# remove if (prefix === 'fas') - normal

		foreach my $s ( sort keys %STYLES )
			{
			if ( $check_js =~ /["']$s["']/ ) # ' = normal, " = minimised
				{
				die "error - $s - already set $style" if $style;
				$style = $s;
				}
			}

		die "something has changed in this release - style regex - $style\n" if ! $style;

		warn ". . bit: $style\n";

		##
		$self->{svg_defn_matches}	= 0;
		$self->{icons_kept}			= "";
		$self->{icons_to_keep}		= $self->{all_icons}{ $style } ? $self->{all_icons}{ $style } : {};

		my @keep = sort keys %{ $self->{icons_to_keep} };

		warn ". . . look: @keep\n" ;

		##
		sub remove_icons ( $self, $svg_line, $icon_name, $code )
			{
			$self->{svg_defn_matches}++;

			if (  $self->{icons_to_keep}->{ $icon_name } )
				{
				#warn ". . . keep $icon_name\n";
				$self->{icons_kept} .= "$icon_name ";
				return $svg_line;
				}
			else
				{
				#warn "remove $icon_name / $code\n";
				return '';
				}
			};

		##
		$js =~ s/
			\s*
			"?( [-\w]+ )"? : \s*
			\[
				\d+ , \s*
				\d+ , \s*
				\[ [^\] ]* \] , \s*
				"( [fe][\w\d]{3} )" , \s*
				.*?
			\]+
			,\n*
			/ $self->remove_icons( $&, $1, $2 )
			/xeg;

		##
		warn ". . . kept: $self->{icons_kept}\n";
		warn ". . . svg defs: $self->{svg_defn_matches}\n";

		return $js;
		}

	sub save_js ( $self )
		{
		warn "save\n";

		my $out_js  = $self->{config}->{SVG_JS_FILES}->{OUT};

		$self->{javascript_small} > io( $out_js );

		warn sprintf ( ". out : %8d K : $out_js \n" , ( -s $out_js ) / 1024 );
		}
	}

my $fa_minimiser = FA_MINIMISER->new();

$fa_minimiser->read_yaml();
$fa_minimiser->read_js();

$fa_minimiser->find();

$fa_minimiser->merge_find_list();

$fa_minimiser->minimise();

$fa_minimiser->save_js();


