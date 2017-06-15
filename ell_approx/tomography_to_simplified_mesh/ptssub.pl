#!/sw/bin/perl -w

# subtract coordinates in a pts file

$pgnam="ptssub";

undef $debug;
@j=();
@ARGVI=@ARGV;
for($i=0;$i<=$#ARGV;$i++){
    if($ARGV[$i] =~ /-D(\w+)=(.*)/){
	$$1=$2;
        @j=($i,@j);
	@DEFS = (@DEFS,$1);
	%DHSH = (%DHSH, $1, $2,);
	next;
    }
    if($ARGV[$i] =~ /-D(\w+)/){
	$$1=1;
        @j=($i,@j);
	@DEFS = (@DEFS,$1);
	%DHSH = (%DHSH, $1, 1,);
	next;
    }
}
foreach $i (@j){
    splice(@ARGV,$i,1);
}
if(defined $debug){
    print "ARGVI: @ARGVI\n";
    print "ARGV: @ARGV\n";
    print "DEFS:";
    for($i=0;$i<=$#DEFS;$i++){
	print " $DEFS[$i]=${$DEFS[$i]}";
    }
    print "\n";
    print "DHSH:";
    while (($key,$value) = each %DHSH){
	print " DHSH\{$key\}=$value";
    }
    print "\n";
}

if($#ARGV < 2){
  die "usage: $pgnam in_file sub_file out_file\n";
}

open(IFILE, "$ARGV[1]") || die "$pgnam: $ARGV[1] $!.\n";
while (<IFILE>){
    s/^\s+//;
    s/\s+$//;
    next if /^\$/;
#    chop;
    @f=split;
    ($xm,$ym,$zm)=@f;
}
close IFILE;
    

open(IFILE, "$ARGV[0]") || die "$pgnam: $ARGV[0] $!.\n";
open(OFILE, ">$ARGV[2]") || die "$pgnam: $ARGV[2] $!.\n";

while (<IFILE>){
    s/^\s+//;
    s/\s+$//;
    next if /^\$/;
#    chop;
    @f=split;

    $f[0]-=$xm;
    $f[1]-=$ym;
    $f[2]-=$zm;

    print OFILE "@f\n";
}
close IFILE;
close OFILE;
