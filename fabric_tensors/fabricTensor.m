% fabric tensor maker using MMTensor
% Andrew Stershic
function [sW,outname]=fabricTensor(path,rest,source,cols,results,series,n_particles,factor,withArea,dim,height,width,fontsize,cb,printaxis)
% function [FAV,FA4,FD4,sWA,sW]=fabricTensor(path,rest,source,cols,results,series,n_particles,factor,withArea,dim)

addpath('tensor')
addpath('fabric')
addpath('plots')


weights = [];

%0 bar
filename = [path,series,'_',num2str(0),rest];
A=load(filename);
if (length(cols) == 4)
    weightsA = A(:,cols(4));
else
    weightsA = ones(size(A,1),1);
end
sWA = sum(weightsA);
weightsA = sparse(weightsA);
in = processDimension(A(:,cols(1:3))',dim);
[NA2, NA4] = fabric_moment_tensor(in,weightsA');
[FA2,FA4] = fabric_tensor(NA2,NA4);

%300 bar
filename = [path,series,'_',num2str(300),rest];
D=load(filename);
if (length(cols) == 4)
    weights = D(:,cols(4));
else
    weights = ones(size(D,1),1);
end
weights = sparse(weights);
in = processDimension(D(:,cols(1:3))',dim);
[NB2, NB4] = fabric_moment_tensor(in,weights');
[FB2,FB4] = fabric_tensor(NB2,NB4);

%600 bar
filename = [path,series,'_',num2str(600),rest];
D=load(filename);
if (length(cols) == 4)
    weights = D(:,cols(4));
else
    weights = ones(size(D,1),1);
end
weights = sparse(weights);
in = processDimension(D(:,cols(1:3))',dim);
[NC2, NC4] = fabric_moment_tensor(in,weights');
[FC2,FC4] = fabric_tensor(NC2,NC4);

%2000 bar
filename = [path,series,'_',num2str(2000),rest];
D=load(filename);
if (length(cols) == 4)
    weights = D(:,cols(4));
else
    weights = ones(size(D,1),1);
end
sWD = sum(weights);
weights = sparse(weights);
in = processDimension(D(:,cols(1:3))',dim);
[ND2, ND4] = fabric_moment_tensor(in,weights');
[FD2,FD4] = fabric_tensor(ND2,ND4);

%work
P = 0.01;

%test fitness of 0bar FT
[A2_tet, A4_tet] = fabric_decomposition(NA2, NA4);
[p2, p4] = fabric_fitness_test(n_particles, A2_tet, A4_tet,P);
twoOrFour1 = 0;
if (p2 < P)
    twoOrFour1 = 2;
end
if (p4 < P)
    twoOrFour1 = 4;
end

%test fitness of 2000bar FT
[D2_tet, D4_tet] = fabric_decomposition(ND2, ND4);
[p2, p4] = fabric_fitness_test(n_particles, D2_tet, D4_tet,P);
twoOrFour2 = 0;
if (p2 < P)
    twoOrFour2 = 2;
end
if (p4 < P)
    twoOrFour2 = 4;
end
twoOrFour = min(twoOrFour1,twoOrFour2);

FAV = [];
FAV(1) = fractional_anisotropy(NA2);
FAV(2) = fractional_anisotropy(NB2);
FAV(3) = fractional_anisotropy(NC2);
FAV(4) = fractional_anisotropy(ND2);

label = [series,' evolution - ',source];
%for single FT examples
% h = plotDirectionalRoseDiagrams_input(NA2,NA4,FA2,FD2,FA4,FD4,label,twoOrFour1,twoOrFour2,1,dim,fontsize,cb,printaxis);
%for evolution diagrams
h = plotDirectionalRoseDiagrams_input(NA2,NA4,FA2,FD2,FA4,FD4,label,twoOrFour1,twoOrFour2,0,dim,fontsize,cb,printaxis);

fprintf('total (0 bar)= %6.3g, total (2000 bar)= %6.3g, diff = %6.3g\n',factor*sWA, factor*sWD, factor*(sWD-sWA) );
sW = [sWA sWD]*factor;

outname = [results,series,'/NMC_',series,withArea,'_',num2str(dim),'D_evolution.png'];
if (cb == 1)
    outname = [results,series,'/NMC_',series,withArea,'_',num2str(dim),'D_top_evolution.png'];
end
if (cb == 2)
    outname = [results,series,'/NMC_',series,withArea,'_',num2str(dim),'D_side_evolution.png'];
end
% r = 150; set(h, 'Position',[0 0 width height]/r, 'PaperUnits', 'inches', 'PaperPosition', [0 0 width height]/r);
r = 150; set(h, 'PaperUnits', 'inches', 'PaperPosition', [0 0 width height]/r);
saveas(h,outname,'png');
% 
% label = [series,' 0 bar - ',source];
% h = plotDirectionalRoseDiagrams_input(NA2,NA4,FA2,FA4,label,1);
% outname = [results,series,'/NMC_',series,'_0bar.png'];
% saveas(h,outname,'png');
% 
% label = [series,' 2000 bar - ',source];
% h = plotDirectionalRoseDiagrams_input(ND2,ND4,FD2,FD4,label,1);
% outname = [results,series,'/NMC_',series,'_2000bar.png'];
% saveas(h,outname,'png');
