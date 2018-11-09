#!/usr/bin/env perl
#
# This script generates a tournament based on sorting networks.
# If run to completion, the tournament would produce a complete ranking of players, not just a final winner.
# For small numbers of players (8 - 32), this is a nicer way to run a tournament, because no one needs to 
# drop out and just sit around (at least for the first few rounds).
#
#   Usage : SN_tournament.pl [ <num players> ]
#
my ($num_players) = @_;

$num_players //= 8;

#use lib "lib";
#use Algorithm::Networksort;
#use Algorithm::Networksort::Best qw(:all);
# Since it is mess to install these libraries, we just use the web interface to the library instead.

# Get the list of comparisons
use LWP::Simple;
my $webpage = `GET http://jgamble.ripco.net/cgi-bin/nw.cgi?inputs=$num_players&algorithm=best&output=text`;
if ($webpage =~ m/(\[\[.*\]\])/s) {
  $webpage = $1;
}
$webpage =~ s/\]\]/$&,/g;
$webpage = "$webpage\n";
#print $webpage;

# Convert string to an actual perl array;
my @array_cmps = eval ($webpage);

use Data::Dumper;
$Data::Dumper::Terse = 1; 
$Data::Dumper::Indent = 0; 
$Data::Dumper::Maxdepth = 4;  
#print "\n" . Dumper(\@array_cmps) . "\n";

my @players = (0 .. ($num_players - 1));

# Write out the graph that we want.
my $tdot_file = "tournament.dot";
my $tpng_file = "tournament.png";
open TDOT_FILE, ">$tdot_file";

# graph header
print TDOT_FILE <<DONE;
digraph "tournament" {
  graph [center=1 rankdir=LR ]
  edge [dir=none]
  node [width=0.3 height=0.3 label=""]
DONE

# Space for player names.
print TDOT_FILE "  { node [shape=rect width=5]\n";
foreach $p (@players) {
  print TDOT_FILE "    player_name_${p}\n";
}
print TDOT_FILE "  }\n";

# Space for player numbers.
print TDOT_FILE "  { node [shape=circle]\n";
foreach $p (@players) {
  print TDOT_FILE "    player_number_level0_${p}\n";
}
print TDOT_FILE "  }\n";

# First set of edges
print TDOT_FILE "  { edge []\n";
foreach $p (@players) {
  print TDOT_FILE "    player_name_${p} -> player_number_level0_${p}\n";
}
print TDOT_FILE "  }\n";



# graph footer
print TDOT_FILE "}\n";
close TDOT_FILE;


# Convert dot to png.
system("dot -Tpng -o$tpng_file $tdot_file");
