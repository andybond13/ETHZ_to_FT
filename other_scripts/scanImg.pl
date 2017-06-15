#!/usr/bin/perl

# scan 16 bit tif image
# scan each line and print numbers into PGM file
# need to specify max integer gray scale in the file,
# assumes number > 256 because that decides on the type
# of PGM file, easy check and change of pack command
# can make it capable of encoding 8 bit (maxint < 256)
# data

use warnings;
use Imager;
use IO::File;

die "usage: scanImg.pl input_image maxint output_image\n" if @ARGV != 3;
($image_file, $mxint, $ofile)=@ARGV;

my $img = Imager->new();
$img->open(file=>$image_file) or die $img->errstr();

my $fh = IO::File->new( $ofile, '>' ) 
  or die "Unable to open $ofile - $!\n";

$fh->binmode;  # write in binary mode, 

open my($OFILE), '>', $ofile or die "$0: $! $ofile\n";

$xsize=$img->getwidth();
$ysize=$img->getheight();
$channels=$img->getchannels();
die "invalid number of channles: $channels\n" if($channels != 1);

# may bomb, as it is writing to bin filehandle, worry later
print $fh "P5 $xsize $ysize $mxint\n";

for($i=0;$i<$ysize;$i++){
    my @colors = $img->getsamples(y=>$i, type=>'16bit'); # get the entire scanline
    foreach $j (@colors){
	$out=pack 'n', $j; # pack it as 16 bit, big-endian, network format
	$fh->print( $out );
    }
}
