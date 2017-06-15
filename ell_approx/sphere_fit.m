%http://www.mathworks.com/matlabcentral/fileexchange/24693-ellipsoid-fit
%Yury Petrov

function [ center, radii, evecs, v, volume ] = ellipsoid_fit(volVX, sXc, sYc, sZc)%, flag, equals )

%
% Fit an sphere to volume & centroid:
%
%
% Parameters:
% * volVX        - volume of particle
% * sXc,sYc,sZc  - centroid of particle (from particle stats)
%
%
% Output:
% * center    -  ellispoid center coordinates [xc; yc; zc]
% * ax        -  ellipsoid radii [a; b; c]
% * evecs     -  ellipsoid radii directions as columns of the 3x3 matrix
% * v         -  the 9 parameters describing the ellipsoid algebraically: 
%                Ax^2 + By^2 + Cz^2 + 2Dxy + 2Exz + 2Fyz + 2Gx + 2Hy + 2Iz = 1
%

%do as sphere with given centroid and volume ( same as spherical approximation)
%in the form Ax^2 + By^2 + Cz^2 + 2Dxy + 2Exz + 2Fyz + 2Gx + 2Hy + 2Iz = 1
center = [sXc sYc sZc];
r = (3/(4*pi)*volVX)^(1/3);
denom = r^2 - sXc^2 - sYc^2 - sZc^2;
v = [1 1 1  0 0 0 -2*sXc -2*sYc -2*sZc ]/denom;
radii = [r r r];
evecs = eye( 3 );
volume = volVX;


