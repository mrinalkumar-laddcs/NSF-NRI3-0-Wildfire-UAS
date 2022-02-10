clear all; close all; clc;

% load('RiverRun_Ewind.mat', 'xlat','ylong');
% load('FluxProbabilityCube.mat');
load('WildfireProbabFlux');
load('ConflictCube.mat');

transform = 1;

Tim = 50;
cutoff = 0.16;

% domain.latmin   = min(xlat);
% domain.latmax   = max(xlat);
% domain.longmin  = min(ylong);
% domain.longmax  = max(ylong);

domain.longmin  = 3838000;
domain.longmax  = 3846000;
domain.latmin   = 337200;
domain.latmax   = 345000;

if transform == 1 
    domain.xmin = domain.longmin-domain.longmin;
    domain.xmax = domain.longmax-domain.longmin;
    domain.ymin = domain.latmin-domain.latmin;
    domain.ymax = domain.latmax-domain.latmin;
    ylong = ylong - domain.longmin;
    xlat  = xlat  - domain.latmin;
end

[lnmesh, ltmesh] = meshgrid(ylong,xlat);
TempCont = FluxProbCube(:,:,Tim);
fc = find(TempCont > cutoff);

ConfSlice = ConflictCube(:,:,Tim);
[Conf,indx] = sort(ConfSlice(:),'descend');
[row,col] = ind2sub(size(ConfSlice),indx(2));

%%%plot the data
figure(1)
hold on;
surf(lnmesh, ltmesh, TempCont);
if transform == 1
    xlim([domain.xmin, domain.xmax]);
    ylim([domain.ymin, domain.ymax]);
else
    xlim([domain.longmin, domain.longmax]);
    ylim([domain.latmin, domain.latmax]);
end
daspect([1 1 1]);

% figure(2)
% hold on;
% plot3(lnmesh(fc), ltmesh(fc), TempCont(fc), 'k.', 'Markersize', 2, 'linewidth', 1);
% view(0,90);

figure(2)
hold on;
grid on;
contour(lnmesh, ltmesh, TempCont,[cutoff cutoff]);
for i = 1:10
    [row,col] = ind2sub(size(ConfSlice),indx(i));
    plot(ylong(1,col),xlat(1,row),'*');
    text(ylong(1,col),xlat(1,row),num2str(i));
end
% contour(TempCont,[cutoff cutoff]);
if transform == 1
    xlim([domain.xmin, domain.xmax]);
    ylim([domain.ymin, domain.ymax]);
else
    xlim([domain.longmin, domain.longmax]);
    ylim([domain.latmin, domain.latmax]);
end
daspect([1 1 1]);

ConMatrix = contourc(ylong, xlat, TempCont,[cutoff cutoff]);
% ConMatrix = contourc(TempCont,[cutoff cutoff]);
% ConMatrix = contourc(TempCont,[Tim Tim]);

% works for single contour level only
if ~isempty(ConMatrix)
    curr_ind = 0;
    poly_ind = 0;
    while curr_ind ~= size(ConMatrix,2)
        curr_ind = curr_ind+1;
        poly_ind = poly_ind+1;
        ConPolySize = ConMatrix(2,curr_ind);
        bdry(poly_ind).poly = [ConMatrix(1,curr_ind+(1:ConPolySize))' ConMatrix(2,curr_ind+(1:ConPolySize))'];
        curr_ind = curr_ind+ConPolySize;
    end
else
    disp('Chosen contour level does not exist');
end

if exist('bdry')
    figure(3)
    hold on
    grid on
%     contour(lnmesh, ltmesh, TempCont,[cutoff cutoff]);
    for i = 1:size(bdry,2)
        plot(bdry(i).poly(:,1),bdry(i).poly(:,2),'-');
    end
    for i = 1:10
        [row,col] = ind2sub(size(ConfSlice),indx(i));
        plot(ylong(1,col),xlat(1,row),'*');
        text(ylong(1,col),xlat(1,row),num2str(i));
    end
end

if exist('bdry')
    latlong_factor = 30;
%     latlong_factor = 1;
    tol = 0.8*latlong_factor;
    figure(3)
    hold on
    grid on
    for i = 1:size(bdry,2)
        [bdry_red(i).poly(:,1),bdry_red(i).poly(:,2)] = reducem(bdry(i).poly(:,1),bdry(i).poly(:,2),tol);
        plot(bdry_red(i).poly(:,1),bdry_red(i).poly(:,2),'-o');
    end
end

if transform == 1
    xlim([domain.xmin, domain.xmax]);
    ylim([domain.ymin, domain.ymax]);
else
    xlim([domain.longmin, domain.longmax]);
    ylim([domain.latmin, domain.latmax]);
end
daspect([1 1 1]);