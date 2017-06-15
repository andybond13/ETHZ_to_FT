#!/sw/bin/perl

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

use warnings;
use Imager;
use IO::File;

die "usage: scanImgRange.pl input_images\n" if @ARGV < 1;
@ifiles=@ARGV;

# loop over stack of image files
foreach $image_file (@ifiles){
    print STDERR "read image $image_file ...";
    my $nmc = 0;
    my $void = 0;
    my $img = Imager->new();
    $img->open(file=>$image_file) or die $img->errstr();

#    $xsize=$img->getwidth();
    $ysize=$img->getheight();
    $channels=$img->getchannels();
    die "invalid number of channles: $channels for file $image_file\n" if($channels != 1);

    for($i=0;$i<$ysize;$i++){     # loop over image rows
	my @colors = $img->getsamples(y=>$i, type=>'16bit');
	foreach $j (@colors){     # loop over pixels in a row
	    if($j > 0){           # color is not background, it is particle
		$nmc++;
	    }
		else{
		$void++;
		}
	}
    }
    print "NMC: $nmc    void: $void";
    print STDERR " done.\n";
}

