#!/usr/bin/perl

# scan 16 bit tif image, assume 1 color channel
# scan each line and print max and min numbers

use warnings;
use Imager;
use IO::File;

die "usage: scanImgRange.pl input_image\n" if @ARGV != 1;
($image_file)=@ARGV;

my $img = Imager->new();
$img->open(file=>$image_file) or die $img->errstr();

# $xsize=$img->getwidth();
$ysize=$img->getheight();
$channels=$img->getchannels();
die "invalid number of channles: $channels\n" if($channels != 1);

$nmax=0;
$nmin=10000000;
for($i=0;$i<$ysize;$i++){
    my @colors = $img->getsamples(y=>$i, type=>'16bit');

    foreach $j (@colors){
	$nmax=($nmax > $j) ? $nmax : $j;
	if($j>0){
	    $nmin=($nmin < $j) ? $nmin : $j;
	}
    }
}

print "channels: $channels nmin: $nmin nmax: $nmax\n";
