#!/usr/bin/env perl
#
# This script generates a tournament based on sorting networks.
# If run to completion, the tournament would produce a complete ranking of players, not just a final winner.
# For small numbers of players (8 - 32), this is a nicer way to run a tournament, because no one needs to 
# drop out and just sit around (at least for the first few rounds).
#
#   Usage : SN_tournament.pl [ <num players> ]
#
use strict;
use warnings;

my ($num_players) = @ARGV;
$num_players //= 8;

#use lib "lib";
#use Algorithm::Networksort;
#use Algorithm::Networksort::Best qw(:all);
# Since it is mess to install these libraries, we just use the web interface to the library instead.

# Get the list of matches
use LWP::Simple;
my $webpage = `GET http://jgamble.ripco.net/cgi-bin/nw.cgi?inputs=$num_players&algorithm=best&output=text`;
if ($webpage =~ m/(\[\[.*\]\])/s) {
  $webpage = $1;
}
$webpage =~ s/\]\]/$&,/g;
$webpage = "$webpage\n";
#print $webpage;

# Convert string to an actual perl array;
my @tournament_of_matches = eval ($webpage);

use Data::Dumper;
$Data::Dumper::Terse = 1; 
$Data::Dumper::Indent = 0; 
$Data::Dumper::Maxdepth = 4;  
#print "\n" . Dumper(\@tournament_of_matches) . "\n";

my @players = (0 .. ($num_players - 1));
my $num_rounds = $#tournament_of_matches + 1;
my ($rm, $mm, $col, $p, $r);

