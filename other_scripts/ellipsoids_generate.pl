#!/usr/bin/perl -w

# Written by:
# Srdjan Simunovic
# Oak Ridge National Laboratory
# email: simunovics@ornl.gov
#
# Your mileage may vary, use at your own risk.

# Input file for ellipsoids must be space separated, in the form:
# value xCenter yCenter zCenter Radius 1 Radius 2 Radius 3 Evec1_x Evec1_y Evec1_z Evec2_x Evec2_y Evec2_z Evec3_x Evec3_y Evec3_z a b c d e f g h i
# The lines in the file are commented with #

# in_file - input file (input)
# out_file - output mesh file (output)
# sphere_file - template sphere mesh file with radius (input)



# command line parsing, old school way
undef $debug;
@j=();

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
    print "ellipsoids_generate.pl: generate ellipsoid mesh file from ellipsoid definition\n";
    die    "usage: ellipsoids_generate.pl in_file out_file sphere_file [-Ddebug]\n";
}

# $pi = atan2(1,1) * 4;
# $third=1.0/3.0;
$vtot=0;
my @rest;
open(IFILE, "$ARGV[0]") || die "$0: $ARGV[0] $!\n";
while (<IFILE>){
    next if /^#/;
    s/^\s+//;
    s/\s+$//;
    next if /^$/;

# value xCenter yCenter zCenter Radius 1 Radius 2 Radius 3 Evec1_x Evec1_y Evec1_z Evec2_x Evec2_y Evec2_z Evec3_x Evec3_y Evec3_z a b c d e f g h i
    ($id,@C[0..2],@R[0..2],@I[0..2],@J[0..2],@K[0..2],@rest)=split;

    $kel++;
    print "$kel: $id\n" if $debug;
    $id0=$id;
    $vtot++;
    $id=$vtot;

    $ORIGIN{$id}=[ @C ];
    $GROUP{$id}= $id0;
    $AXES{$id}=[ @R ];
    @I=&Vunit( @I );
    @J=&Vunit( @J );
    @K=&Vunit( @K );
    $IPRIME{$id}=[ @I ];
    $JPRIME{$id}=[ @J ];
    $KPRIME{$id}=[ @K ];
}
close IFILE;


open(IFILE, "$ARGV[2]") || die "$0: $ARGV[2] $!\n";
while (<IFILE>){
    next if /^#/;

    /^$/ && do{
	print "   key $key completed, read $icnt\n"  if $debug;
	undef $key;   # empty line, keyword done
	next;
    };
	
    s/\s+$//;

    /^([A-Za-z]+)/ && do{   # keyword
	$key=$1;
	$icnt=0;
	$$key{'size'}=-1;
	print "Found key $key\n" if $debug;
	next;
    };

    $$key{'size'} == -1 && do{   # entity size 
	@a=split;
	$nkey=$a[0];
	die "Number of entities $key is @a\n" if @a>1;
	print "   Number of entities $key is $nkey\n"  if $debug;
	$$key{'size'}=$nkey;
	next;
    };

    $key eq 'Vertices' && do{
	@field=split;
	pop @field;
	$icnt++;
	$nn++;
	push @VTEMPL, @field;
	next;
    };

    $key eq 'Triangles' && do{
	$icnt++;
	@nds=split;
	pop @nds;

	$nt++;
	push @TRIA, @nds;
	next;
    };

}
close IFILE;

$NTOT=$nn*$kel;
$TTOT=$nt*$kel;


open(OFILE, ">$ARGV[1]") || die "$0: $ARGV[1] $!\n";

&print_header();

print OFILE "Vertices\n$NTOT\n";
print "blowing up ellipsoids\n" if $debug;

$i1void=1;
$i2void=$vtot;
for($ivoid=$i1void;$ivoid<=$i2void;$ivoid++){
    $Vnum=$ivoid;
    $g=$GROUP{$Vnum};

    $r1=   $AXES{$Vnum}[0];
    $r2=   $AXES{$Vnum}[1];
    $r3=   $AXES{$Vnum}[2];

    @v=@{ $ORIGIN{$Vnum} };

    @sphere=&blowup_ellipse($r1, $r2, $r3);

    for($j=0; $j< @sphere; $j+=3){
	$x=&AdotB(@{ $IPRIME{$ivoid} }, @sphere[$j..$j+2]);
	$y=&AdotB(@{ $JPRIME{$ivoid} }, @sphere[$j..$j+2]);
	$z=&AdotB(@{ $KPRIME{$ivoid} }, @sphere[$j..$j+2]);
	@sphere[$j..$j+2]=($x, $y, $z);
    }

    @sphere=&transl(@v, @sphere);

    for($i=0;$i<@sphere;$i+=3){
	@a=@sphere[$i..$i+2];
	print OFILE "@a $g\n";
    }
}
print "done\n" if $debug;

