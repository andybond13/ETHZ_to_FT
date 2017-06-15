function h = plotDirectionalRoseDiagram_input(N2,N4,FA2,FD2,FA4,FD4,label,twoOrFour1,twoOrFour2,mesh,dim,fontsize,cb,printaxis)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (C) 2011, Maarten Moesen                                      %
% All rights reserved.                                                    %
%                                                                         %
% Author(s): Maarten Moesen                                               %
% E-mail: moesen.maarten@gmail.com                                        %
%                                                                         %
% This file is part of MMTensor.                                          %                                                                        %
%                                                                         %
% Redistribution and use in source and binary forms, with or without      %
% modification, are permitted provided that the following conditions are  %
% met:                                                                    %
%    * Redistributions of source code must retain the above copyright     %
%      notice, this list of conditions and the following disclaimer.      %
%    * Redistributions in binary form must reproduce the above copyright  %
%      notice, this list of conditions and the following disclaimer in    %
%      the documentation and/or other materials provided with the         %
%      distribution.                                                      %
%    * Neither the name of the Katholieke Universiteit Leuven nor the     %
%      names of its contributors may be used to endorse or promote        %
%      products derived from this software without specific prior written %
%      permission.                                                        %
%                                                                         %
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS     %
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT       %
% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A %
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL KATHOLIEKE         %
% UNIVERSITEIT LEUVEN BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,     %
% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES(INCLUDING, BUT NOT LIMITED %
% TO, PROCUREMENT OF SUBSTITUTE GOODS ORSERVICES; LOSS OF USE, DATA, OR   %
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  %
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING    %
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS      %
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[N2, N4] = fabric_moment_tensor(D)
%[D2,D4] = fabric_decomposition(N2, N4)
%[F2,F4] = fabric_tensor(N2,N4)
%[p2, p4] = fabric_fitness_test(nb_edges,D2,D4)

%% Plot the representation surface of the fabric tensor
[x,y,z] = sphere(80);
S = size(x);

x = reshape(x, 1, numel(x));
y = reshape(y, 1, numel(y));
z = reshape(z, 1, numel(z));

N = makeS2FromVector([x;y;z]);

%this controls whether you're plotting the fabric tensor F of 0 bar or 2000 bar
F2 = FA2; F4 = FA4;
% F2 = FD2; F4 = FD4;

sN2 = N2'*N;
sF2 = F2'*N;

sN4 = sN2;
sF4 = sF2;

for i = 1:length(sN4)
    sN4(i) = N(:,i)'*N4*N(:,i);
    sF4(i) = N(:,i)'*F4*N(:,i);
end

%default of order 0
sF_a = 1 * ones(size(sF2)); %not /(4*pi) !
sF_d = 1 * ones(size(sF2)); %not /(4*pi) !
if (twoOrFour1 == 2)
    sF_a = FA2'*N;
end
if (twoOrFour1 == 4)
    sF_a = sF2;
    for i = 1:length(sN4)
        sF_a(i) = N(:,i)'*FA4*N(:,i);
    end
end
if (twoOrFour2 == 2)
    sF_d = FD2'*N;
end
if (twoOrFour2 == 4)
    sF_d = sF2;
    for i = 1:length(sN4)
        sF_d(i) = N(:,i)'*FD4*N(:,i);
    end
end
sF = sF_d - sF_a;

x = reshape(x, S);
y = reshape(y, S);
z = reshape(z, S);
sN2 = reshape(sN2, S);
sF2 = reshape(sF2, S);
sN4 = reshape(sN4, S);
sF4 = reshape(sF4, S);
sF = reshape(sF, S);


%% Plot the representation surface of N2
if (mesh == 1)
    h = figure;
    surf(sN2.*x,sN2.*y,sN2.*z, sN2, 'FaceColor','white','EdgeColor','blue');%,'EdgeColor','none');%surf(X,Y,Z,'FaceColor','gray','EdgeColor','none')
    %     colormap gray;
    axis equal
    axis vis3d
    xlabel('x1');
    ylabel('x2');
    zlabel('x3');
    title('Moment tensor N2')
    set(gca,'Color','w');
    set(gcf,'Color','w');
    grid off
    ca = caxis;
    ca = [min(0,ca(1)),ca(2)];
    caxis(ca);
    view(60,15);
    if (dim == 2)
        xlabel('');
        ylabel('r');
        zlabel('z');
        view(90,0);
    end
