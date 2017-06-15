function cluster = clusterContacts(list,A)

% 
% %fake!
% list = [list list];
% A = [A; A+10];

x1 = A(:,1); y1 = A(:,2); z1 = A(:,3);
x2 = A(:,4); y2 = A(:,5); z2 = A(:,6);

u = [x1 y1 z1];
v = [x2 y2 z2];

cluster = {};

% figure
% for i = 1:length(list)
%     plot3(x1,y1,z1,'rx')
%     hold on
%         plot3(x2,y2,z2,'bx')
% end

%adjacency
% c = zeros(length(u),length(u));
c = sparse(length(u),length(u));
for i = 1:length(list)
    for j = 1:length(list)
        if ( norm(u(i,:)-v(j,:),inf) == 1)
            c(i,j) = 1;
        end
    end
end

%graph connectivity matrix
% fprintf('*Calculating connectivity matrix\n');
c = c|(c*c');
% fprintf('*Done calculating contact clusters and normals\n');

i = 1;
clusters = 0;
while (i <= length(list))
    clusters = clusters + 1;
    line = c(i,:);
    fline = find(line);
    back = fline(end);
    cluster{clusters} = fline;
    i = back + 1;
end

assert(clusters == length(cluster));

%convert cluster index to list #
for i = 1:clusters
    for j = 1:length(cluster{i})
        cluster{i}(j) = list(cluster{i}(j));
    end
end



