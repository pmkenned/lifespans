#!/usr/bin/perl

# iterate over the rows
#  iterate over the columns
#   if column c from image 0 == column c from image 1 and in "diff" state,
#    leave diff state, print start diff col, print end col, print first color, print second color
#   if column c from image 0 != column c from image 1
#    record column number
#    record color from image0 and image 1
#   

use strict;
use warnings;

my $argc = $#ARGV+1;
my $mode = 0;

if($argc < 1) {
    print STDERR "usage: ./program FILE1 [FILE2]\n"
    exit;
}

if($argc == 1) {
    $mode = 1;
}

if($argc == 2) {
    $mode = 2;
}

my $fh1 = open($ARGV[0], '<') or die $!;

my $fh2;
if($mode == 2) {
    $fh2 = open($ARGV[1], '<') or die $!;
}

my @lines = <$fh1>;
chomp @lines;

# print color delta look up table

print "var color_delta = [\n";
print "[0,0,0, 255, 255, 255],\n";
print "];\n";

# print row/column table

my $rows = 2;
my $cols = 2;

print "var rc_data = [\n";
for(my $r = 0; $r < $rows; $r++) {

    for(my $c=0; $c < $cols; $c++) {
        # if columns differ and in the same state
        #  enter diff state
        # if columns differ and in the differ state
        #  if columns differ in the same way as currently
        #  if columns differ in a different way as currently
        # if columns equal and in the same state
        #  do nothing
        # if columns equal and in the diff state
        #  exit diff state, print diff section
    }

    my $d = 0;
    my $c0 = 0;
    my $c1 = 0;
    print "[" . $d. ", " . $r . ", " . $c0, ", " . $c1 . "],\n";
}
print "];\n";
