function plotEllipsoid(a,b,ra,rb,rc,rc2,nc)
    theta=[-pi:0.1:pi];
    phi=[0:0.1:pi];
    for i=1:length(theta)
        for j=1:length(phi)
            r1 = a*[cos(theta(i))*sin(phi(j));sin(theta(i))*sin(phi(j));cos(phi(j))];
            r2 = b*[cos(theta(i))*sin(phi(j));sin(theta(i))*sin(phi(j));cos(phi(j))];
            xx1(i,j) = r1(1,:)+ra(1);
            yy1(i,j) = r1(2,:)+ra(2);
            zz1(i,j) = r1(3,:)+ra(3);
            xx2(i,j) = r2(1,:)+rb(1);
            yy2(i,j) = r2(2,:)+rb(2);
            zz2(i,j) = r2(3,:)+rb(3);
        end
    end
    plot3(xx1,yy1,zz1,'r')
    hold on
    plot3(xx2,yy2,zz2,'g')
    plot3(rc(1),rc(2),rc(3),'o')
    plot3(rc2(1),rc2(2),rc2(3),'o')
    plot3([a(1,1)+ra(1),ra(1)-a(1,1)],[a(2,1)+ra(2),ra(2)-a(2,1)],[a(3,1)+ra(3),ra(3)-a(3,1)],'k*-.')
    plot3([a(1,2)+ra(1),ra(1)-a(1,2)],[a(2,2)+ra(2),ra(2)-a(2,2)],[a(3,2)+ra(3),ra(3)-a(3,2)],'k*-.')
    plot3([a(1,3)+ra(1),ra(1)-a(1,3)],[a(2,3)+ra(2),ra(2)-a(2,3)],[a(3,3)+ra(3),ra(3)-a(3,3)],'k*-.')
    plot3([b(1,1)+rb(1),rb(1)-b(1,1)],[b(2,1)+rb(2),rb(2)-b(2,1)],[b(3,1)+rb(3),rb(3)-b(3,1)],'k*-.')
    plot3([b(1,2)+rb(1),rb(1)-b(1,2)],[b(2,2)+rb(2),rb(2)-b(2,2)],[b(3,2)+rb(3),rb(3)-b(3,2)],'k*-.')
    plot3([b(1,3)+rb(1),rb(1)-b(1,3)],[b(2,3)+rb(2),rb(2)-b(2,3)],[b(3,3)+rb(3),rb(3)-b(3,3)],'k*-.')
    plot3(theta*nc(1)/2+rc(1),theta*nc(2)/2+rc(2),theta*nc(3)/2+rc(3))
    plot3(theta*nc(1)/2+rc2(1),theta*nc(2)/2+rc2(2),theta*nc(3)/2+rc(3))
    %plot(nc(1),nc(2),'kx')
    %plot(theta*nc(1)/2,theta*nc(2)/2,'k')
    
    xlabel('x')
    ylabel('y')
    zlabel('z')
    axis equal