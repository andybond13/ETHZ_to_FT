%evaluate significance, return new list without outliers

function [x,y,z] = outlierRemoval(in)

    threshold = 6;
    size = length(in);
    x = in(1:size/3)';
    y = in(size/3+1:size/3*2)';
    z = in(size/3*2+1:size)';

    c = [mean(x) mean(y) mean(z)];
    s = sqrt([var(x) var(y) var(z)]);
    zs = zeros(size/3,3);
    zs = [(x-c(1))/s(1) (y-c(2))/s(2) (z-c(3))/s(3)];
    r = [];
    
    for i = 1:size/3
        m = max(zs(i,:));
        if (m > threshold)
            %remove columns 
            r(end+1) = i;
        end
    end
    
    x(r) = [];
    y(r) = [];
    z(r) = [];
    x = x'; y = y'; z = z';
end

