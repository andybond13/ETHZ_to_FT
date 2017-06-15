# vector routines

use Math::Trig;

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
    my (@A);
    my ($n);

    @A = ($_[0],$_[1],$_[2]);
    $n = &Vnorm(@A);
    if($n == 0){
	die "$0: vector has zero length, line $.\n";
    }
    else{
	($A[0]/$n, $A[1]/$n, $A[2]/$n);
    }
}

sub ABdistance {
    sqrt(
	($_[0]-$_[3]) * ($_[0]-$_[3]) +
	($_[1]-$_[4]) * ($_[1]-$_[4]) +
	($_[2]-$_[5]) * ($_[2]-$_[5]) 
	);
}

# rotate point around axis
sub PointRotate {
    my @field=@_[0..2];    # point
    my @P    =@_[3..5];    # rotation point
    my @O3   =@_[6..8];    # rotation axis
    my $alpha=$_[9];       # rotation angle

    my @R;
    my $dr;
    my $s;
    my @O2;
    my @O1;


    @O3 = &Vunit(@O3);      # make sure O3 is unit vector
    @R  = &AmB(@field,@P);  # vector from rotation point to point, R
    $dr = &Vnorm(@R);       # unit vector in R direction
    @O2 = &AxB(@O3, @R);    # vector perpendicular to rotation axis, O3, and R
    $s = &Vnorm(@O2);       # radius of rotation, if O3 and R are co-linear, no need for rotation
    if($dr*$s>0){
	@O2 = &AxS(@O2, 1.0/$s);   # unit vector ortogonal to radius and O3
	@O1 = &AxB(@O2, @O3);      # unit vector in direction of the radius
	$f1 = $s*(cos($alpha)-1);  # in the direction oposite to O1
	$f2 = $s*sin($alpha);      # in the direction O2
	@v1 = &AxS(@O1, $f1);
	@v2 = &AxS(@O2, $f2);
	$field[0] += $v1[0]+$v2[0];
	$field[1] += $v1[1]+$v2[1];
	$field[2] += $v1[2]+$v2[2];
    }
    return @field;
}

# signed distance form a plane
sub PointDistanceFromPlane {
    my @F = @_[0..2];    # point
    my @P = @_[3..5];    # plane point
    my @N = @_[6..8];    # plane normal

    my @nu;
    my @v1;
    my $dist;

    @nu=&Vunit(@N);
    @v1=&AmB(@F, @P);
    $dist=&AdotB(@nu, @v1);

    return $dist;
}

# 
sub PointProjectToPlane {
    my @F = @_[0..2];    # point
    my @P = @_[3..5];    # plane point
    my @N = @_[6..8];    # plane normal

    my @nu;
    my @v1;
    my $dist;
    my @FP;

    @nu=&Vunit(@N);
    @v1=&AmB(@F, @P);
    $dist=&AdotB(@nu, @v1);
    @FP=&AmB(@F, 
	     &AxS(@nu, $dist)
	);

    return @FP;
}

# signed distance form a plane and angle wrt to in plane vector
sub PointDistanceAndAngleFromPlane {
    my @F = @_[0..2];    # point
    my @P = @_[3..5];    # plane point
    my @N = @_[6..8];    # plane normal
    my @O = @_[9..11];    # plane orientation vector

    my @nu;
    my @ou;
    my @fu;
    my @ouXfu;
    my @FP;
    my @FPN;
    my @FPU;
    my $dist;

    my $sang;
    my $cang;
    my $angs;
    my $angc;
    my $angle;

# unit vector in normal direction
    @nu=&Vunit(@N);

# unit vector in-plane for orientation
    @ou=&Vunit(
 # subtract from O the component that is in nu direction
	&AmB(
	     @O, 
	     &AxS(@nu, 
		  &AdotB(@nu, @O)
	     ))
	);

    @FP=&AmB(@F, @P);         # vector from plane point to point
    $dist=&AdotB(@nu, @FP);   # FP component in nu
    @FPN=&AxS(@nu, $dist);    # FP vector in nu direction
    @FPU=&AmB(@FP, @FPN);     # FP vector in ou direction
    @fu=&Vunit(@FPU);         # unit of FP vector in ou direction

    @ouXfu=&AxB(@ou, @fu);    # 1x1xsin(ou,fu) in nu direction

    $sang=&AdotB(@nu, @ouXfu); # in or oposite direction of nu, sin of angle btw ou & fu
    $cang=&AdotB(@ou, @fu);    # in or oposite direction of ou, cos of angle btw ou & fu

#    $angs=asin($sang);
    $angc=acos($cang);

# now need to figure out correct angle

    if($sang > 0){
	$angle=$angc;
    }
    else{
	$angle=2*pi-$angc;
    }

    return ($dist, $angle);
}

sub PointScaleDistanceInBounds {
    my @F = @_[0..2];        # point
    my @P = @_[3..5];        # origin point
    my @N = @_[6..8];        # orientation direction
    my @DBOUNDS = @_[9..10]; # bounds in which to scale
    my $scale = $_[11];

    my @n;
    my @v;
    my $d;
    my @FS;

    @n=&Vunit(@N);
    @v=&AmB(@F, @P);
    $d=(&AdotB(@n, @v) >= 0) ? 1 : -1; # determine orientation
    $d=&Vnorm(@v) * $d;

    if($d >= $DBOUNDS[0] && $d <= $DBOUNDS[1]){
	$d*=$scale;
	@FS=&ApB(@P,
		 &AxS(@v,$d));
	return @FS;
    }
    else{
	return @F;
    }
}

sub PointScaleNormalDistanceInBounds {
    my @F = @_[0..2];        # point
    my @P = @_[3..5];        # plane point
    my @N = @_[6..8];        # plane normal
    my @DBOUNDS = @_[9..10]; # bounds in which to scale
    my $scale = $_[11];

    my @n;
    my @v;
    my $d;

    my @FN;  # normal distance component 
    my @FU;  # in-plane distance component
    my @FS;

    @n=&Vunit(@N);
    @v=&AmB(@F, @P);
    $d=&AdotB(@n, @v); # determine normal distance component
    @FN=&AxS(@n, $d);  
    @FU=&AmB(@v, @FN);

    if($d >= $DBOUNDS[0] && $d <= $DBOUNDS[1]){
	@FN=&AxS(@n, $scale);
	@FS=&ApB(@P,@FN);
	@FS=&ApB(@FS,@FU);
	return @FS;
    }
    else{
	return @F;
    }
}
