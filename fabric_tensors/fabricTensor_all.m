% script to run fabric tensor maker using MMTensor
% Andrew Stershic

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

% base = '/Users/andrewstershic/Desktop/battery/labeled_particles/NMC_90wt_000bar'
base = '/Volumes/stershic-primary/andrewstershic/Code/LIGGGHTS-PUBLIC-L3/simulations/fabricTensors';
FA = [];
factor = 1.0;
withArea = '';
dim = 3;
%display settings
Oheight = 600;
Owidth = 800;
fontsize = 20;
cb = 0; %0 = 3D, 1 = top, 2 = side
imageList = {};
%%
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
    rest = 'bar_contacts_only.out';
    results = './results/fromVoxels/';
    source = 'Voxels';
    cols = 3:5;
    printAxis = 0;
    [FA(:,index,1),imageList{end+1}]=fabricTensor(path,rest,source,cols,results,series,n_particles,factor,withArea,dim,Oheight,Owidth,fontsize,cb,printAxis);
    
    %Voxel-contacts
    fprintf('\n%u wt, voxel-contacts\n',wt);
    %     path = '../../labeled_particles/voxel_contacts/NMC_';
    path = [base,'/fromVoxel-contacts/',series,'/NMC_'];
    rest = 'bar_vecs.out';
    results = './results/fromVoxel-contacts/';
    source = 'Voxel contacts';
    cols = 3:5;
    [FA(:,index,2),imageList{end+1}]=fabricTensor(path,rest,source,cols,results,series,n_particles,factor,withArea,dim,Oheight,Owidth,fontsize,cb,0);
    
%     %Voxel-contacts - clustered - disabled 8/3/2015. Valid, but nearly same as Voxel-contacts
%     fprintf('\n%u wt, voxel-contacts-clustered\n',wt);
%     %     path = '../../labeled_particles/voxel_contacts/NMC_';
%     path = [base,'/fromVoxel-contacts-clustered/',series,'/NMC_'];
%     rest = 'bar_vecs_clustered_withArea.out';
%     results = './results/fromVoxel-contacts-clustered/';
%     source = 'Voxel contacts (clustered)';
%     cols = 3:5;
%     [FA(:,index,3),imageList{end+1}]=fabricTensor(path,rest,source,cols,results,series,n_particles,factor,withArea,dim,Oheight,Owidth,fontsize);
%     
%    Ellipsoid centroids
    fprintf('\n%u wt, ellipsoids centroids\n',wt);
        path = ['../../labeled_particles/ell_centroid_files/',series,'/NMC_'];
    path = [base,'/fromEllipsoid-centroids/',series,'/NMC_'];
    rest = 'bar_centroidcontacts.out';
    results = './results/fromEllipsoid-centroids/';
    source = 'Ellipsoid centroids';
    cols = 3:5;
    [FA(:,index,4),imageList{end+1}]=fabricTensor(path,rest,source,cols,results,series,n_particles,factor,withArea,dim,Oheight,Owidth,fontsize,cb,0);
    
    %Ellipsoid contacts
    fprintf('\n%u wt, ellipsoid contacts\n',wt);
    %     path = ['../../labeled_particles/txt_ell_files/'];
    path = [base,'/fromEllipses/',series,'/NMC_'];
    rest = 'bar_contacts_only.out';
    results = './results/fromEllipses/';
    source = 'Ellipsoid contacts';
    cols = 3:5;
    [FA(:,index,5),imageList{end+1}]=fabricTensor(path,rest,source,cols,results,series,n_particles,factor,withArea,dim,Oheight,Owidth,fontsize,cb,0);
    
    %Spherical
    fprintf('\n%u wt, spherical\n',wt);
    path = [base,'/fromSph/',series,'/NMC_'];
    rest = 'bar.out';
    results = './results/fromSph/';
    source = 'Spherical';
    cols = 3:5;
    [FA(:,index,6),imageList{end+1}]=fabricTensor(path,rest,source,cols,results,series,n_particles,factor,withArea,dim,Oheight,Owidth,fontsize,cb,0);
    
