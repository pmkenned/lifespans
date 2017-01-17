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

my $fh1;
if($mode == 2) {
    open($fh1, '<', $ARGV[1]) or die $!;
}

# read in the image data

my @lines0 = <$fh0>;
chomp @lines0;

my @lines1;
if($mode == 2) {
    @lines1 = <$fh1>;
    chomp @lines1;
}
else {
    @lines1 = @lines0;
}

# ignore first 3 lines
for(my $i=0; $i < 3; $i++) {
    shift @lines0;
    shift @lines1;
}

my ($rows0, $rows1, $cols0, $cols1);

$_ = $lines0[0];
$_ =~ /(\d+)/;
$rows0 = $1;
$_ = $lines0[1];
$_ =~ /(\d+)/;
$cols0 = $1;

if($mode == 2) {
    $_ = $lines1[0];
    $_ =~ /(\d+)/;
    $rows1 = $1;
    $_ = $lines1[1];
    $_ =~ /(\d+)/;
    $cols1 = $1;
}
else {
    $rows1 = $rows0;
    $cols1 = $cols0;
}

for(my $i=0; $i < 12; $i++) {
    shift @lines0;
    shift @lines1;
}

my $rows = $rows0;
my $cols = $cols0;

my @i0;
my @i1;

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

# TODO: specify mode == 1

my $r1 = 0;
foreach my $line (@lines1) {
    my @pixels = split(/;/, $line);
    my $c1 = 0;
    foreach my $pixel (@pixels) {
        $pixel =~ s/^ +//;
        $pixel =~ s/ +$//;
        my @colors = split(/ /, $pixel);
        $i1[$r1][$c1*3+0] = hex $colors[0];
        $i1[$r1][$c1*3+1] = hex $colors[1];
        $i1[$r1][$c1*3+2] = hex $colors[2];
        $c1++;
    }
    $r1++;
}

# returns 1 if equal, 0 if not equal
sub compare_pixels {
    my $m = shift;
    my $i0_ref = shift;
    my $i1_ref = shift;
    my $r = shift;
    my $c = shift;
    my $rv = 1;

    if($m == 1) {
        if($i0_ref->[$r][$c*3+0] != 255) { $rv = 0; }
        if($i0_ref->[$r][$c*3+1] != 255) { $rv = 0; }
        if($i0_ref->[$r][$c*3+2] != 255) { $rv = 0; }
    }
    else {
        if($i0_ref->[$r][$c*3+0] != $i1_ref->[$r][$c*3+0]) { $rv = 0; }
        if($i0_ref->[$r][$c*3+1] != $i1_ref->[$r][$c*3+1]) { $rv = 0; }
        if($i0_ref->[$r][$c*3+2] != $i1_ref->[$r][$c*3+2]) { $rv = 0; }
    }
    return $rv;
}

# returns 1 if equal, 0 if not equal
sub compare_pixel_with_color {
    my $i0_ref = shift;
    my $r = shift;
    my $c = shift;
    my $color_r = shift;
    my $color_g = shift;
    my $color_b = shift;
    my $rv = 1;
    if($i0_ref->[$r][$c*3+0] != $color_r) { $rv = 0; }
    if($i0_ref->[$r][$c*3+1] != $color_g) { $rv = 0; }
    if($i0_ref->[$r][$c*3+2] != $color_b) { $rv = 0; }
    return $rv;
}

sub print_segment {
    my $at_least_one = shift;
    my $r = shift;
    my $diff_start = shift;
    my $diff_end = shift;
    my $color0r = shift;
    my $color0g = shift;
    my $color0b = shift;
    my $color1r = shift;
    my $color1g = shift;
    my $color1b = shift;

    if(not $at_least_one) {
        print "    [$r, ";
    }
    print $diff_start . ", " . $diff_end, ", ";
    print $color0r . ", " . $color0g . ", " . $color0b . ", ";
    print $color1r . ", " . $color1g . ", " . $color1b . ", ";
}

#print "var patch = [\n";
print "[\n";
for(my $r = 0; $r < $rows; $r++) {

    my $state = SAME;
    my $state_n = $state;

    my $diff_start = 0;
    my $diff_end = 0;
    my $abrupt = 0;
    my ($color0r, $color0g, $color0b);
    my ($color1r, $color1g, $color1b);
    my ($color2r, $color2g, $color2b);
    my ($color3r, $color3g, $color3b);

    my $at_least_one = 0;

    COL: for(my $c=0; $c < $cols; $c++) {

        # if columns differ and in the same state
        #  enter diff state
        # if columns differ and in the differ state
        #  if columns differ in the same way as currently
        #  if columns differ in a different way as currently
        # if columns equal and in the same state
        #  do nothing
        # if columns equal and in the diff state
        #  exit diff state, print diff section

        if($state == SAME) {
            if(&compare_pixels($mode, \@i0, \@i1, $r, $c)) {
                # next COL;
            }
            else {
                $state_n = DIFF;
                $color0r = $i0[$r][$c*3+0];
                $color0g = $i0[$r][$c*3+1];
                $color0b = $i0[$r][$c*3+2];
                if($mode == 2) {
                    $color1r = $i1[$r][$c*3+0];
                    $color1g = $i1[$r][$c*3+1];
                    $color1b = $i1[$r][$c*3+2];
                }
                else {
                    $color1r = 255;
                    $color1g = 255;
                    $color1b = 255;
                }
                $diff_start = $c;
            }
        }
        if($state == DIFF) {
            if(&compare_pixels($mode, \@i0, \@i1, $r, $c)) {
                $state_n = SAME;
                $diff_end = $c - 1;
            }
            else {
                if(&compare_pixel_with_color(\@i0, $r, $c, $color0r, $color0g, $color0b) and
                   (($mode == 1) or &compare_pixel_with_color(\@i1, $r, $c, $color1r, $color1g, $color1b))) {
                    # next COL;
                }
                else {
                    $abrupt = 1;
                    $color2r = $i0[$r][$c*3+0];
                    $color2g = $i0[$r][$c*3+1];
                    $color2b = $i0[$r][$c*3+2];
                    if($mode == 2) {
                        $color3r = $i1[$r][$c*3+0];
                        $color3g = $i1[$r][$c*3+1];
                        $color3b = $i1[$r][$c*3+2];
                    }
                    else {
                        $color3r = 255;
                        $color3g = 255;
                        $color3b = 255;
                    }
                    $diff_end = $c - 1;
                }
            }
        }

        if(($state == DIFF) and ($state_n == SAME)) {
            &print_segment($at_least_one, $rows-$r-1, $diff_start, $diff_end,
                           $color0r, $color0g, $color0b,
                           $color1r, $color1g, $color1b);
            $at_least_one = 1;
        }

        if(($state == DIFF) and $abrupt) {
            &print_segment($at_least_one, $rows-$r-1, $diff_start, $diff_end,
                           $color0r, $color0g, $color0b,
                           $color1r, $color1g, $color1b);
            $diff_start = $diff_end + 1;
            $color0r = $color2r;
            $color0g = $color2g;
            $color0b = $color2b;
            $color1r = $color3r;
            $color1g = $color3g;
            $color1b = $color3b;
            $abrupt = 0;
            $at_least_one = 1;
        }

        if(($state_n == DIFF) and ($c == $cols-1)) {
            $diff_end = $c;
            &print_segment($at_least_one, $r, $diff_start, $diff_end,
                           $color0r, $color0g, $color0b,
                           $color1r, $color1g, $color1b);
            $at_least_one = 1;
        }

        $state = $state_n;
    }

    if($at_least_one) {
        print "],\n";
    }

}
print "],\n";
#print "];\n";
