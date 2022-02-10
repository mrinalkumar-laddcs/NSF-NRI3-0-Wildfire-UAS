% function fluxProbabPlanner()
function [stepResult] = deterministicPlanner(obs,plannerMethod,domain,sys,startPoint,finalPoint,clearance,vehicle)
% obs = combineBroken(conv_obs,broken_poly);
global transform plot_transform

if transform == 1
    bndBox = [domain.xmin domain.ymin domain.xmax domain.ymax];
    startPoint = startPoint - [domain.longmin domain.latmin];
    finalPoint = finalPoint - [domain.longmin domain.latmin];
else
    bndBox = [domain.longmin domain.latmin domain.longmax domain.latmax];
end
        
% Planner Selection
switch plannerMethod.initial
    case 1
        % Generate Map File
        genMapFile(obs,bndBox,sys.mapfile);
        [status,path,tri_funnel] = TriPlanner(sys.triplannerFunc,sys.mapfile,domain,startPoint,finalPoint,clearance);
%         save('triplanner_data.mat');
%         
%         clear all; close all; clc;
%         load('triplanner_data.mat');
        
        % GPOPS
        if plannerMethod.gpops_enable == 1
            run twoDoneParticle_Triplanner_Main
            path = xStar;
            stepResult.risk.t = [0; cumsum(sqrt((path(2:end,1)-path(1:end-1,1)).^2+(path(2:end,2)-path(1:end-1,2)).^2))/vehicle.V/60];
            stepResult.risk.x = path;
        else
            path = unique(path,'stable','rows');
            stepResult.risk.t = [0; cumsum(sqrt((path(2:end,1)-path(1:end-1,1)).^2+(path(2:end,2)-path(1:end-1,2)).^2))/vehicle.V/60];
            stepResult.risk.x = path;
        end
        
    case 2
        % Work In Progress
        [status,path] = MW_CDT(obs,bndBox,startPoint,finalPoint);
        % Work in Progress
        % GPOPS
        
    case 3
        % Work in Progress
        
        %[status,path] = TriMesh(obs,domain,startPoint,finalPoint);
        
        % GPOPS
        % nodes = [];
        % edges = [];
        % for i = 1:size(conv_obs,2)
        %     conv_obs(i).polySize = size(conv_obs(i).polygon,1);
        %     edges = [edges; size(nodes,1)+[(1:(conv_obs(i).polySize-1))' (2:conv_obs(i).polySize)'; conv_obs(i).polySize 1]];
        %     nodes = [nodes; conv_obs(i).polygon];
        %     polySize(i,1) = conv_obs(i).polySize;
        % end
        % run twoDoneParticleObstacleMain
        
    otherwise
        disp('Incorrect choice of Initial Planning method. Choose from - 1: Triplanner, 2: MATLAB CDT, 3: Voronoi Diagram');
        return
end
end