%     
%     %DEM-LIGGGHTS2
%     fprintf('\n%u wt, DEM L2\n',wt);
%     path = [base,'/fromL2/',series,'/NMC_'];
%     rest = 'bar_contacts_only.out';
%     results = './results/fromL2/';
%     source = 'LIGGGHTS2';
%     cols = 3:5;
%     [FA(:,index,7),imageList{end+1}]=fabricTensor(path,rest,source,cols,results,series,n_particlesL2,factor,withArea,dim,height,width,fontsize);
%     
    %DEM-LIGGGHTS3
    fprintf('\n%u wt, DEM L3\n',wt);
    path = [base,'/fromL3/',series,'/NMC_'];
    rest = 'bar_contacts_only.out';
    results = './results/fromL3/';
    source = 'LIGGGHTS3';
    cols = 3:5;
    [FA(:,index,8),imageList{end+1}]=fabricTensor(path,rest,source,cols,results,series,n_particlesL3,factor,withArea,dim,Oheight,Owidth,fontsize,cb,0);
    
%     %DEM-LIGGGHTS3 w/VF
%     fprintf('\n%u wt, DEM L3-VF\n',wt);
%     path = [base,'/fromL3-VF/',series,'/NMC_'];
%     rest = 'bar_contacts_only.out';
%     results = './results/fromL3-VF/';
%     source = 'LIGGGHTS3-VF';
%     cols = 3:5;
%     [FA(:,index,9),imageList{end+1}]=fabricTensor(path,rest,source,cols,results,series,n_particlesL3,factor,withArea,dim,height,width,fontsize);
%     
    %DEM-LIGGGHTS3 w/o friction
    fprintf('\n%u wt, DEM L3-NF\n',wt);
    path = [base,'/fromL3-NF/',series,'/NMC_'];
    rest = 'bar_contacts_only.out';
    results = './results/fromL3-NF/';
    source = 'LIGGGHTS3-NF';
    cols = 3:5;
    [FA(:,index,10),imageList{end+1}]=fabricTensor(path,rest,source,cols,results,series,n_particlesL3,factor,withArea,dim,Oheight,Owidth,fontsize,cb,0);
    
%     %DEM-LIGGGHTS3 w/o friction (actually only 90wt, rest is copy of L3) -
%     %VF
%     fprintf('\n%u wt, DEM L3-NF-VF\n',wt);
%     path = [base,'/fromL3-NF_VF/',series,'/NMC_'];
%     rest = 'bar_contacts_only.out';
%     results = './results/fromL3-NF_VF/';
%     source = 'LIGGGHTS3-NF';
%     cols = 3:5;
%     [FA(:,index,11),imageList{end+1}]=fabricTensor(path,rest,source,cols,results,series,n_particlesL3,factor,withArea,dim,height,width,fontsize);    
%     
end

%%
%load images, crop, add +/-'s and save in place
close all

font = 24;
side = 0;
top = 0;
width = 400;
height = 500;
% widthCentering = 0.5; %0.5 = balanced left/right
% vertCentering = 0.5; %0.5 = balanced top/bottom
widthCentering = 0.55; %0.5 = balanced left/right
vertCentering = 0.4; %0.5 = balanced top/bottom
wbase = side + Owidth*(0.5 - widthCentering) + width*widthCentering-7;
vbase = top + Oheight*(0.5 - vertCentering) + height*vertCentering-25;
scale = 0.75;

for i = 1:4
    for j = 1:7
        idx = (i-1)*7 + j;
        
        zImg = imread(imageList{idx});
               
        zImg = imcrop(zImg,[(Owidth-width)*widthCentering (Oheight-height)*vertCentering width height]);  %xmin ymin width height (original 1200x900)