print OFILE "\n";

print OFILE "Triangles\n$TTOT\n";
print "triangles"  if $debug;
for($ivoid=$i1void;$ivoid<=$i2void;$ivoid++){
    print " $ivoid" if $debug;
    $noffset= ($ivoid-$i1void)*$nn;

    $g=$GROUP{$ivoid};

    for($j=0;$j<@TRIA;$j+=3){
	@a=@TRIA[$j..$j+2];
	$a[0]+=$noffset;
	$a[1]+=$noffset;
	$a[2]+=$noffset;
	print OFILE "@a $g\n";
    }
}
print OFILE "\nEnd\n";

print "\n" if $debug;;

sub blowup_ellipse{
    # blows up ellipse at center 0,0,0 with scales r1,r2,r3
    my $r1=shift @_;
    my $r2=shift @_;
    my $r3=shift @_;
    my $i;
    my @a;

    for($i=0; $i<@VTEMPL; $i+=3){
	$a[$i]  =$VTEMPL[$i]  *$r1;
	$a[$i+1]=$VTEMPL[$i+1]*$r2;
	$a[$i+2]=$VTEMPL[$i+2]*$r3;
    }

    return @a;
}

sub transl{
    my @v;
    my @s;
    my @a;
    my $i;

    @v=splice(@_,0,3);
    @s=@_;

    for($i=0;$i<@s;$i+=3){
	$a[$i]   = $s[$i]  +$v[0];
	$a[$i+1] = $s[$i+1]+$v[1];
	$a[$i+2] = $s[$i+2]+$v[2];
    }
    return @a;
}

sub rotate{
    my @P;
    my @O3;
    my $alpha;
    my @field;
    my @v;
    my $i;

    my (@R, @O1, @O2, @v1, @v2);
    my ($dr, $s, $f1, $f2);

    # rotate points in @v wrt to origin at @P, around vector defined
    # by @O3, for angle alpha (radians)

    @P=splice(@_,0,3);
    @O3=splice(@_,0,3);
    @O3=&Vunit(@O3);
    $alpha= shift @_;

#    print "P : @P\n";
#    print "O3: @O3\n";
#    print "al: $alpha\n";

    @v=@_;
    for($i=0;$i<@v;$i+=3){
	@field=@v[$i..$i+2];
	@R = &AmB(@field,@P);
	$dr = &Vnorm(@R);
	@O2 = &AxB(@O3, @R);
	$s = &Vnorm(@O2);
	if($dr*$s>0){
	    @O2 = &AxS(@O2, 1.0/$s);
	    @O1 = &AxB(@O2, @O3);
	    $f1 = $s*(cos($alpha)-1);
	    $f2 = $s*sin($alpha);
	    @v1 = &AxS(@O1, $f1);
	    @v2 = &AxS(@O2, $f2);
	    $field[0] = $field[0]+$v1[0]+$v2[0];
	    $field[1] = $field[1]+$v1[1]+$v2[1];
	    $field[2] = $field[2]+$v1[2]+$v2[2];
	}
	@v[$i..$i+2]=@field;
    }

    return @v;
}


sub by_numeric {$a <=> $b;}
sub by_mostly_numeric{
    ($a <=> $b) || ($a cmp $b);
}

sub print_header{
    print OFILE "MeshVersionFormatted 1\n\n";
    print OFILE "Dimension\n3\n\n";
}


sub ApB {
    ($_[0]+$_[3], $_[1]+$_[4], $_[2]+$_[5]);
}

sub AmB {
    ($_[0]-$_[3], $_[1]-$_[4], $_[2]-$_[5]);
}

sub AdotB {
    $_[0]*$_[3]+$_[1]*$_[4]+$_[2]*$_[5];
}

sub AxB {
    ($_[1]*$_[5] - $_[2]*$_[4],
     $_[2]*$_[3] - $_[0]*$_[5],
     $_[0]*$_[4] - $_[1]*$_[3]);
}

sub AxS {
    ($_[0]*$_[3], $_[1]*$_[3], $_[2]*$_[3]);
}

sub Vnorm {
    sqrt($_[0]*$_[0] + $_[1]*$_[1] + $_[2]*$_[2]);
}

sub Vunit {
    local(@A);
    local($n);

    @A = ($_[0],$_[1],$_[2]);
    $n = &Vnorm(@A);
    if($n == 0){
	print "Vunit: zero vector\n";
	(0, 0, 0);
    }
    else{
	($A[0]/$n, $A[1]/$n, $A[2]/$n);
    }
}

sub by_number {
    $a <=> $b;
}
