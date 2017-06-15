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
use Getopt::Long;

#
# Process the command line
#
my $DEBUG=0;
my ($VERBOSE,$HELP,$SPLIT);
my $OUTFILE="image.idx";
{ # process command line options
    GetOptions(
        "verbose"   => \$VERBOSE,
        "debug"     => \$DEBUG,
        "split"     => \$SPLIT,
        "help"      => \$HELP,
	"o=s"     => \$OUTFILE
        );
}

die "usage: scanImgRange.pl input_images [--help --verbose --debug --split --o=outputfile]\n" if (@ARGV < 1 || $HELP);
@ifiles=@ARGV;

# loop over stack of image files
foreach $image_file (@ifiles){
    print STDOUT "read image $image_file ..." if $VERBOSE;
    my $img = Imager->new();
    $img->open(file=>$image_file) or die $img->errstr();

#    $xsize=$img->getwidth();
    $ysize=$img->getheight();
    $channels=$img->getchannels();
    die "invalid number of channles: $channels for file $image_file\n" if($channels != 1);

    for($i=0;$i<$ysize;$i++){               # loop over image rows
	my @colors = $img->getsamples(y=>$i, type=>'16bit');
	$ncolor=@colors;
#	print "ncolor $ncolor xsize $xsize:\n";

	foreach $j (@colors){               # loop over pixels in a row
	    if($j > 0){                     # color is not background, it is a particle
		$PARTICLE{$j}++;            # increase count of pixels for a particle
		$PFILES{$j}{$image_file}++; # build image list for each particle
	    }
	}
    }
    print STDOUT " done.\n" if $VERBOSE;
}

# create a list of all particle labels
@PARTICLES=sort by_number keys %PARTICLE;

# print particle label, number of voxels in particles, and files for the particle
unless($SPLIT){ # for single output file
    print STDOUT "Saving all particles in file $OUTFILE\n" if $VERBOSE;
    open(OFILE,">$OUTFILE") or die "$0: $! $OUTFILE\n";
}
foreach $i (@PARTICLES){
    if($SPLIT){ # for separate particle files
	my $idx=$i;
	$OUTIDX=$OUTFILE."_".sprintf("%06d", $idx).".idx";
	print STDOUT "Saving particle".sprintf("%6d", $idx)." in file $OUTIDX\n" if $VERBOSE;
	open(OFILE,">$OUTIDX") or die "$0: $! $OUTIDX\n";
    }
    @files=sort keys %{ $PFILES{$i} }; 
    print OFILE "$i $PARTICLE{$i} @files\n";
    if($SPLIT){ # for separate particle files
	close OFILE;
    }
}

sub by_number {
    $a <=> $b;
}