%         zImg = insertText(zImg,[wbase vbase],'x','FontSize',font,'BoxOpacity',0.0);
        if (j >= 1 && j <= 5)
            
            H = 0;
            W = 0;
            skew1 = 0; skew2 = 0;
            if (i == 2 && j == 1)
                W = 30*scale;
                skew2 = 50*scale;
            end
            if ((i == 1 || i == 2) && j == 3)
                W = 30*scale;
            end
            if ((j == 3) && (i ~= 4))
                H = 60*scale;
                skew1 = 50*scale;
            end
            if ((j == 4) && (i == 2 || i == 3))
                H = 50*scale;
            end
            zImg = insertText(zImg,[wbase+160*scale+W vbase-skew2],'+','FontSize',font,'BoxOpacity',0.0);
            zImg = insertText(zImg,[wbase-160*scale-W vbase+skew2],'+','FontSize',font,'BoxOpacity',0.0);
            zImg = insertText(zImg,[wbase-skew1 vbase+225*scale+H],'-','FontSize',font,'BoxOpacity',0.0);
            zImg = insertText(zImg,[wbase+skew1 vbase-225*scale-H],'-','FontSize',font,'BoxOpacity',0.0);
        end
        if (j == 6 || j == 7)
            v1 = sqrt(2)/2 * 120*scale; h1 = sqrt(2)/2 * 150*scale;
            if (i ~= 4 || j ~= 6)
                zImg = insertText(zImg,[wbase+v1 vbase+h1],'-','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase+v1 vbase-h1],'-','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase-v1 vbase+h1],'-','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase-v1 vbase-h1],'-','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase+120*scale vbase],'+','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase-120*scale vbase],'+','FontSize',font,'BoxOpacity',0.0);
                if (i ~= 1 || j ~= 7)
                    zImg = insertText(zImg,[wbase vbase+150],'+','FontSize',font,'BoxOpacity',0.0);
                    zImg = insertText(zImg,[wbase vbase-150],'+','FontSize',font,'BoxOpacity',0.0);
                end
            else
                zImg = insertText(zImg,[wbase+120*scale vbase],'+','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase-120*scale vbase],'+','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase vbase+150*scale],'-','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase vbase-150*scale],'-','FontSize',font,'BoxOpacity',0.0);
            end
        end
        
        imshow(zImg)

        %// Write to file
        outname = ['~/Dropbox/ORNL-paper1/submission/figure6/',num2str(i),'-',num2str(j),'.png'];
        imwrite(zImg,outname)
    end
end


%%
% 2-D images, Figure 7
close all
clear all
%need +/- label

npL3 = [7870 7870 7870 7870; ...
    8805 8805 8805 8805; ...
    13038 13038 13038 13038;...
    18724 18724 18724 18724]; %ETH gradation->LIGGHTS3 spherical simulations

% base = '/Users/andrewstershic/Desktop/battery/labeled_particles/NMC_90wt_000bar'
base = '/Volumes/stershic-primary/andrewstershic/Code/LIGGGHTS-PUBLIC-L3/simulations/fabricTensors';
FA = [];
factor = 1.0;
withArea = '';
dim = 3;
%display settings
Oheight = 600;
Owidth = 800;
fontsize = 24;
imageList = {};

for wt = 90:2:96
    index = (wt - 90)/2 + 1;
    n_particlesL3 = npL3(index);
    series = [num2str(wt),'wt'];

    %DEM-LIGGGHTS3 - side
    cb = 2;
    fprintf('\n%u wt, DEM L3\n',wt);
    path = [base,'/fromL3/',series,'/NMC_'];
    rest = 'bar_contacts_only.out';
    results = './results/fromL3/';
    source = 'LIGGGHTS3';
    cols = 3:5;
    [~,imageList{end+1}]=fabricTensor(path,rest,source,cols,results,series,n_particlesL3,factor,withArea,dim,Oheight,Owidth,fontsize,cb,0);
    
    %DEM-LIGGGHTS3 - top
    cb = 1;
    fprintf('\n%u wt, DEM L3\n',wt);
    path = [base,'/fromL3/',series,'/NMC_'];
    rest = 'bar_contacts_only.out';
    results = './results/fromL3/';
    source = 'LIGGGHTS3';
    cols = 3:5;
    [~,imageList{end+1}]=fabricTensor(path,rest,source,cols,results,series,n_particlesL3,factor,withArea,dim,Oheight,Owidth,fontsize,cb,0);
