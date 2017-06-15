% main.m
% Andrew Stershic
% April 15, 2014
% process voxel contact data to make clustered contact planes
% updated April 20, 2015
% now includes number of contacts for area calculation
% clusters contacts between same particles: e.g. x-x....x-x = two clusters
close all;
clear all;

for I=[90]
   for J=[0]
       
% read data
wt = I;
bar = J;
file  = ['../NMC_',num2str(wt),'wt_',num2str(bar),'bar/NMC_',num2str(wt),'wt_',num2str(bar),'bar'];
stats = ['/Volumes/stershic-primary/andrewstershic/Desktop/gransimulations/batteryTomography/particle_stats/NMC_',num2str(wt),'wt_',num2str(bar),'bar.csv'];
inputfile = [file '_pairs.txt'];
outputfile = [file '_vecs_clustered_withArea.txt'];
centroidalfile = [file '_centroidal_clustered_withArea.txt'];
fprintf('*Reading file %s\n',inputfile);
A=dlmread(inputfile);
fprintf('*File %s has been read\n',inputfile);
V = [];
V2 = [];
% figure
%%

% A=A(1:1000,:);
% group by particle
fprintf('*Grouping contacts by particle pair\n');
[A,pairs1,pairs2,indices] = find_particle_pairs(A);

fprintf('*Loading particle statistics\n');
statsdata = csvread(stats,1,0);
sXc = statsdata(:,9);
sYc = statsdata(:,10);
sZc = statsdata(:,11);

%%
h = waitbar(0,'Please wait...');
steps = 1000;

fprintf('*Calculating contact clusters and normals\n');
for i = 1:length(pairs1)
    for j = 1:length(pairs2(i))
        list = indices{i}{j};
        num = length(list);
        %fprintf('  %u & %u : %u contacting voxel pairs\n',pairs1(i), pairs2{i}, num);
        
%         %plot
%         plot3(A(list,1),A(list,2),A(list,3),'x')
%         hold on
%         plot3(A(list,4),A(list,5),A(list,6),'rx')
        
        %cluster contacts
        cluster = clusterContacts(list,A(list,1:6));
        waitbar( i/length(pairs1), h, sprintf('Pair %u of %u',i,length(pairs1)) ) ;

%         if (length(cluster) > 1) 
%             length(cluster)
%         end
%         assert(length(cluster) == 1);
%         fprintf('(i,j) = (%u,%u)   number of clusters = %u \n',i,j,length(cluster))
        for k = 1:length(cluster)
            %find contact vector of cluster
            pts1 = A(cluster{k},1:3);
            pts2 = A(cluster{k},4:6);

            if (length(cluster{k}) > 1)
                m1 = mean(pts1); m2 = mean(pts2);
            else
                m1 = pts1; m2 = pts2;
            end
            vr = m2-m1; v = vr/norm(vr); %vectors are between contact cluster centroids
%             plot3(m1(1),m1(2),m1(3),'kx'); plot3(m2(1),m2(2),m2(3),'kx'); plot3([m1(1) m2(1)],[m1(2) m2(2)],[m1(3) m2(3)],'k');
            
            V(end+1,:) = [v norm(vr) length(cluster{k}) pairs1(i) pairs2{i}(j) k]; %length(cluster{k}) is the number of contacts that I want printed.
            
        end
        
        vc = [sXc(pairs1(i))-sXc(pairs2{i}(j)) sYc(pairs1(i))-sYc(pairs2{i}(j)) sZc(pairs1(i))-sZc(pairs2{i}(j)) ];
        V2(end+1,:) = [vc/norm(vc) norm(vc) num pairs1(i) pairs2{i}(j) 1]; %num = is the number of contacts that I want printed.
    end
end
close(h)

%%

% write vector list to file
fid = fopen(outputfile, 'w+');
fid2 = fopen(centroidalfile, 'w+');
for i=1:size(V, 1)
    fprintf(fid, '%f %f %f %f %f %u %u %u', V(i,1), V(i,2), V(i,3), V(i,4), V(i,5), V(i,6), V(i,7), V(i,8));
    fprintf(fid, '\n');
end
for i=1:size(V2, 1)
    fprintf(fid2, '%f %f %f %f %f %u %u %u', V2(i,1), V2(i,2), V2(i,3), V2(i,4), V2(i,5), V2(i,6), V2(i,7), V2(i,8));
    fprintf(fid2, '\n');
end
fclose(fid);
fclose(fid2);

fprintf('Number of contacts: V1 = %u, V2 = %u\n',length(V),length(V2));

    end
end

