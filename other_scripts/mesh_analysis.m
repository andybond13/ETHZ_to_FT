%%
%mesh analysis script
% .mesh files -> surface area, volume, sphericity
clear all
close all

% target directory
path = '/Users/andrewstershic/Desktop/battery/labeled_particles/NMC_96wt_2000bar/mesh/';
%path = '/Volumes/Stershic-HybridHD/Users/andrewstershic/Desktop/gransimulations/batteryTomography/labeled_particles/NMC_90wt_0bar/mesh/';
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
SPH = [];
VOL = [];
SA = [];
skip = 0;

n = length(meshfiles);
for i = 1:n
    % read file, get points
    file = [path header meshfiles{i} '.mesh'];
    fprintf('%s.mesh : %u of %u\n',meshfiles{i},i, length(meshfiles))
    fid = fopen(file);
    tline = fgetl(fid);
    vertices = 0; triangles = 0;
    vertnext = 0;
    X = []; Y = []; Z = []; TRIANGLE = zeros(0,3);
    count = 0;
    while ischar(tline)
        %         disp(tline)
        tline = fgetl(fid);
        if (vertnext == 4)
            la = strsplit(tline);
            TRIANGLE(end+1,:) = [str2double(la(1)) str2double(la(2)) str2double(la(3))];
            count = count + 1;
            if (count == triangles)
                break
            end
        end
        if (vertnext == 2)
            la = strsplit(tline);
            X(end+1) = str2double(la(1));
            Y(end+1) = str2double(la(2));
            Z(end+1) = str2double(la(3));
            count = count + 1;
            if (count == vertices)
                vertnext = 0;
                count = 0;
            end
        end
        if (vertnext == 3)
            vertnext = 4;
            triangles = str2num(tline);
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
        if (length(tline) < 9)
            continue
        end
        if (tline(1:9) == 'Triangles')
            vertnext = 3;
        end
    end
    fclose(fid);
    fprintf('  %u vertices, %u triangles\n',vertices, triangles);
    
    if (vertices * triangles == 0)
        continue
    end
    
    %figure
    %trimesh(TRIANGLE,X,Y,Z);
    
    % calculate quantities of interest
    
    %volume & surface area
    vol = 0;
    sa = 0;
    for j = 1:size(TRIANGLE,1)
        p1 = [X(TRIANGLE(j,1)) Y(TRIANGLE(j,1)) Z(TRIANGLE(j,1))];
        p2 = [X(TRIANGLE(j,2)) Y(TRIANGLE(j,2)) Z(TRIANGLE(j,2))];
        p3 = [X(TRIANGLE(j,3)) Y(TRIANGLE(j,3)) Z(TRIANGLE(j,3))];
        v1 = p2 - p1;
        v2 = p3 - p1;
        vol = vol + 1.0/6.0 * dot(p1,cross(p2,p3));
        sa = sa + 0.5 * norm(cross(v1,v2));
    end
    
    %sphericity
    sph = pi^(1/3) * (6*vol)^(2/3) / sa;
    if (sph > 1)
        skip = skip + 1;
        continue;
    end
    assert(sph <= 1);
    
    ID(end+1) = str2num(meshfiles{i});
    VOL(end+1) = vol;
    SA(end+1) = sa;
    SPH(end+1) = sph;
end

%%
% save results
outname = [path 'mesh_SPH_VOL.txt'];
fid = fopen(outname, 'w+');
for i=1:size(ID, 2)
    fprintf(fid, '%u %f %f %f\n', ID(i), SA(i), SPH(i), VOL(i));
%     fprintf(fid, '\n');
end
fclose(fid);
fprintf('skipped %u particles\n', skip);