end
    
%%
close all
font = 36;
side = 0;
top = 0;
% width = 400;
% height = 500;
% % widthCentering = 0.5; %0.5 = balanced left/right
% % vertCentering = 0.5; %0.5 = balanced top/bottom
% widthCentering = 0.55; %0.5 = balanced left/right
% vertCentering = 0.4; %0.5 = balanced top/bottom
wbase = Owidth * 0.5 + 65; %side + Owidth*(0.5 - widthCentering) + width*widthCentering-7;
vbase = Oheight * 0.5 - 70; %top + Oheight*(0.5 - vertCentering) + height*vertCentering-25;
scale = 0.75;

for i = 1:4
    for j = 1:2
        idx = (i-1)*2 + j;
        
        zImg = imread(imageList{idx});
        
%         zImg = imcrop(zImg,[(Owidth-width)*widthCentering (Oheight-height)*vertCentering width height]);  %xmin ymin width height (original 1200x900)
        %         zImg = insertText(zImg,[wbase vbase],'x','FontSize',font,'BoxOpacity',0.0);
        
        
        H = 0;
        W = 0;
        skew1 = 0; skew2 = 0;
        
        xc = 0; yc = 0;
        if (i == 1)
            W = 100;
            H = 40;
            skew1 = 70;
        elseif (i == 2)
            xc = -45;  yc = -5;
            W = 80;
            H = 30;
            skew1 = 50;
        elseif (i == 3)
            xc = -60;  yc = -5;
            W = 60;
            H = 30;
            skew2 = 60;
        elseif (i == 4)
            xc = -30;  yc = -5;
            W = 60;
            H = 30;
            skew1 = -70;
        end
        
        if (j == 1)
            if (i <= 3)
                v1 = sqrt(2)/2 * (160*scale+W); h1 = sqrt(2)/2 * (225*scale+H);
%                 zImg = insertText(zImg,[wbase+xc vbase+yc],'x','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase+xc+160*scale+W vbase+yc-skew2],'+','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase+xc-160*scale-W vbase+yc+skew2],'+','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase+xc-skew1 vbase+yc+225*scale+H],'+','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase+xc+skew1 vbase+yc-225*scale-H],'+','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase+xc+v1 vbase+yc+h1],'-','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase+xc+v1 vbase+yc-h1],'-','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase+xc-v1 vbase+yc+h1],'-','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase+xc-v1 vbase+yc-h1],'-','FontSize',font,'BoxOpacity',0.0);
            else
%                 zImg = insertText(zImg,[wbase+xc vbase+yc],'x','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase+xc+160*scale+W vbase+yc-skew2],'+','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase+xc-160*scale-W vbase+yc+skew2],'+','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase+xc-skew1 vbase+yc+225*scale+H],'-','FontSize',font,'BoxOpacity',0.0);
                zImg = insertText(zImg,[wbase+xc+skew1 vbase+yc-225*scale-H],'-','FontSize',font,'BoxOpacity',0.0);
            end
        end
        
        imshow(zImg)
%         pause
        
        %// Write to file
        outname = ['~/Dropbox/ORNL-paper1/submission/figure7/',num2str(i),'-',num2str(j),'.png'];
        imwrite(zImg,outname)
    end
end



%%

