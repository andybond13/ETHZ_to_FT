#!/usr/bin/perl

# scan stack of 16 bit tif images, assume 1 color channel
#
# for every image file
#   scan each line in each file
#   find non-zero pixels (labels)
#   count pixels in each particle
#   build file list for each particle
# end
# for each particle
#   print particle label, pixel count, file list
# end

# voxel-by-voxel search to create a list of centroidal contact unit vectors!

use strict;
use warnings;
use IO::File;

die "usage: contactListSplit.pl input_file\n" if @ARGV != 1;
my $ifile=$ARGV[0];

open my $info, $ifile or die "Could not open $ifile: $!";

while( my $line = <$info>)  {
    my @abc = split(' ',$line);   
    last if @abc > 4;
    print "$line";
#    my $linesize = @abc;
#    print "$linesize\n";
}

close $info;