end
%% Plot the representation surface of N4
if (mesh == 1)
    h = figure;
    surf(sN4.*x,sN4.*y,sN4.*z, sN4, 'FaceColor','white','EdgeColor','red');%,'EdgeColor','none');%surf(X,Y,Z,'FaceColor','gray','EdgeColor','none')
    %     colormap gray;
    axis equal
    axis vis3d
    xlabel('x1');
    ylabel('x2');
    zlabel('x3');
    title('Moment tensor N4')
    set(gca,'Color','w');
    set(gcf,'Color','w');
    grid off
    ca = caxis;
    ca = [min(0,ca(1)),ca(2)];
    caxis(ca);
    view(60,15);
    if (dim == 2)
        xlabel('');
        ylabel('r');
        zlabel('z');
        view(90,0);
    end
end
%% Plot the representation surface of N2 and N4
if (mesh == 1)
    h = figure;
    hold on
    surf(sN2.*x,sN2.*y,sN2.*z, sN2, 'FaceColor','white','EdgeColor','blue');%,'EdgeColor','none');%surf(X,Y,Z,'FaceColor','gray','EdgeColor','none')
    surf(sN4.*x,sN4.*y,sN4.*z, sN4, 'FaceColor','white','EdgeColor','red');%,'EdgeColor','none');%surf(X,Y,Z,'FaceColor','gray','EdgeColor','none')
    set(gca,'Color','w');
    set(gcf,'Color','w');
    view(60,15);
    title('Moment tensors N2(blue) and N4(red)')
    xlabel('x1');
    ylabel('x2');
    zlabel('x3');
    ca = caxis;
    ca = [min(0,ca(1)),ca(2)];
    caxis(ca);
    if (dim == 2)
        xlabel('');
        ylabel('r');
        zlabel('z');
        view(90,0);
    end
end
%% Plot the representation surface of F2
if (mesh == 1)
    h = figure;
    surf(sF2.*x,sF2.*y,sF2.*z, sF2, 'FaceColor','white','EdgeColor','blue');%,'EdgeColor','none');%surf(X,Y,Z,'FaceColor','gray','EdgeColor','none')
    %     colormap gray;
    axis equal
    axis vis3d
    xlabel('x1');
    ylabel('x2');
    zlabel('x3');
    title('Fabric tensor F2')
    set(gca,'Color','w');
    set(gcf,'Color','w');
    grid off
    ca = caxis;
    ca = [min(0,ca(1)),ca(2)];
    caxis(ca);
    view(60,15);
    if (dim == 2)
        xlabel('');
        ylabel('r');
        zlabel('z');
        view(90,0);
    end
end
%% Plot the representation surface of F4
if (mesh == 1)
    h = figure;
    surf(sF4.*x,sF4.*y,sF4.*z, sF4, 'FaceColor','white','EdgeColor','red');%,'EdgeColor','none');%surf(X,Y,Z,'FaceColor','gray','EdgeColor','none')
    %     colormap gray;
    axis equal
    axis vis3d
    xlabel('x1');
    ylabel('x2');
    zlabel('x3');
    title('Fabric tensor F4')
    set(gca,'Color','w');
    set(gcf,'Color','w');
    grid off
    ca = caxis;
    ca = [min(0,ca(1)),ca(2)];
    caxis(ca);
    view(60,15);
    if (dim == 2)
        xlabel('');
        ylabel('r');
        zlabel('z');
        view(90,0);
    end