% %%
% %3-D images: figure 6
% close all
% %perhaps put axis and/or colorbar on one diagram
% %need +/- label
% 
% for idx = 1 : numel(imageList);
%     images{idx} = imread(imageList{idx});
%     width = 360;
%     height = 500;
% %         widthCentering = 0.5; %0.5 = balanced left/right
% %     vertCentering = 0.5; %0.5 = balanced top/bottom
%     widthCentering = 0.6; %0.5 = balanced left/right
%     vertCentering = 0.45; %0.5 = balanced top/bottom
%     images2{idx} = imcrop(images{idx},[(Owidth-width)*widthCentering (Oheight-height)*vertCentering width height]);  %xmin ymin width height (original 1200x900)
% end
% 
% top = 200;
% side = 300;
% img2 = ones(top,size(images2{1},2),3)+1;
% img1 = ones(size(images2{1},1),side,3)+1;
% img3 = ones(top,side,3)+1;
% blank1 = im2uint8(img1);
% blank2 = im2uint8(img2);
% blank3 = im2uint8(img3);
% 
% %insert white images for labels
% images2 = {blank3 blank1 blank1 blank1 blank1 blank1 blank1 blank1 blank2 images2{1:7} ...
%     blank2 images2{8:14} blank2 images2{15:21} blank2 images2{22:28}};
% 
% zImg = cell2mat(reshape(images2, [7+1, 4+1]));
% % imshow(zImg)
% 
% r = 150;
% set(gcf, 'Units','inches', 'Position',[0 0 size(zImg,1)/r size(zImg,2)/r])
% 
% %pixels from top-left
% 
% font = fontsize*2;
% 
% zImg = insertText(zImg,[side*0.0 top*0.5],'Method','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side*0.4 top+height*0.5],'a','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side*0.4 top+height*1.5],'b','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side*0.4 top+height*2.5],'c','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side*0.4 top+height*3.5],'d','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side*0.4 top+height*4.5],'e','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side*0.4 top+height*5.5],'f','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side*0.4 top+height*6.5],'f''','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side*0.2+width*0.5 top*0.5],'90% wt. NMC','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side*0.2+width*1.5 top*0.5],'92% wt. NMC','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side*0.2+width*2.5 top*0.5],'94% wt. NMC','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side*0.2+width*3.5 top*0.5],'96% wt. NMC','FontSize',font,'BoxOpacity',0.0);
% 
% lines = [side 0 side top+height*7;...
%          0 top side+width*4 top;...
%          side+width 0 side+width top+height*7;...
%          side+width*2 0 side+width*2 top+height*7;...
%          side+width*3 0 side+width*3 top+height*7;...
%          0 top+height side+width*4 top+height;...
%          0 top+height*2 side+width*4 top+height*2;...
%          0 top+height*3 side+width*4 top+height*3;...
%          0 top+height*4 side+width*4 top+height*4;...
%          0 top+height*5 side+width*4 top+height*5;...
%          0 top+height*6 side+width*4 top+height*6];
% 
% zImg = insertShape(zImg,'Line',lines,'Color','black','Opacity',1.0,'LineWidth',5); %[10 10 5 5 5 5 5 5 5 5 5]
% 
% 
% wbase = side + 900*(0.5 - widthCentering) + width*widthCentering-55;
% vbase = top + 1200*(0.5 - vertCentering) + height*vertCentering-60;
% for i = 1:4
%     for j = 1:5
%         H = 0;
%         W = 0;
%         skew1 = 0; skew2 = 0;
%         if (i == 2 && j == 1)
%             W = 30;
%             skew2 = 50;
%         end
%         if ((i == 1 || i == 2) && j == 3)
%             W = 30;
%         end
%         if ((j == 3) && (i ~= 4))
%             H = 90;
%             skew1 = 50;
%         end
%         if ((j == 4) && (i == 2 || i == 3))
%             H = 50;
%         end
%         zImg = insertText(zImg,[width*(i-1)+wbase+180+W height*(j-1)+vbase-skew2],'+','FontSize',font,'BoxOpacity',0.0);
%         zImg = insertText(zImg,[width*(i-1)+wbase-180-W height*(j-1)+vbase+skew2],'+','FontSize',font,'BoxOpacity',0.0);
%         zImg = insertText(zImg,[width*(i-1)+wbase-skew1 height*(j-1)+vbase+250+H],'-','FontSize',font,'BoxOpacity',0.0);
%         zImg = insertText(zImg,[width*(i-1)+wbase+skew1 height*(j-1)+vbase-250-H],'-','FontSize',font,'BoxOpacity',0.0);
%     end
%     for j = 6:7
%         v1 = sqrt(2)/2 * 120; h1 = sqrt(2)/2 * 150;
%         if (i ~= 4 || j ~= 6)
%             zImg = insertText(zImg,[width*(i-1)+wbase+v1 height*(j-1)+vbase+h1],'-','FontSize',font,'BoxOpacity',0.0);
%             zImg = insertText(zImg,[width*(i-1)+wbase+v1 height*(j-1)+vbase-h1],'-','FontSize',font,'BoxOpacity',0.0);
%             zImg = insertText(zImg,[width*(i-1)+wbase-v1 height*(j-1)+vbase+h1],'-','FontSize',font,'BoxOpacity',0.0);
%             zImg = insertText(zImg,[width*(i-1)+wbase-v1 height*(j-1)+vbase-h1],'-','FontSize',font,'BoxOpacity',0.0);
%             zImg = insertText(zImg,[width*(i-1)+wbase+120 height*(j-1)+vbase],'+','FontSize',font,'BoxOpacity',0.0);
%             zImg = insertText(zImg,[width*(i-1)+wbase-120 height*(j-1)+vbase],'+','FontSize',font,'BoxOpacity',0.0);
%             if (i ~= 1 || j ~= 7)
%                 zImg = insertText(zImg,[width*(i-1)+wbase height*(j-1)+vbase+150],'+','FontSize',font,'BoxOpacity',0.0);
%                 zImg = insertText(zImg,[width*(i-1)+wbase height*(j-1)+vbase-150],'+','FontSize',font,'BoxOpacity',0.0);
%             end
%         else
%             zImg = insertText(zImg,[width*(i-1)+wbase+120 height*(j-1)+vbase],'+','FontSize',font,'BoxOpacity',0.0);
%             zImg = insertText(zImg,[width*(i-1)+wbase-120 height*(j-1)+vbase],'+','FontSize',font,'BoxOpacity',0.0);
%             zImg = insertText(zImg,[width*(i-1)+wbase height*(j-1)+vbase+150],'-','FontSize',font,'BoxOpacity',0.0);
%             zImg = insertText(zImg,[width*(i-1)+wbase height*(j-1)+vbase-150],'-','FontSize',font,'BoxOpacity',0.0);
%         end
%     end
% end
% 
% 
% imshow(zImg)
% 
% %// Write to file
% imwrite(zImg,'~/Dropbox/ORNL-paper1/submission/figure6.png') 
% 
% 
% 
% %%
% % 2-D images, Figure 7
% close all
% clear all
% %need +/- label
% 
% npL3 = [7870 7870 7870 7870; ...
%     8805 8805 8805 8805; ...
%     13038 13038 13038 13038;...
%     18724 18724 18724 18724]; %ETH gradation->LIGGHTS3 spherical simulations
% 
% % base = '/Users/andrewstershic/Desktop/battery/labeled_particles/NMC_90wt_000bar'
% base = '/Volumes/stershic-primary/andrewstershic/Code/LIGGGHTS-PUBLIC-L3/simulations/fabricTensors';
% FA = [];
% factor = 1.0;
% withArea = '';
% dim = 3;
% %display settings
% Oheight = 450;
% Owidth = 600;
% fontsize = 24;
% imageList = {};
% 
% for wt = 90:2:96
%     index = (wt - 90)/2 + 1;
%     n_particlesL3 = npL3(index);
%     series = [num2str(wt),'wt'];
% 
%     %DEM-LIGGGHTS3 - side
%     cb = 2;
%     fprintf('\n%u wt, DEM L3\n',wt);
%     path = [base,'/fromL3/',series,'/NMC_'];
%     rest = 'bar_contacts_only.out';
%     results = './results/fromL3/';
%     source = 'LIGGGHTS3';
%     cols = 3:5;
%     [~,imageList{end+1}]=fabricTensor(path,rest,source,cols,results,series,n_particlesL3,factor,withArea,dim,Oheight,Owidth,fontsize,cb);
%     
%     %DEM-LIGGGHTS3 - top
%     cb = 1;
%     fprintf('\n%u wt, DEM L3\n',wt);
%     path = [base,'/fromL3/',series,'/NMC_'];
%     rest = 'bar_contacts_only.out';
%     results = './results/fromL3/';
%     source = 'LIGGGHTS3';
%     cols = 3:5;
%     [~,imageList{end+1}]=fabricTensor(path,rest,source,cols,results,series,n_particlesL3,factor,withArea,dim,Oheight,Owidth,fontsize,cb);
% end
%     
% %%
% close all
% 
% for idx = 1 : numel(imageList);
%     images{idx} = imread(imageList{idx});
%     width = 600;
%     height = 450;
%     widthCentering = 0.5; %0.5 = balanced left/right
%     vertCentering = 0.5; %0.5 = balanced top/bottom
%     images2{idx} = imcrop(images{idx},[(Owidth-width)*widthCentering (Oheight-height)*vertCentering width height]);  %xmin ymin width height (original 1200x900)
% end
% 
% top = 100;
% side = 500;
% img2 = ones(top,size(images2{1},2),3)+1;
% img1 = ones(size(images2{1},1),side,3)+1;
% img3 = ones(top,side,3)+1;
% blank1 = im2uint8(img1);
% blank2 = im2uint8(img2);
% blank3 = im2uint8(img3);
% 
% %insert white images for labels
% images2 = {blank3 blank1 blank1 blank2 images2{1:2} ...
%     blank2 images2{3:4} blank2 images2{5:6} blank2 images2{7:8}};
% 
% zImg = cell2mat(reshape(images2, [2+1, 4+1]));
% % imshow(zImg)
% 
% r = 150;
% set(gcf, 'Units','inches', 'Position',[0 0 size(zImg,1)/r size(zImg,2)/r])
% 
% %pixels from bottom
% 
% font = fontsize*2;
% 
% zImg = insertText(zImg,[side*0.25 top*0.2],'Orientation','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side*0.25 top+height*0.3],'Side View','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side*0.25 top+height*1.3],'Top View','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side*0.4 top+height*0.5],'X-Z','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side*0.4 top+height*1.5],'X-Y','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side+width*0.25 top*0.2],'90% wt. NMC','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side+width*1.25 top*0.2],'92% wt. NMC','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side+width*2.25 top*0.2],'94% wt. NMC','FontSize',font,'BoxOpacity',0.0);
% zImg = insertText(zImg,[side+width*3.25 top*0.2],'96% wt. NMC','FontSize',font,'BoxOpacity',0.0);
% 
% lines = [side 0 side top+height*2;...
%          0 top side+width*4 top;...
%          side+width 0 side+width top+height*2;...
%          side+width*2 0 side+width*2 top+height*2;...
%          side+width*3 0 side+width*3 top+height*2;...
%          0 top+height side+width*4 top+height];
% 
% zImg = insertShape(zImg,'Line',lines,'Color','black','Opacity',1.0,'LineWidth',5); %[10 10 5 5 5 5 5 5 5 5 5]
% 
% imshow(zImg)
% 
% %// Write to file
% imwrite(zImg,'~/Dropbox/ORNL-paper1/submission/figure7.png') 