# Annotate each match with a column number (distinct column within round)
my @tournament_of_matches_with_col = ();
foreach $rm (@tournament_of_matches) {
  my @round_of_matches = @{$rm};
  my @matches_in_each_col = [];
  push (@tournament_of_matches_with_col, []);
  foreach $mm (@round_of_matches) {
    my $col = -1;
    my ($p1, $p2) = @{$mm};
    foreach my $test_col (0 .. $#matches_in_each_col) {
      my $col_could_work = 1;
      foreach my $test_match (@{$matches_in_each_col[$test_col]}) {
        my ($tp1, $tp2) = @{$test_match};
        if ($tp1 <= $p1 && $p1 <= $tp2 || 
            $tp1 <= $p2 && $p2 <= $tp2 ||
            $p1 <= $tp1 && $tp1 <= $p2 || 
            $p1 <= $tp2 && $tp2 <= $p2 ) {
          $col_could_work = 0;
          last;
          # This col doesn't work, move on to next col
        }
      }
      if ($col_could_work) {
        $col = $test_col;
      }
    }
    if ($col == -1) { $col = $#matches_in_each_col + 1; }
    if ($col > $#matches_in_each_col) {
      $matches_in_each_col[$col] = [];
    }
    push (@{$matches_in_each_col[$col]}, $mm);
    push (@{$tournament_of_matches_with_col[-1]}, [$p1, $p2, $col]);
  }
}
#print "\n" . Dumper(\@tournament_of_matches) . "\n";
print "\n" . Dumper(\@tournament_of_matches_with_col) . "\n";

# Dot based png version.
if (0) {

# Write out the graph that we want.
  my $tdot_file = "tournament_${num_players}.dot";
  my $tpng_file = "tournament_${num_players}.png";
  open TDOT_FILE, ">$tdot_file";

  my $scale_factor = 0.5;
  sub scl { my ($x) = @_; return ($x * $scale_factor); }

# graph header
  print TDOT_FILE "digraph \"tournament\" {\n";
  print TDOT_FILE "  graph [center=1 rankdir=LR ]\n";
#print TDOT_FILE "  graph [center=1 rankdir=TB ]\n";
  print TDOT_FILE "  edge [dir=none]\n";
  print TDOT_FILE "  node [width=".&scl(0.3)." height=".&scl(0.3)." label=\"\"]\n";

# Space for player names.
  print TDOT_FILE "  { node [shape=rect width=".&scl(6)." height=".&scl(1)."] rank=same\n";
  foreach $p (@players) {
    print TDOT_FILE "    player_name_${p}\n";
  }
  print TDOT_FILE "  }\n";

# Space for player numbers.
  foreach $r (0 .. $num_rounds) {
    print TDOT_FILE "  { node [shape=circle width=".&scl(1)." height=".&scl(1)."] rank=same\n";
    foreach $p (@players) {
      my $lbl_cmnt = 'label="'.($p+1).'"';
      my $pos_cmnt = ""; # "pos=\"$r,$p\""; # ignored by dot.
      my $cmnt = join(" ", "[", $pos_cmnt, $lbl_cmnt, "]");
      print TDOT_FILE "    round${r}_player_number_${p} $cmnt\n";
    }
    print TDOT_FILE "  }\n";
  }

# First set of edges
  print TDOT_FILE "  { edge []\n";
  foreach $p (@players) {
    print TDOT_FILE "    player_name_${p} -> round0_player_number_${p}\n";
  }
  print TDOT_FILE "  }\n";

# All the rounds
  my $src_round_num = 0;
  foreach $rm (@tournament_of_matches) {
    my @round_of_matches = @{$rm};
    my $sl = $src_round_num;
    my $dl = $sl + 1;
    print TDOT_FILE "  // Round ${dl}\n";
    print TDOT_FILE "  { edge []\n";

    my %player_connected = {};
    foreach $mm (@round_of_matches) {
      my @match = @{$mm};
      my ($p1, $p2) = @match; 
      print TDOT_FILE "    // match is between ${p1} and ${p2}\n";
      print TDOT_FILE "    round${sl}_player_number_${p1} -> round_${sl}to${dl}_match_${p1} -> round${dl}_player_number_${p1} [ weight=10 ]\n";
      print TDOT_FILE "    round${sl}_player_number_${p2} -> round_${sl}to${dl}_match_${p2} -> round${dl}_player_number_${p2} [ weight=10 ]\n";
      print TDOT_FILE "    round_${sl}to${dl}_match_${p1} -> round_${sl}to${dl}_match_${p2} [ weight=0 ]\n\n";
      $player_connected{$p1} = 1; 
      $player_connected{$p2} = 1; 
    }
    foreach $p (@players) { 
      if (not defined $player_connected{$p} or not $player_connected{$p}) {
        print TDOT_FILE "    // ${p} has no match in this round\n";
        print TDOT_FILE "    round${sl}_player_number_${p} -> round${dl}_player_number_${p} [ weight=10 ]\n\n";
      } 
      $player_connected{$p} = 0;
    }
    print TDOT_FILE "  }\n";

    $src_round_num++;
  }

# Some extra invisible edges to get things to render properly.
  foreach $r (0 .. $num_rounds) {
    print TDOT_FILE "  { edge [ ] \n";
    #print TDOT_FILE "  { edge [ style=\"invis\" ] \n";
    foreach $p (0 .. ($num_players - 2)) {
      my $q = $p + 1;
      print TDOT_FILE "    round${r}_player_number_${p} -> round${r}_player_number_${q} [ weight=100 ]\n";
    }
    print TDOT_FILE "  }\n";
  }


# graph footer
  print TDOT_FILE "}\n";
  close TDOT_FILE;


# Convert dot to png.
  system("dot -Tpng -o$tpng_file $tdot_file");
}

# text based version.
if (1) {
  my $ttxt_file = "tournament_${num_players}.txt";
  open TTXT_FILE, ">$ttxt_file";

  my $canvas_ht = $num_players * 3;
  my $canvas_wd = $num_rounds  * 12 + 20;
  my @txt_array = ();
  foreach my $y (0 .. ($canvas_ht-1)) {
    $txt_array[$y] = ' ' x $canvas_wd;
  }

  #print @txt_array;
  #print TTXT_FILE @txt_array;
  close TTXT_FILE;
}

#O----[ ]-------[ ]
