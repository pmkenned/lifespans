#!/usr/bin/perl

use strict;
use warnings;

use constant {
    SAME => 0,
    DIFF => 1,
};

my $argc = $#ARGV+1;
my $mode = 0;

if($argc < 1) {
    print STDERR "usage: ./program FILE1 [FILE2]\n";
    exit;
}

if($argc == 1) { $mode = 1; }
if($argc == 2) { $mode = 2; }

open(my $fh0, '<', $ARGV[0]) or die $!;

my @lines0 = <$fh0>;
chomp @lines0;

# ignore first 3 lines
for(my $i=0; $i < 3; $i++) {
    shift @lines0;
}

my ($rows0, $rows1, $cols0, $cols1);

$_ = $lines0[0];
$_ =~ /(\d+)/;
$rows0 = $1;
$_ = $lines0[1];
$_ =~ /(\d+)/;
$cols0 = $1;

for(my $i=0; $i < 12; $i++) {
    shift @lines0;
}

my $rows = $rows0;
my $cols = $cols0;

my @i0;

my $r0 = 0;
foreach my $line (@lines0) {
    my @pixels = split(/;/, $line);
    my $c0 = 0;
    foreach my $pixel (@pixels) {
        $pixel =~ s/^ +//;
        $pixel =~ s/ +$//;
        my @colors = split(/ /, $pixel);
        $i0[$r0][$c0*3+0] = hex $colors[0];
        $i0[$r0][$c0*3+1] = hex $colors[1];
        $i0[$r0][$c0*3+2] = hex $colors[2];
        $c0++;
    }
    $r0++;
}

print "var rc_data = [\n";
for(my $r = 0; $r < $rows; $r++) {

    my $prev_col = 0;
    my $prev_r = $i0[$r][0];
    my $prev_g = $i0[$r][0];
    my $prev_b = $i0[$r][0];

    print "[";

    COL: for(my $c=0; $c < $cols+1; $c++) {

        my $curr_r = ($c < $cols) ? $i0[$r][$c*3+0] : -1;
        my $curr_g = ($c < $cols) ? $i0[$r][$c*3+1] : -1;
        my $curr_b = ($c < $cols) ? $i0[$r][$c*3+2] : -1;

        # if prev and curr pixels differ
        if(($curr_r != $prev_r) or ($curr_g != $prev_g) or ($curr_b != $curr_b)) {
            my $num = ($c - $prev_col);
            print "$num, $prev_r, $prev_g, $prev_b, ";
            $prev_r = $curr_r;
            $prev_g = $curr_g;
            $prev_b = $curr_b;
            $prev_col = $c;
        }

    }

    print "],\n";
}

print "];\n";
