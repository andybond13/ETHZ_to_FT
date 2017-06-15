%%
%ellipsoid fit script
% .mesh files -> ellipsoid approximations (ellipses.approx)
clear all
close all

% target directory
% path = '/Users/andrewstershic/Desktop/battery/labeled_particles/NMC_90wt_0bar/mesh/';
path = '/Volumes/stershic-primary/andrewstershic/Desktop/gransimulations/batteryTomography/labeled_particles/NMC_96wt_2000bar/mesh/';
header = 'Island_';
stats = '/Volumes/stershic-primary/andrewstershic/Desktop/gransimulations/batteryTomography/particle_stats/NMC_96wt_2000bar.csv';
files = dir(path);
meshfiles = {};
for i=1:length(files)
    name = files(i).name;
    if (length(name) < 5)
        continue
    end
    namestring = name(end-4:end);
    nameheader = name(1:7);
    if (prod(namestring == '.mesh')*prod(nameheader == header) == 1)
        nameid = name(8:end-5);
        meshfiles{end+1} = nameid;
    else
        fprintf('did not include %s\n',name);
    end
end

statsdata = csvread(stats,1,0);
volVXs = statsdata(:,2);
sXc = statsdata(:,9);
sYc = statsdata(:,10);
sZc = statsdata(:,11);

ID = [];
VOL = [];
VOLVX = [];
CENTER = zeros(0,3);
RADII = zeros(0,3);
V = zeros(0,9);
EVECS = zeros(3,3,0);
n = length(meshfiles);
assert(n <= length(volVXs));
for i = 1:n
    % read file, get points
    file = [path header meshfiles{i} '.mesh'];
    fprintf('%s.mesh : %u of %u\n',meshfiles{i},i, n)
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
            la = strsplit(tline);
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
    
    %remove outliers (mesh points)
    [X, Y, Z] = outlierRemoval([X Y Z]);
    
    %do appoximation
    if (length(X) < 4)
        continue
    end
    
    id = str2num(meshfiles{i});
    
    [ center, radii, evecs, v, vol] = ellipsoid_fit([X' Y' Z'],volVXs(id),sXc(id),sYc(id),sZc(id));
    if (max(radii) > 1000 || min(center) < 0)
        %too big, don't count
        continue
    end
    ID(end+1) = id;
    VOL(end+1,:) = vol;
    VOLVX(end+1,:) = volVXs(id);
    CENTER(end+1,:) = center;
    RADII(end+1,:) = radii;
    V(end+1,:) = v';
    EVECS(:,:,end+1) = evecs;
    assert(radii(1) == real(radii(1)));
    
    % value	xCenter	yCenter	zCenter	Radius 1	Radius 2	Radius 3	Evec1_x	Evec1_y	Evec1_z	Evec2_x	Evec2_y	Evec2_z	Evec3_x	Evec3_y	Evec3_z	a	b	c	d	e	f	g	h	i
    
    %     % draw data
    %     fprintf( 'Ellipsoid center: %.3g %.3g %.3g\n', center );
    %     fprintf( 'Ellipsoid radii : %.3g %.3g %.3g\n', radii );
    %     fprintf( 'Ellipsoid evecs :\n' );
    %     fprintf( '%.3g %.3g %.3g\n%.3g %.3g %.3g\n%.3g %.3g %.3g\n', ...
    %         evecs(1), evecs(2), evecs(3), evecs(4), evecs(5), evecs(6), evecs(7), evecs(8), evecs(9) );
    %     fprintf( 'Algebraic form  :\n' );
    %     fprintf( '%.3g ', v );
    %     fprintf( '\n' );
    %     plot3( X, Y, Z, '.r' );
    %     hold on;
    % this isn't the best way to draw an ellipsoid since the rotation is wrong
    %     ellipsoid(center(1),center(2),center(3),radii(1),radii(2),radii(3),100);
    %     alpha(0.5)
    %     pause
end




% %%
% % remove outliers (by Radius)
% m = mean(log(RADII(:,1))); s = std(log(RADII(:,1)));
% minzs = 0;
% for i=1:length(RADII)
%     zs = (log(RADII(i,1))-m)/s;
%     if (zs < minzs)
%         minzs = zs;
%     end
% end
% fprintf('Cut-off: radius <= %.3g\n',exp(abs(minzs)*s+m));
% outlierlist = [];
% for i=1:length(RADII)
%     zs = (log(RADII(i,1))-m)/s;
%     if (zs > abs(minzs))
%         outlierlist(end+1) = i;
%     end
% end
% EVECS(:,:,outlierlist) = [];
% CENTER(outlierlist,:) = [];
% RADII(outlierlist,:) = [];
% ID(outlierlist) = [];
% V(outlierlist,:) = [];
%%
n = length(ID);
fileOut = [path 'ellipsoidInfo.out'];
fid2 = fopen(fileOut,'w');

fprintf(fid2,'#value	xCenter	yCenter	zCenter	Radius 1	Radius 2	Radius 3	Evec1_x	Evec1_y	Evec1_z	Evec2_x	Evec2_y	Evec2_z	Evec3_x	Evec3_y	Evec3_z	a	b	c	d	e	f	g	h	i\n');
for i = 1:n
    fprintf(fid2,'%u %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3e %6.3e %6.3e %6.3e %6.3e %6.3e %6.3e %6.3e %6.3e %6.3e %6.3e\n',...
        ID(i),CENTER(i,1),CENTER(i,2),CENTER(i,3),RADII(i,1),RADII(i,2),RADII(i,3), EVECS(1,1,i), EVECS(2,1,i), EVECS(3,1,i), EVECS(1,2,i), EVECS(2,2,i), EVECS(3,2,i), EVECS(1,3,i), EVECS(2,3,i), EVECS(3,3,i), V(i,1), V(i,2),V(i,3),V(i,4),V(i,5),V(i,6),V(i,7),V(i,8), V(i,9), VOL(i), VOLVX(i));
end
fclose(fid2);

%%
% contact calculations
NC = zeros(0,3);
MU = zeros(0,1);
PAIR = zeros(0,2);
n = length(ID);
figure
hold on
fprintf('computing comparisons:   \n');
count = 0;
for i = 1:n-1
    for j=i+1:n
        count = count + 1;
        [mu nc] = ellipsoidContact(CENTER(i,:),RADII(i,:),EVECS(:,:,i),...
            CENTER(j,:),RADII(j,:),EVECS(:,:,j),1);
        if (mu > 0 && mu < 1) %write only if mu < 1 : might expand this in the future to mu < 1.05 or such
            NC(end+1,:) = nc;
            MU(end+1,1) = mu;
            PAIR(end+1,:) = [ID(i) ID(j)];
            %             disp(mu)
        end
        pct = count/(n*(n-1)/2)*100;
        if (mod(count,1000) == 0)
            fprintf('%.1f %%\n',pct);
        end
    end
end
fprintf('\n%u contacts found!\n\n',length(NC));
%%
% save results
outname = [path 'ellipseContacts.txt'];
fid = fopen(outname, 'w+');
for i=1:size(NC, 1)
    fprintf(fid, '%f %f %f %f %u %u', NC(i,1), NC(i,2), NC(i,3), MU(i), PAIR(i,1), PAIR(i,2));
    fprintf(fid, '\n');
end
fclose(fid);