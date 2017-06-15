%Andrew Stershic
%ref: http://woodem.eu/doc/theory/geom/ellipsoid.html
%http://www.youtube.com/watch?v=cBnz4el4qX8

%input = center
%        radii (semi-axis length)
%        eigen-vectors (principal axis unit vectors)
%        plot (1 = yes, 0 = no)
function [mu,nc] = ellipsoidContact(centerA,radiiA,evecsA,centerB,radiiB,evecsB,plot)
ex = -2;

mu = -1;
nc = [0;0;0];

%check if intersection is even possible
dist = norm(centerA'-centerB');
if (dist > max(radiiA)+max(radiiB))
    %no contact possible
    return;
end

%ellipsoid intersection
a = [evecsA(1:3)'*radiiA(1) evecsA(4:6)'*radiiA(2) evecsA(7:9)'*radiiA(3)];
ra = centerA';
[ua,sa,va] = svd(a);
sa = diag(sa);
A = sa(1)^ex*ua(:,1)*ua(:,1)' + sa(2)^ex*ua(:,2)*ua(:,2)' + sa(3)^ex*ua(:,3)*ua(:,3)';

b = [evecsB(1:3)'*radiiB(1) evecsB(4:6)'*radiiB(2) evecsB(7:9)'*radiiB(3)];
rb = centerB';
[ub,sb,vb] = svd(b);
sb = diag(sb);
B = sb(1)^ex*ub(:,1)*ub(:,1)' + sb(2)^ex*ub(:,2)*ub(:,2)' + sb(3)^ex*ub(:,3)*ub(:,3)';

R = rb-ra;
invA = inv(A);
invB = inv(B);

syms x
S=@(x) x*(1-x)*R'*inv((1-x)*invA+x*invB)*R;
dS = @(xs) vpa(subs(diff(S,x),x,xs));
dS2 = @(xs) vpa(subs(diff(S,x,2),x,xs));
dS3 = @(xs) vpa(subs(diff(S,x,3),x,xs));

t = sa(1)/(sa(1)+sb(1));
for n=1:10
    t = t - dS(t)/dS2(t)/(1-dS(t)*dS3(t)/(2*dS2(t)^2));
end
t = vpa(t);
F = S(t);
mu = sqrt(F);
G = vpa((1-t)*invA + t*invB);
nc = G\R;
rc = vpa(ra+(1-t)*invA*nc);
rc2 = vpa(rb - t*invB*nc);
if (mu > 1)
    %no contact
    return;
end

d = norm(R);
unp = vpa(d*(1-1/mu));
un = vpa(unp * R'*nc / (norm(nc)*d));   %unp * R'*nc / (norm(nc)*norm(R))

if (plot == 1)
    plotEllipsoid(a,b,ra,rb,rc,rc2,nc)
end