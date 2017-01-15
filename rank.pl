#!/usr/bin/perl

use strict;
use warnings;

my @lines = <>;
chomp foreach @lines;

my %table;
my %ranks;

foreach my $line (@lines) {
    my @words = split(/,\s+/, $line);

    my $name  = $words[0];
    my $birth = $words[1];
    my $death = $words[2];

    $table{$name} = [$birth, $death];
}

my @keys = keys %table;

my $g_max_rank = 0;

foreach my $key (@keys) {

    my $b = $table{$key}->[0];
    my $d = $table{$key}->[1];

    my @keys2 = keys %ranks;

    my @blocked = ();
    KEY: foreach my $key2 (@keys2) {
        my $b2 = $table{$key2}->[0];
        my $d2 = $table{$key2}->[1];
        if(($b > $d2) or ($d < $b2)) {
            # clear
        }
        else {
            my $r2 = $ranks{$key2};
            $blocked[$r2] = 1;
        }
    }

    my $rank = 0;
    my $found = 0;
    BLOCKED: for(my $i=0; $i<=$#blocked; $i++) {
        if(not defined $blocked[$i]) {
            $ranks{$key} = $i;
            $found = 1;
            last BLOCKED;
        }
    }
    if(not $found) {
        $g_max_rank = $#blocked+1;
        $ranks{$key} = $g_max_rank;
    }

}

my @colors = (
 '#a00000',
 '#00a000',
 '#0000a0',
 '#a0a000',
 '#a000a0',
 '#00a0a0',
 '#a0a0a0'
);

my $c = 0;
foreach my $key (@keys) {
    # print $key . ", " . $table{$key}->[0] . ", " . $table{$key}->[1] . ", " . $ranks{$key} . "\n";
    my $sp = 40 - length $key;
    $c++;
    if($c > $#colors) { $c = 0; }
    print "lifespan(\"" . $key . "\"," . ' 'x$sp . $table{$key}->[0] . ", " . $table{$key}->[1] . ", " . $ranks{$key} . ", '" . $colors[$c] . "');\n";
}
