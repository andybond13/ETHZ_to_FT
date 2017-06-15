%find volume of convex hull

function [ vol, k ] = volumeCH(x,y,z)
xx = -1:.05:1;
yy = abs(sqrt(xx));
k = convhull(x,y,z);
%     trimesh(k,x,y,z)
%     hold on
%     plot3(x,y,z,'b*')

vol = 0.0;
for i=1:length(k)
    p1 = [x(k(i,1)) y(k(i,1)) z(k(i,1))];
    p2 = [x(k(i,2)) y(k(i,2)) z(k(i,2))];
    p3 = [x(k(i,3)) y(k(i,3)) z(k(i,3))];
    vol = vol + dot(p1, cross(p2, p3))/6;
    
end

end