end
%% Plot the representation surface of F2 and F4
h = figure;
hold on
if (mesh == 1)
    surf(sF2.*x,sF2.*y,sF2.*z, sF2, 'FaceColor','white','EdgeColor','blue');%,'EdgeColor','none');%surf(X,Y,Z,'FaceColor','gray','EdgeColor','none')
    surf(sF4.*x,sF4.*y,sF4.*z, sF4, 'FaceColor','white','EdgeColor','red');%,'EdgeColor','none');%surf(X,Y,Z,'FaceColor','gray','EdgeColor','none')
    set(gca,'Color','w');
    set(gcf,'Color','w');
    view(60,15);
    title('Fabric tensors F2(blue) and F4(red)')
    xlabel('x1');
    ylabel('x2');
    zlabel('x3');
    ca = caxis;
    ca = [min(0,ca(1)),ca(2)];
    caxis(ca);
    if (dim == 2)
        xlabel('');
        ylabel('r');
        zlabel('z');
        view(90,0);
    end
else
    surf(sF.*x,sF.*y,sF.*z, sF,'EdgeColor','none');%surf(X,Y,Z,'FaceColor','gray','EdgeColor','none')
    alpha(1.0);

    view(60,15);
    
    if (cb == 1) %top view
        view(0,90);
    end
    if (cb == 2) %side view
        view(0,0);
    end

%     axis([-0.8 0.8 -0.8 0.8 -1.2 1.2])
    
    
    %     ca = caxis
    %     ca = [min(0,ca(1)),ca(2)]
     axis equal
     colormap jet
%    axis off
    
    ca = [-1.5 1.5]; %5/5/2015
    caxis(ca);%5/5/2015
    set(gca,'color','none')
    set(gca,'units','centimeters')
    
    %NOTE!!! - I'm actually plotting F, not f: f = F/(4*pi); This is why F0
    %is 1 and not 1/(4*pi)
    if (cb == 0)
        if (printaxis == 1)
            axis([-0.8 0.8 -0.8 0.8 -1.2 1.2])%5/5/2015
            set(gca,'XTick',[-0.6:0.3:0.6],'YTick',[-0.6:0.3:0.6],'ZTick',[-0.6:0.3:0.6],'FontSize',fontsize)           
        else
            axis([-0.8 0.8 -0.8 0.8 -1.2 1.2],'off')%5/5/2015
        end
    elseif (cb == 1)
        set(gca,'FontSize',fontsize)
        xlabel('X','FontSize',fontsize)
        ylabel('Y','FontSize',fontsize)
    elseif (cb == 2)
        set(gca,'FontSize',fontsize)
        xlabel('X','FontSize',fontsize)
        zlabel('Z','FontSize',fontsize)
    end
    set(gca,'LooseInset',get(gca,'TightInset'))
    
    
%     if (cb == 1)
% %         ax=gca;
% %         pos=get(gca,'pos')
% %         set(gca,'pos',[pos(1) pos(2) pos(3) pos(4)*0.95]);
% %         pos=get(gca,'pos');
%         c=colorbar('location','manual','FontSize',fontsize,'Position',[0.0 0 0.1 0.5]); %left bottom width height
%         %set(hc,'xaxisloc','top');
%     end
    
    titleline = ['\Delta f^{(',num2str(twoOrFour1),',',num2str(twoOrFour2),')}'];
%     titleline = ['\Delta F^{(',num2str(twoOrFour),')}'];
%     titleline = ['Fabric tensor F',num2str(twoOrFour),' : ',label];
    if (cb == 0)
        handle=title(titleline,'FontSize',fontsize);
        v=axis;
        set(handle,'Position',[v(2)*0.6 v(4)*0.6 v(6)*0.7]);
    end
    
    if (dim == 2)
        xlabel('');
        ylabel('r');
        zlabel('z');
        view(90,0);
        ca = [-2.5 2.5]; %5/5/2015
        axis([-2 2 -2.5 2.5 -2.5 2.5])%5/5/2015
        caxis(ca);%5/5/2015
        set(handle,'Position',[0 2 2]);
    end
end

%colormap gray;



end

