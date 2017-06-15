function [A,pair1,pair2,indices] = find_particle_pairs(A)

%for every particle, pair1
%   want to find paired particles, pair2
%   and indices, indices

p1 = A(:,7);
p2 = A(:,8);


pair1 = [];
pair2 = {};
indices = {};

for i=1:length(p1)
    P1 = p1(i);
    P2 = p2(i);
    
    if (P1 > P2)
        temp = P1;
        P1 = P2;
        P2 = temp;
        temp = A(i,1:3);
        A(i,1:3) = A(i,4:6);
        A(i,4:6) = temp;
    end
    
    if (ismember(P1,pair1) == 0)
        pair1(end+1) = P1;
        i1 = length(pair1);
    elseif (ismember(P1,pair1) == 1)
        i1 = find(pair1 == P1);
        assert(length(i1) == 1);
    else
        assert(1==0);
    end
    
    if (length(pair2) < i1)
        pair2{i1} = [P2];
        i2 = 1;
    else
        if (ismember(P2,pair2{i1}) == 1)
            i2 = find(pair2{i1} == P2);
            assert(length(i2) == 1);
        else
            pair2{i1}(end+1) = P2;
            i2 = length(pair2{i1});
        end
    end
    
    if (length(indices) < i1)
        indices{i1} = {};
    end
    if (length(indices{i1}) < i2)
        indices{i1}{i2} = [];
    end
    indices{i1}{i2}(end+1) = i;
end