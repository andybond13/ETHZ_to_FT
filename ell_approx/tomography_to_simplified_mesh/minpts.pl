#!/sw/bin/perl -w

# find min values in the pts file

$pgnam="minpts";

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

if($#ARGV < 1){
  die "usage: $pgnam in_file out_file\n";
}

open(IFILE, "$ARGV[0]") || die "$pgnam: $ARGV[0] $!.\n";

$nl=0;
while (<IFILE>){
    s/^\s+//;
    s/\s+$//;
    next if /^\$/;
#    chop;
    @f=split;
    $nl++;

    $nl==1 && do{
	($xm,$ym,$zm)=@f;
	next;
    };

    $xm=($f[0] < $xm) ? $f[0] : $xm;
    $ym=($f[1] < $ym) ? $f[1] : $ym;
    $zm=($f[2] < $zm) ? $f[2] : $zm;
}
close IFILE;
open(OFILE, ">$ARGV[1]") || die "$pgnam: $ARGV[1] $!.\n";
print OFILE "$xm $ym $zm";
close OFILE;
