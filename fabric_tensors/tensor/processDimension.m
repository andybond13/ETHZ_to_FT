function out = processDimension(in,dim)
%Andrew Stershic
%if 3-d leave as is
%if 2-d make into axisymmetric 0,r,z format where r= sqrt(x^2+y^2)


if (dim == 2)
    r = sqrt( in(1,:).^2 + in(2,:).^2 ); 
    z = in(3,:); 
    in = [zeros(size(r));r;z];
else
    assert(dim == 3)
end

out = in;% * diag(w) * length(w)/sum(w);