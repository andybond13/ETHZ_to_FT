% script to run fabric tensor maker using MMTensor
% Andrew Stershic

%multiplied by contact area

clear all
close all

%going across: 0 bar -> 2000bar
%going down : 90 wt  -> 96 wt
np = [7752 8248 9214 13993;...  %sph/ellipsoid approximation data
    8822 14340 11398 15382;...
    12906 14090 14948 15268;...
    18692 17511 19716 19764];

npL2 = [18701 18701 18701 18701; ...
    19963 19963 19963 19963; ...
    32496 32496 32496 32496;...
    52276 52276 52276 52276]; %ETH gradation->LIGGHTS2 spherical simulations

npL3 = [7870 7870 7870 7870; ...
    8805 8805 8805 8805; ...
    13038 13038 13038 13038;...
    18724 18724 18724 18724]; %ETH gradation->LIGGHTS3 spherical simulations

base = '/Users/andrewstershic/Desktop/battery/labeled_particles/NMC_90wt_0bar'
% base = '/Volumes/stershic-primary/andrewstershic/Code/LIGGGHTS-PUBLIC-L3/simulations/fabricTensors/from_withArea';
FA = zeros(2,4,8);
withArea = '_withArea';
dim = 3;

%voxel = 370nm per side (cube) = 0.37um

for wt = 90:2:96
    index = (wt - 90)/2 + 1;
    n_particles = np(index);
    n_particlesL2 = npL2(index);
    n_particlesL3 = npL3(index);
    series = [num2str(wt),'wt'];
    
    %Voxels
    fprintf('\n%u wt, voxels\n',wt);
    %     path = '../../labeled_particles/txt_ft_files/NMC_';
    path = [base,'/fromVoxels/',series,'/NMC_'];
    rest = 'bar_centroidal_withArea.out';
    results = './results/fromVoxels/';
    source = 'Voxels';
    cols = [3:5,7];
    factor = 1.0/9.0 * (0.37)^2;    %contacting voxels to area (taking 1/9th of 1x1 per contact - matches exactly for infinite plane)
    FA(:,index,1)=fabricTensor(path,rest,source,cols,results,series,n_particles,factor,withArea,dim);
    
    %Voxel-contacts
    fprintf('\n%u wt, voxel-contacts\n',wt);
    %     path = '../../labeled_particles/voxel_contacts/NMC_';
    path = [base,'/fromVoxel-contacts/',series,'/NMC_'];
    rest = 'bar_vecs_withArea.out';
    results = './results/fromVoxel-contacts/';
    source = 'Voxel contacts';
    cols = [3:5,7];
    factor = 1.0/9.0 * (0.37)^2;    %contacting voxels to area (taking 1/9th of 1x1 per contact - matches exactly for infinite plane)
    FA(:,index,2)=fabricTensor(path,rest,source,cols,results,series,n_particles,factor,withArea,dim);
    
    %Voxel-contacts - clustered
    fprintf('\n%u wt, voxel-contacts-clustered\n',wt);
    %     path = '../../labeled_particles/voxel_contacts/NMC_';
    path = [base,'/fromVoxel-contacts-clustered/',series,'/NMC_'];
    rest = 'bar_vecs_clustered_withArea.out';
    results = './results/fromVoxel-contacts-clustered/';
    source = 'Voxel contacts (clustered)';
    cols = [3:5,7];
    factor = 1.0/9.0 * (0.37)^2;    %contacting voxels to area (taking 1/9th of 1x1 per contact - matches exactly for infinite plane)
    FA(:,index,3)=fabricTensor(path,rest,source,cols,results,series,n_particles,factor,withArea,dim);
    
% %    Ellipsoid centroids
%     fprintf('\n%u wt, ellipsoids centroids\n',wt);
%         path = ['../../labeled_particles/ell_centroid_files/',series,'/NMC_'];
%     path = [base,'/fromEllipsoid-centroids/',series,'/NMC_'];
%     rest = 'bar_centroidcontacts.out';
%     results = './results/fromEllipsoid-centroids/';
%     source = 'Ellipsoid centroids';
%     cols = 3:5;
%     FA(:,index,3)=fabricTensor(path,rest,source,cols,results,series,n_particles);
%     
%     %Ellipsoid contacts
%     fprintf('\n%u wt, ellipsoid contacts\n',wt);
%     %     path = ['../../labeled_particles/txt_ell_files/'];
%     path = [base,'/fromEllipses/',series,'/NMC_'];
%     rest = 'bar_contacts_only.out';
%     results = './results/fromEllipses/';
%     source = 'Ellipsoid contacts';
%     cols = 3:5;
%     FA(:,index,4)=fabricTensor(path,rest,source,cols,results,series,n_particles);
%     
    %Spherical
    fprintf('\n%u wt, spherical\n',wt);
    path = [base,'/fromSph/',series,'/NMC_'];
    rest = 'bar_withArea.out';
    results = './results/fromSph/';
    source = 'Spherical';
    cols = [3:5,9];
    factor =  (0.37)^2;              %contact area( pixels^2) to area
    FA(:,index,4)=fabricTensor(path,rest,source,cols,results,series,n_particles,factor,withArea,dim);
