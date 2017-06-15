#!/sw/bin/perl

# scan stack of 16 bit tif images for a given particle id, assume 1 color channel
#
# for every image file
#   scan each line in each file
#   find non-zero pixels (labels) == particle id
#   add coordinates to coordinate list
#   make new image with prescribed
#   particle only
# end
# for particle = particle id
#   print particle coordinates
# end

use warnings;
use Imager;
use IO::File;
use Getopt::Long;

#
# Process the command line
#
my $DEBUG=0;
my ($VERBOSE,$HELP);
my $OUTFILE="particle.pts";
my $ZFILE;
{ # process command line options
    GetOptions(
        "verbose"   => \$VERBOSE,
        "debug"     => \$DEBUG,
        "help"      => \$HELP,
	"o=s"       => \$OUTFILE,
	"zfile"     => \$ZFILE
        );
}

die "usage: scanImgRangeGrain1.pl id Nvoxels images  [--help --verbose --debug --zfile --o=outputfile]\n" if (@ARGV < 3 || $HELP);
($pid, $nvox, @ifiles)=@ARGV;

# loop over stack of image files
$iz=0;
$iframe=0;

# DEBUG: images for a particle
if($DEBUG){
    $c1 = Imager::Color->new(gray=>255);
}

foreach $image_file (@ifiles){
    $iframe++;
    print STDOUT "read image $image_file ... " if $VERBOSE;
    my $img = Imager->new();
    $img->open(file=>$image_file) or die $img->errstr();

    if($ZFILE){
	if($image_file=~m/^.*?(\d+).tif/){
	    $iz=$1;
	    $iz =~ s/^0+//;
	}
	print "\n\tiz: $iz\n" if $VERBOSE;
    }

    $xsize=$img->getwidth();
    $ysize=$img->getheight();
    $channels=$img->getchannels();
    die "invalid number of channles: $channels for file $image_file\n" if($channels != 1);

    # DEBUG: new image which will hold only the specified particle

    my $imgb;
    if($DEBUG){
	print STDOUT "\n\tdebug image ..." if $VERBOSE;
	$imgb = Imager->new(xsize=>$xsize, ysize=>$ysize,
			    channels=>1, bits=>8); # Grayscale, 8 bit
    }

    for($i=0;$i<$ysize;$i++){        # loop over image rows
	my @colors = $img->getsamples(y=>$i, type=>'16bit');

	my @PXYZ=();      # for avoiding to save consecutive points in a row
	for($j=0; $j<@colors;$j++){  # loop over pixels in a row
	    $c=$colors[$j];
	    if($c == $pid){
		if($DEBUG){
		    $imgb->setpixel(x=>$j, y=>$i, color=>$c1);
		}
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


    # DEBUG: write images with only the specified particle
    if($DEBUG){
	$pframe=sprintf("_%04d.tiff",$iframe);
	$fnameb="p_$pid"."$pframe";
	print STDOUT " $fnameb\n" if $VERBOSE;
	$imgb->write(file=>$fnameb);
	undef $imgb;
    }

    $iz++;
    print STDOUT "done.\n" if $VERBOSE;
}

# $n=@PXYZ;
print STDOUT "voxels in particle: from images= $n , from input= $nvox\n" if $VERBOSE;

open(OFILE,">$OUTFILE") or die "$0: $! $OUTFILE\n";
# print OFILE "3\n";
# print OFILE "$n\n";
# print particle coordinates
foreach $s ( @PSAVE ){
    foreach $p (@{ $s }){
	@xyz=@{ $p };
	print OFILE "@xyz\n";
    }
}
