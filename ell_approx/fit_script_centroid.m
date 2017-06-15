%%
%ellipsoid fit script
% ellipsoid contact list + particle_stats = Centroid Vectors
clear all
close all

%notes: the story is that I had run fit_script to record the particle
%numbers using i and j, which are indices but NOT the particle ids. Thus, I
%have to re-run the mesh loading sequence to recover this listing, so I
%know which are the actual particles. 

%I fixed the file (4/23) but have not rerun the fit_script to generate new
%output. but if I were to, the fit_script_centroid_this_does_not_work.m
%would actually work, since the ID's and not indices will be saved. This
%means that the centroid location can come from the particle stats (very
%accurate) rather than the centroid of the ellipsoid approximation (not as
%accurate).

for wt = 92:2:96;
for bar = [0,300,600,2000];
    
    
% target directory
path = ['/Volumes/Stershic-HybridHD/Users/andrewstershic/Desktop/gransimulations/batteryTomography/labeled_particles/NMC_',num2str(wt),'wt_',num2str(bar),'bar/mesh/'];
header = 'Island_';
files = dir(path);
meshfiles = {};
for i=1:length(files)
    name = files(i).name;
    if (length(name) < 5)
        continue
    end
    namestring = name(end-4:end);
    if (namestring == '.mesh')
        nameid = name(8:end-5);
        meshfiles{end+1} = nameid;
    end
end

ID = [];
CENTER = zeros(0,3);
RADII = zeros(0,3);
EVECS = zeros(3,3,0);
n = length(meshfiles);
for i = 1:n
    % read file, get points
    file = [path header meshfiles{i} '.mesh'];
    fprintf('%s.mesh : %u of %u\n',meshfiles{i},i, length(meshfiles))
    fid = fopen(file);
    tline = fgetl(fid);
    vertices = 0;
    vertnext = 0;
    X = []; Y = []; Z = [];
    count = 0;
    while ischar(tline)
        %         disp(tline)
        tline = fgetl(fid);
        if (vertnext == 2)
            la = strread(tline,'%s','delimiter',' ');%strsplit(tline);
            X(end+1) = str2double(la(1));
            Y(end+1) = str2double(la(2));
            Z(end+1) = str2double(la(3));
            count = count + 1;
            if (count == vertices)
                break
            end
        end
        if (vertnext == 1)
            vertnext = 2;
            vertices = str2num(tline);
        end
        if (length(tline) < 8)
            continue
        end
        if (tline(1:8) == 'Vertices')
            vertnext = 1;
        end
    end
    fclose(fid);
    fprintf('  %u vertices\n',vertices);
    
    %remove outliers
    [X, Y, Z] = outlierRemoval([X Y Z]);
    
    %do appoximation
    if (length(X) < 4)
        continue
    end
    [ center, radii, evecs, v ] = ellipsoid_fit([X' Y' Z']);
    if (max(radii) > 1000 || min(center) < 0)
        %too big, don't count
        continue
    end
    ID(end+1) = str2num(meshfiles{i});
    CENTER(end+1,:) = center;
    RADII(end+1,:) = radii;
    EVECS(:,:,end+1) = evecs;
    assert(radii(1) == real(radii(1)));
    % draw data
    % fprintf( 'Ellipsoid center: %.3g %.3g %.3g\n', center );
    % fprintf( 'Ellipsoid radii : %.3g %.3g %.3g\n', radii );
    % fprintf( 'Ellipsoid evecs :\n' );
    % fprintf( '%.3g %.3g %.3g\n%.3g %.3g %.3g\n%.3g %.3g %.3g\n', ...
    %     evecs(1), evecs(2), evecs(3), evecs(4), evecs(5), evecs(6), evecs(7), evecs(8), evecs(9) );
    % fprintf( 'Algebraic form  :\n' );
    % fprintf( '%.3g ', v );
    % fprintf( '\n' );
    %plot3( X, Y, Z, '.r' );
end

%%
% remove outliers (by Radius)
m = mean(log(RADII(:,1))); s = std(log(RADII(:,1)));
minzs = 0;
for i=1:length(RADII)
    zs = (log(RADII(i,1))-m)/s;
    if (zs < minzs)
        minzs = zs;
    end
end
fprintf('Cut-off: radius <= %.3g\n',exp(abs(minzs)*s+m));
outlierlist = [];
for i=1:length(RADII)
    zs = (log(RADII(i,1))-m)/s;
    if (zs > abs(minzs))
        outlierlist(end+1) = i;
    end
end
EVECS(:,:,outlierlist) = [];
CENTER(outlierlist,:) = [];
RADII(outlierlist,:) = [];
ID(outlierlist) = [];

%% calculate contacts

% contactpath = ['/Users/andrewstershic/Desktop/battery/labeled_particles/NMC_',num2str(wt),'wt_',num2str(bar),'bar/mesh/ellipseContacts.txt'];
% statpath    = ['/Users/andrewstershic/Desktop/battery/particle_stats/NMC_',num2str(wt),'wt_',num2str(bar),'bar.csv'];
% outpath     = ['/Users/andrewstershic/Desktop/battery/labeled_particles/NMC_',num2str(wt),'wt_',num2str(bar),'bar/mesh/ellipseCentroidContacts.txt'];
contactpath = ['/Volumes/Stershic-HybridHD/Users/andrewstershic/Desktop/gransimulations/batteryTomography/labeled_particles/NMC_',num2str(wt),'wt_',num2str(bar),'bar/mesh/ellipseContacts.txt'];
% statpath    = ['/Volumes/Stershic-HybridHD/Users/andrewstershic/Desktop/gransimulations/batteryTomography/particle_stats/NMC_',num2str(wt),'wt_',num2str(bar),'bar.csv'];
outpath     = ['/Volumes/Stershic-HybridHD/Users/andrewstershic/Desktop/gransimulations/batteryTomography/labeled_particles/NMC_',num2str(wt),'wt_',num2str(bar),'bar/mesh/ellipseCentroidContacts.txt'];


%x y z mu p1 p2
contacts = dlmread(contactpath);
contacts = contacts(:,5:6);

% %value	volume	xmin	ymin	zmin	xmax	ymax	zmax	xCenter	yCenter	zCenter
%stats = csvread(statpath,1);
%centroid = stats(:,[1,9,10,11]);
centroid = [ID' CENTER];

n = length(contacts);
V = [];
for i = 1:n
    p1 = contacts(i,1);
    p2 = contacts(i,2);
    
    %pp1 = find(ID'==p1); pp2 = find(ID' == p2);
    %assert(size(pp1) == 1); assert(size(pp2) == 1);
    %assert(centroid(p1,1) == p1);
    if (p1 > length(centroid) || p2 > length(centroid))
        fprintf('skipping particle pair: %u %u\n',p1,p2);
        continue
    end
    
    x1 = centroid(p1,2); y1 = centroid(p1,3); z1 = centroid(p1,4);
    x2 = centroid(p2,2); y2 = centroid(p2,3); z2 = centroid(p2,4);
    v = [x2-x1;y2-y1;z2-z1];
    nv = norm(v);
    v = v/nv;
    V(end+1,:) = [v' nv p1 p2];
end


%%
% save results
fid = fopen(outpath, 'w+');
for i=1:length(V)
    fprintf(fid, '%f %f %f %f %u %u', V(i,1), V(i,2), V(i,3), V(i,4), V(i,5), V(i,6));
    fprintf(fid, '\n');
end
fclose(fid);

outstr = ['Done: NMC_',num2str(wt),'wt_',num2str(bar),'bar. ',num2str(n),' contact pairs found\n'];
fprintf(outstr);
end
end