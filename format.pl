#!/usr/bin/perl

use strict;
use warnings;

my @lines = <>;
chomp @lines;

for(my $i=0; $i<15; $i++) {
    shift @lines;
}

my @rev_lines = reverse @lines;

print "var data = [\n";

my $x = 0;
foreach my $line (@rev_lines) {
    $x++;

    print "    [ ";

    my @words = split(/;/, $line);
    my $n = $#words + 1;
    for(my $i=0; $i<$n; $i++) {
        my $word = $words[$i];
        $word =~ s/^ +//;
        $word =~ s/ +$//;
        my @colors = split(/ /, $word);
        print "[" . hex($colors[0]) . ", " . hex($colors[1]) . ", " . hex($colors[2]) . "]";
        if($i < $n - 1) {
            print ",";
        }
    }
    print "],\n"
    # TODO: remove last comma
}

print "];";
