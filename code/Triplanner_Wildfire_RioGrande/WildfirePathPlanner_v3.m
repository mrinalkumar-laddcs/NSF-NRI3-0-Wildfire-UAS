%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Path Planner Script
%
% For a given obstacle map file, this script calls the C++ executable 
% which uses Triplanner library to generate polyline path with a desired
% clearance
%
% Instructions:
% 1. Configure the Settings
% 2. Run this script.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc;
addpath('data_files');
addpath('functions');
addpath('functions');
addpath(['functions' filesep 'triplanner']);
addpath(['functions' filesep 'cdt']);
addpath(['functions' filesep 'trimesh']);
addpath('gpops_phased_files');
addpath(['gpops_phased_files' filesep 'functions']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-- Problem Setup: User Defined Settings --%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Approach -  'rolling': Rolling Window (time varying map), 'static': Static (fixed map)
% approach.type     = 'rolling';
approach.type     = 'static';

% Map Boundary Type - 'probab': Probabilistic Heat Flux Map, 'nominal': Nominal Boundary Map 
boundary.type     = 'probab'; 
% boundary.type     = 'nominal'; 

% Data File Type - 'flux': Probabilistic Flux Data File, 'clus': Clustered Data File
data_file.type    = 'flux';
% data_file.type    = 'clus';

% LOGIC: probab boundary aproach requires probab flux data only. nominal 
% boundary approach uses probab flux data to get nominal contour or use
% clustered data.

% Planner Method
plannerMethod.initial      = 1; % 1: Triplanner, 2: MATLAB CDT, 3: Voronoi Diagram,
plannerMethod.gpops_enable = 1; % 0: No GPOPS (initial path only), 1: use GPOPS

% Define the domain
% domain.longmin  = 3838000;
% domain.longmax  = 3846000;
% domain.latmin   = 337200;
% domain.latmax   = 345200;
domain.longmin = 337200;
domain.longmax = 341200;
domain.latmin   = 3840000;
domain.latmax   = 3847500;

%------------------------------------------%
%-------- Rolling Window approach ---------%
%------------------------------------------%
% OLD PARAMETERS
% approach.rolling.tStart = 50; % min
% approach.rolling.tFinal = 80; % min
% approach.rolling.tDelta = 5; % min
% 
% nSteps = length(approach.rolling.tStart:approach.rolling.tDelta:approach.rolling.tFinal); 
% 
% % Case 1:
% approach.rolling.startPoint = [100,100]    + [domain.longmin domain.latmin]; % (x,y)
% approach.rolling.finalPoint = [3000*ones(nSteps-1,1) 2500*ones(nSteps-1,1)] + [domain.longmin domain.latmin]; % (x,y)
% approach.rolling.clearance  = 5;
% 
% % Case 2:
% approach.rolling.startPoint = [100,100]    + [domain.longmin domain.latmin]; % (x,y)
% approach.rolling.finalPoint = [2560, 1500; 
%                                2400, 3360;
%                                2600, 3460] + [domain.longmin domain.latmin]; % (x,y)
% approach.rolling.clearance  = 5;

% NEW PARAMETERS
approach.rolling.tStart = 65; % min
approach.rolling.tFinal = 73; % min
approach.rolling.tDelta = 2; % min

nSteps = length(approach.rolling.tStart:approach.rolling.tDelta:approach.rolling.tFinal); 

approach.rolling.startPoint = [1500,500]    + [domain.longmin domain.latmin]; % (x,y)
approach.rolling.finalPoint = [1800*ones(nSteps-1,1) 1700*ones(nSteps-1,1)] + [domain.longmin domain.latmin]; % (x,y)
approach.rolling.clearance  = 5;

%------------------------------------------%
%------- Single Snapshot approach ---------%
%------------------------------------------%
% Case 1: 
% approach.static.tFire   = 85;
% approach.static.startPoint = [100,100]    + [domain.longmin domain.latmin]; % (x,y)
% approach.static.finalPoint = [4200, 2600] + [domain.longmin domain.latmin]; % (x,y)
% approach.static.clearance  = 5;

% Case 2: 
approach.static.tFire   = 70;
approach.static.startPoint = [100,100]    + [domain.longmin domain.latmin]; % (x,y)
approach.static.finalPoint = [4000, 3050] + [domain.longmin domain.latmin]; % (x,y)
approach.static.clearance  = 5;

vehicle.V      = 5; % m/s
vehicle.r_min  = 20;  % m

%------------------------------------------%
%---- Probabilistic Boundary approach -----%
%------------------------------------------%
% Used in Probabilistic Boundary, Flux File
    boundary.probab.risk.Mode         = 0;    % 0: Single Risk Value, 1: Range of Risk Values
    boundary.probab.risk.Upper        = 0.2;  % 
    boundary.probab.risk.Lower        = 0.001;% 
    boundary.probab.risk.Value        = 0.16; % Single Risk Value: 0.001 - 0.2;
%     boundary.probab.risk.Value        = 0.10; % Single Risk Value: 0.001 - 0.2;
%     boundary.probab.risk.Value        = 0.05; % Single Risk Value: 0.001 - 0.2;

%------------------------------------------%
%------- Nominal Boundary approach --------%
%------------------------------------------%
    boundary.nominal.conservatism      = 0;    % 0: Nominal, 1: conservative, 2: probabilistic
    
    % When using Flux File
    boundary.nominal.flux.nominalRisk = 0.5;
    boundary.nominal.flux.conservativeRisk = 0;
    
    % When using Cluster File
    boundary.nominal.clus.conservativeDelta = 140;
    
    % Any File, Probabilistic Approach Parameters
    boundary.nominal.unc.mu            = 0;
    boundary.nominal.unc.sigma         = 50;
    boundary.nominal.cauchy.x0         = 0;
    boundary.nominal.cauchy.gamma      = 7;
    
    boundary.nominal.risk.Mode         = 1;    % 0: Single Risk Value, 1: Range of Risk Values
    boundary.nominal.risk.Upper        = 0.2;  % 
    boundary.nominal.risk.Lower        = 0.001;% 
    boundary.nominal.risk.Value        = 0.05; % 0.001 - 0.2;

% Data Files
data_file.flux = 'WildfireProbabFlux';
data_file.clus = 'WildfireClus';

% System Files
sys.triplannerFunc = 'TPpathgen.exe';
sys.mapfile        = fullfile(pwd,'data_files','wildfireMap.txt');

% Result Filename
result_filename = 'JourArt_Wildfire';
rolling_test_file = fullfile(pwd,'results',[result_filename,'_','RollingTestData']);
rolling_conserv_test_file = fullfile(pwd,'results',[result_filename,'_','RollingTestData_conserve']);
static_test_file = fullfile(pwd,'results',[result_filename,'_','StaticTestData']);
static_conserv_test_file = fullfile(pwd,'results',[result_filename,'_','StaticTestData_conserv']);

% Other Parameters
global transform plot_transform fig_draw;
transform         = 1;    % 1: Origin Shifting, 0: No shifting (Recommended 1 for TriPlanner to work)
plot_transform    = 0;    % 1: Origin Shifting, 0: No shifting
fig_draw          = 1;    % 1: Figure while cluster extraction, 0: No Fig

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------ Verify User Defined Settings ------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
settingsFile = 'settings.mat';
save(fullfile(pwd,'data_files',settingsFile));
[approach,boundary,data_file] = verifySettings(settingsFile);
delete(fullfile(pwd,'data_files',settingsFile));
clear settingFile;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------- Begin Simulation  ------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------------------------------%
%---------- Transform the Coords ----------%
%------------------------------------------%
if transform == 1 
    domain.xmin = domain.longmin-domain.longmin;
    domain.xmax = domain.longmax-domain.longmin;
    domain.ymin = domain.latmin-domain.latmin;
    domain.ymax = domain.latmax-domain.latmin;
end

%------------------------------------------%
%---- Map Generation and Path Planning ----%
%------------------------------------------%
if approach.typeID == 1
    % Rolling Window Approach
    plan_times   = approach.rolling.tStart:approach.rolling.tDelta:approach.rolling.tFinal;
    nSteps = length(plan_times);    
    for i = 1:nSteps-1
        window.tFire = plan_times(i);
        if i == 1
            window.startPoint = approach.rolling.startPoint;
        else
            if transform == 1
                window.startPoint = interp1(stepResult(i-1).risk.t,stepResult(i-1).risk.x,approach.rolling.tDelta)+[domain.longmin domain.latmin];
            else
                window.startPoint = interp1(stepResult(i-1).risk.t,stepResult(i-1).risk.x,approach.rolling.tDelta);
            end
        end
        window.finalPoint = approach.rolling.finalPoint(i,:);
        window.clearance  = approach.rolling.clearance;
        [stepResult(i)] = staticPlanner(window,boundary,data_file,plannerMethod,domain,sys,vehicle);
    end
    save(rolling_test_file);
else
    if approach.typeID == 2
        % Static Approach
        window.tFire      = approach.static.tFire;
        window.startPoint = approach.static.startPoint;
        window.finalPoint = approach.static.finalPoint;
        window.clearance  = approach.static.clearance;
        [stepResult] = staticPlanner(window,boundary,data_file,plannerMethod,domain,sys,vehicle);
        save(static_test_file);
%         save(static_conserv_test_file);
    end
end

% return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------- Visualize ----------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all;
result_filename = 'JourArt_Wildfire';
rolling_test_file = fullfile(pwd,'results',[result_filename,'_','RollingTestData']);
rolling_conserv_test_file = fullfile(pwd,'results',[result_filename,'_','RollingTestData_conserve']);
static_test_file = fullfile(pwd,'results',[result_filename,'_','StaticTestData']);
static_conserv_test_file = fullfile(pwd,'results',[result_filename,'_','StaticTestData_conserv']);
test_data_file = rolling_test_file;
% test_data_file = rolling_conserv_test_file;
% test_data_file = static_test_file;
% test_data_file = static_conserv_test_file;
load(test_data_file);
plotPath2(approach,plannerMethod,stepResult,domain,test_data_file);
animatePath(approach,plannerMethod,stepResult,domain,test_data_file);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Polygon Resize
% switch conservatism
%     case 0
%         disp('Nominal Boundary'); disp('');
%         [status,path] = deterministicPlanner(refObs,domain,initialMethod,triplannerFunc,mapfile,startPoint,finalPoint,clearance,broken_poly);
%         plotPath(refObs,domain,startPoint,finalPoint,status,path.path,broken_poly);
%         
%     case 1
%         disp('Conservative Case'); disp('');
%         newObs = polygonResize(refObs,conservativeDelta);
%         if fig_draw == 1
%             plotObstacles(refObs,newObs,domain,conservatism,conservativeDelta);
%         end
%         [status,path] = deterministicPlanner(newObs,domain,initialMethod,triplannerFunc,mapfile,startPoint,finalPoint,clearance,broken_poly);
%         plotPath(newObs,domain,startPoint,finalPoint,status,path.path,broken_poly);
%         
%     case 2
%         disp('Probabilistic Case'); disp('');
%         % Work in Progress
%         [status,path] = probabilisticPlanner(refObs,domain,initialMethod,triplannerFunc,mapfile,startPoint,finalPoint,clearance,broken_poly,unc,risk);
% %         plotPathProb(refObs,domain,startPoint,finalPoint,status,path{4},broken_poly,unc,risk);
%         plotPathProb(refObs,domain,startPoint,finalPoint,status,path,broken_poly,unc,risk);
%         plotPathProb(refObs,domain,startPoint,finalPoint,status,path{2},broken_poly,unc,risk);
%         
%         for i = 1:size(path,2)
%             path_length(i) = sum(sqrt((path{i}(2:end,1)-path{i}(1:end-1,1)).^2+(path{i}(2:end,2)-path{i}(1:end-1,2)).^2));
%         end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------- Visualize ----------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plotPath(newtObs,domain,startPoint,finalPoint,status,path(4).path,broken_poly);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------- Local Functions ------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deterministic Planner
% function [status,path] = deterministicPlanner(conv_obs,domain,planningMethod,triplannerFunc,mapfile,startPoint,finalPoint,clearance,broken_poly)
% obs = combineBroken(conv_obs,broken_poly);
% 
% % Planner Selection
% switch planningMethod
%     case 1
%         % Generate Map File
%         genMapFile(obs,domain,mapfile);
%         [status,path,tri_funnel] = TriPlanner(triplannerFunc,mapfile,domain,startPoint,finalPoint,clearance);
%         save('triplanner_data.mat');
%         
%         clear all; close all; clc;
%         load('triplanner_data.mat');
%         run twoDoneParticle_Triplanner_Main
%         
%     case 2
%         [status,path] = TriMesh(obs,domain,startPoint,finalPoint);
%         % Work in Progress
%         % GPOPS
%         % nodes = [];
%         % edges = [];
%         % for i = 1:size(conv_obs,2)
%         %     conv_obs(i).polySize = size(conv_obs(i).polygon,1);
%         %     edges = [edges; size(nodes,1)+[(1:(conv_obs(i).polySize-1))' (2:conv_obs(i).polySize)'; conv_obs(i).polySize 1]];
%         %     nodes = [nodes; conv_obs(i).polygon];
%         %     polySize(i,1) = conv_obs(i).polySize;
%         % end
%         % run twoDoneParticleObstacleMain
%         
%     case 3
%         % Work In Progress
%         [status,path] = MW_CDT(obs,domain,startPoint,finalPoint);
%         % Work in Progress
%         % GPOPS
%         
%     otherwise
%         disp('Incorrect choice of Planning method. Choose from - 1: Triplanner, 2: Voronoi Diagram, 3: MATLAB CDT');
%         return
% end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Probabilistic Planner
% function [status,path] = probabilisticPlanner(conv_obs,domain,planningMethod,triplannerFunc,mapfile,startPoint,finalPoint,clearance,broken_poly,unc,risk)
% obs = combineBroken(conv_obs,broken_poly);
% 
% if risk.Mode == 1
%     risk_vec = linspace(risk.Lower,risk.Upper,20)';
%     delta = norminv(1-risk_vec,unc.mu,unc.sigma);
%     for i = 1:size(delta,1)
%         newObs = polygonResize(obs,delta(i,1));
%         [status,path{i}] = deterministicPlanner(newObs,domain,planningMethod,triplannerFunc,mapfile,startPoint,finalPoint,clearance,0);
%     end
% else
%     delta = norminv(risk.Value,unc.mu,unc.sigma);
%     newObs = polygonResize(obs,delta);
%     [status,path] = deterministicPlanner(newObs,domain,planningMethod,triplannerFunc,mapfile,startPoint,finalPoint,clearance,0);
% end
% end