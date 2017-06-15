% main.m
% Andrew Stershic
% April 15, 2014
% process voxel contact data to make clustered contact planes
% updated April 20, 2015
% now includes number of contacts for area calculation

close all;
clear all;

for I=90%[90,92,94,96]
   for J=0%[0,300,600,2000]

% read data
wt = I;
bar = J;
% file  = ['../NMC_',num2str(wt),'wt_',num2str(bar),'bar/NMC_',num2str(wt),'wt_',num2str(bar),'bar'];
stats = ['/Volumes/stershic-primary/andrewstershic/Desktop/gransimulations/batteryTomography/particle_stats/NMC_',num2str(wt),'wt_',num2str(bar),'bar.csv'];
% inputfile = [file '_pairs.txt'];
file = ['/Users/andrewstershic/Desktop/battery/delaunay/NMC_90wt_0bar_100'];
inputfile = [file '-contacts.txt'];
outputfile = [file '_vecs_withArea.txt'];
centroidalfile = [file '_centroidal_withArea.txt'];
contact_centroid_file = [file '_contact_centroids.txt'];
fprintf('*Reading file %s\n',inputfile);
A=dlmread(inputfile);
fprintf('*File %s has been read\n',inputfile);
V = [];
V2 = [];
V3 = [];
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
fprintf('*Calculating contact clusters and normals\n');
for i = 1:length(pairs1)
    for j = 1:length(pairs2(i))
        list = indices{i}{j};
        num = length(list);
        %fprintf('  %u & %u : %u contacting voxel pairs\n',pairs1(i), pairs2{i}, num);
        
%                 %plot
%                 plot3(A(list,1),A(list,2),A(list,3),'x')
%                 hold on
%                 plot3(A(list,4),A(list,5),A(list,6),'rx')
%         
        %list = all contacts: NO clustering!!
        
        %find contact vector of cluster
        pts1 = A(list,1:3);
        pts2 = A(list,4:6);

        if (num > 1)
            m1 = mean(pts1); m2 = mean(pts2);
        else
            m1 = pts1; m2 = pts2;
        end
        vr = m2-m1; v = vr/norm(vr); %vectors are between contact cluster centroids
        
        cr = 0.5*(m1+m2);           %centroid of contact points... (9/7/15)
        
%                     plot3(m1(1),m1(2),m1(3),'kx'); plot3(m2(1),m2(2),m2(3),'kx'); plot3([m1(1) m2(1)],[m1(2) m2(2)],[m1(3) m2(3)],'k');
        %[v' v1 v2 vAvg]
        
        V(end+1,:) = [v norm(vr) num pairs1(i) pairs2{i}(j) 1]; %num = length(cluster{k}) is the number of contacts that I want printed.
        
        
        vc = [sXc(pairs1(i))-sXc(pairs2{i}(j)) sYc(pairs1(i))-sYc(pairs2{i}(j)) sZc(pairs1(i))-sZc(pairs2{i}(j)) ];
        V2(end+1,:) = [vc/norm(vc) norm(vc) num pairs1(i) pairs2{i}(j) 1];
        V3(end+1,:) = [cr pairs1(i) pairs2{i}(j)];
    end
end

%%

% write vector list to file
% fid = fopen(outputfile, 'w+');
% fid2 = fopen(centroidalfile, 'w+');
fid3 = fopen(contact_centroid_file, 'w+');
for i=1:size(V, 1)
%     fprintf(fid, '%f %f %f %f %f %u %u %u\n', V(i,1), V(i,2), V(i,3), V(i,4), V(i,5), V(i,6), V(i,7), V(i,8) );
%     fprintf(fid2, '%f %f %f %f %f %u %u %u\n', V2(i,1), V2(i,2), V2(i,3), V2(i,4), V2(i,5), V2(i,6), V2(i,7), V2(i,8));
    fprintf(fid3, '%f %f %f %u %u\n', V3(i,1), V3(i,2), V3(i,3), V3(i,4), V3(i,5));
end
% fclose(fid);
% fclose(fid2);
fclose(fid3);

fprintf('Number of contacts: V1 = %u, V2 = %u, V3 = %u \n',length(V),length(V2),length(V3));

    end
end

