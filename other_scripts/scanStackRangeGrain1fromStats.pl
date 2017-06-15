#!/usr/bin/perl

# scan stack of 16 bit tif images for a given particle id, assume 1 color channel
#
# for every image file
#   scan each line in each file
#   find non-zero pixels (labels) == particle id
#   add coordinates to coordinate list
# end
# for particle = particle id
#   print particle coordinates
# end

use warnings;
use Imager;
use IO::File;

die "usage: scanImgRangeGrain.pl stat_file input_images\n" if @ARGV < 3;
($statfile, @ifiles)=@ARGV;


open(my $fh, '<:encoding(UTF-8)', $statfile)
	or die "Could not open file '$statfile' $1";

while (my $row = <$fh>) {
	chomp $row;
	#print "$row\n";
	my @values = split(' ',$row);
	if ( scalar @values != 2) {die "wrong size";}
	$pid = $values[0];
	$nvox = $values[1];

# loop over stack of image files
$iz=0;
foreach $image_file (@ifiles){
    print STDERR "read image $image_file ...";
    my $img = Imager->new();
    $img->open(file=>$image_file) or die $img->errstr();

#    $xsize=$img->getwidth();
    $ysize=$img->getheight();
    $channels=$img->getchannels();
    die "invalid number of channles: $channels for file $image_file\n" if($channels != 1);

    for($i=0;$i<$ysize;$i++){        # loop over image rows
	my @colors = $img->getsamples(y=>$i, type=>'16bit');

	my @PXYZ=();      # for avoiding to save consecutive points in a row
	for($j=0; $j<@colors;$j++){  # loop over pixels in a row
	    $c=$colors[$j];
	    if($c == $pid){
		if(@PXYZ > 1 && $PXYZ[$#PXYZ][0] == ($j-1)){
		    pop @PXYZ;     # previous point in the row is grain
		}
		push @PXYZ, [$j, $i, $iz];
	    }
	}

	if(@PXYZ){
	    $n+=@PXYZ;
	    push @PSAVE, \@PXYZ;
	}

    }

    $iz++;
    print STDERR " done.\n";
}

# $n=@PXYZ;
print STDERR "$n $nvox\n";
#print "3\n";
#print "$n\n";
# print particle coordinates
foreach $s ( @PSAVE ){
    foreach $p (@{ $s }){
	@xyz=@{ $p };
	print "$pid @xyz\n";
    }
}

}