%     
%     
%     %DEM-LIGGGHTS2
%     fprintf('\n%u wt, DEM L2\n',wt);
%     path = [base,'/fromL2/',series,'/NMC_'];
%     rest = 'bar_contacts_only.out';
%     results = './results/fromL2/';
%     source = 'LIGGGHTS2';
%     cols = 3:5;
%     FA(:,index,6)=fabricTensor(path,rest,source,cols,results,series,n_particlesL2);
%     
    %DEM-LIGGGHTS3
    fprintf('\n%u wt, DEM L3\n',wt);
    path = [base,'/fromL3/',series,'/NMC_'];
    rest = 'bar_contacts_only_withArea.out';
    results = './results/fromL3/';
    source = 'LIGGGHTS3';
    cols = [3:5,9];
    factor = (1e4)^2;               %contact area (cm^2) to (um^2) : (10^4um/cm)^2
    FA(:,index,5)=fabricTensor(path,rest,source,cols,results,series,n_particlesL3,factor,withArea,dim);
    
    %DEM-LIGGGHTS3 w/VF
    fprintf('\n%u wt, DEM L3-VF\n',wt);
    path = [base,'/fromL3-VF/',series,'/NMC_'];
    rest = 'bar_contacts_only_withArea.out';
    results = './results/fromL3-VF/';
    source = 'LIGGGHTS3-VF';
    cols = [3:5,9];
    factor = (1e4)^2;               %contact area (cm^2) to (um^2) : (10^4um/cm)^2
    FA(:,index,6)=fabricTensor(path,rest,source,cols,results,series,n_particlesL3,factor,withArea,dim);
    
    %DEM-LIGGGHTS3 w/o friction (actually only 90wt, rest is copy of L3)
    fprintf('\n%u wt, DEM L3-NF\n',wt);
    path = [base,'/fromL3-NF/',series,'/NMC_'];
    rest = 'bar_contacts_only_withArea.out';
    results = './results/fromL3-NF/';
    source = 'LIGGGHTS3-NF';
    cols = [3:5,9];
    factor = (1e4)^2;               %contact area (cm^2) to (um^2) : (10^4um/cm)^2
    FA(:,index,7)=fabricTensor(path,rest,source,cols,results,series,n_particlesL3,factor,withArea,dim);
    
    %DEM-LIGGGHTS3 w/o friction (actually only 90wt, rest is copy of L3) -
    %VF
    fprintf('\n%u wt, DEM L3-NF-VF\n',wt);
    path = [base,'/fromL3-NF_VF/',series,'/NMC_'];
    rest = 'bar_contacts_only_withArea.out';
    results = './results/fromL3-NF_VF/';
    source = 'LIGGGHTS3-NF';
    cols = [3:5,9];
    factor = (1e4)^2;               %contact area (cm^2) to (um^2) : (10^4um/cm)^2
    FA(:,index,8)=fabricTensor(path,rest,source,cols,results,series,n_particlesL3,factor,withArea,dim);
    
    
end

%%
h = figure
k = figure
title('Total Contact Area comparison')
comp = [90:2:96];
xlabel('composition')
ylabel('contact area (\mu m^2)')
color = ['k','g','b','r','m','c','y','k'];
for i = 1:size(FA,3)
    sWA = [];
    sWD = [];
    sWdiff = [];
    for j = 1:size(FA(:,:,i),2)
        sWA(end+1) = FA(1,j,i);
        sWD(end+1) = FA(2,j,i);
    end
    sWdiff = sWD - sWA;
    figure(h)
    semilogy(comp,sWA,[color(i),'x-'])
    hold on
    semilogy(comp,sWD,[color(i),'o-.'])
    figure(k)
    semilogy(comp,sWdiff,[color(i),'x-'])
    hold on
end
figure(h);
title('Contact Area: 0 bar vs. 2000 bar')
legend('voxel-centroidal (0)','voxel-centroidal (2000)','voxel-contact (0)','voxel-contact (2000)','voxel-contact-cluster (0)','voxel-contact-cluster (2000)',...
    'spherical (0)','spherical (2000)','L3 (0)','L3 (2000)','L3-VF (0)','L3-VF (2000)','L3-NF (0)','L3-NF (2000)','L3-NF\_VF (0)','L3-NF\_VF (2000)')
figure(k);
title('Contact Area Difference: 2000 bar - 0 bar')
legend('voxel-centroidal','voxel-contact','voxel-contact-cluster','spherical','L3','L3-VF','L3-NF','L3-NF\_VF')
    