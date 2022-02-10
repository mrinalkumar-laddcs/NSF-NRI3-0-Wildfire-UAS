% Author: Rachit Aggarwal
% Last Update Date: May 4, 2020

close all; clear all; clc;

addpath('GuessPath');
addpath(['GuessPath' filesep 'PathPlanning']);
addpath('data');

%-------------------------------------------------------------------------%
% Setup Problem Parameters
%-------------------------------------------------------------------------%
% Simulation Features
returnHomeEn = 1;     % Enable Return Home Feature by constraining battery
restoreBatt  = 1;     % Enable Restore battery by recharging upon return
ProblemType  = 'Taos';% 'Toy' or 'Taos'
% ProblemType  = 'Toy';% 'Toy' or 'Taos'
AgentStart = 'Home';  % 'Home' or 'Random'
% AgentStart  = 'Random';% 'Home' or 'Random'

if strcmp(ProblemType,'Taos')==1
    % Load in all of the necessary data
    load('FireRadiationData.mat','UTM_east');
    load('FireRadiationData.mat','UTM_north');
    load('FireRadiationData.mat','ConflictCell');
    %---------------------------------------------------------------------%
    load('FireRadiationData.mat','DroneFluxCube_hard');
    %---------------------------------------------------------------------%

    env.dom.xMin = 0;  env.dom.xMax = max(UTM_east) - min(UTM_east);   % Domain
    env.dom.yMin = 0;  env.dom.yMax = max(UTM_north)-min(UTM_north);   % Domain
elseif strcmp(ProblemType,'Toy')==1
    env.dom.xMin = 0;  env.dom.xMax = 2500;   % Domain
    env.dom.yMin = 0;  env.dom.yMax = 2500;   % Domain
end
roi.xMin = 200; roi.xMax = env.dom.xMax;   % Region of Interest
roi.yMin = 200; roi.yMax = env.dom.yMax;   % Region of Interest

% Problem Parameters
home.loc  = [100,100];% Home Location Center
home.r    = 70;     % radial distance of agents from Home Location Center
AgentSpeed  = 12;   % Agent speed (unit: m/s)
AgentEnergyMax = 1000;  % Max distance an agent can travel
AgentEnergyRes = 150;  % Reserve Energy of the Agent
AgentHoverPower     = 0.6;    % Hover Power Consumption (units: kW)
AgentMotionPowerFac = 0.5/15; % Additional Power Factor (func of speed) when in motion
nAgents   = 4;      % Number of Agents

nConf_min = 4;      % Min number of Conflict Points
nConf_max = 5;      % Min number of Conflict Points

deltaTdyna = 0.4;   % Time Step Size for Dynamics (unit: minutes)
deltaTconf = 4;     % Time Step Size for Conf update (unit: minutes)
T_start    = 30;    % Simulation Start Time
T_end      = 80;    % Simulation End Time

alpha      = 0.5;   % 0 <= alpha <= 1

% Auxilary Parameters
txtOffset = 25;      % Offset for showing agent label text

%-------------------------------------------------------------------------%
% Problem Setup
%-------------------------------------------------------------------------%

%--------- Initialize Agents ---------%
% Setup Agent IDs
agentIDs = (1:nAgents)';

% Setup Agent Home Locations
if strcmp(AgentStart,'Home')
    homeAgentLoc = [(home.loc(1,1) + home.r*cos(2*pi*(1:nAgents)'/nAgents)), (home.loc(1,2) + home.r*sin(2*pi*(1:nAgents)'/nAgents))];
else
    homeAgentLoc = [env.dom.xMin+(env.dom.xMax-env.dom.xMin)*rand(nAgents,1), env.dom.yMin+(env.dom.yMax-env.dom.yMin)*rand(nAgents,1)];
end

% Assign Agent IDs
agent = Agent(agentIDs);     

% Assign Agent Start Locations
agent.SetHome(homeAgentLoc); 

% Assign Agent Speed
agent.SetSpeed(AgentSpeed*ones(nAgents,1));

% Assign Agent Energy Parameters
agent.SetEnergyParameters(AgentEnergyMax*ones(nAgents,1),AgentEnergyRes*ones(nAgents,1),...
    AgentHoverPower*ones(nAgents,1),AgentMotionPowerFac*ones(nAgents,1));

% Reset Agents
agent.Reset();

%-------------------------------------------------------------------------%
% NEW STUFF BELOW

% Get the mean and variance of the heat flux at this time
[DroneFluxMean, DroneFluxVar] =  DroneFluxStats(DroneFluxCube_hard);

% Choose the time in minutes (between 30 minutes and 120 minutes)
T = 60; % min

% Get Heat Flux Data
env.heatflux = GetHeatFluxData(DroneFluxMean,DroneFluxVar,env.dom,T);
env.heatflux.thresh = 7;
env.heatflux.hazardCell = GetHazardRegions(env,T);

timevec = 30:10:120;
[~, time_index] = min(abs(timevec - T));

UTM_east  = linspace(env.dom.xMin,env.dom.xMax,50);
UTM_north = linspace(env.dom.yMin,env.dom.yMax,50);
% [EAST, NORTH] = meshgrid(UTM_east, UTM_north);
% heatFluxData.X = EAST;
% heatFluxData.Y = NORTH;
% heatFluxData.hf = DroneFluxMean(:,:,time_index)';

% figure;
% hold on;
% grid on;
% box on;
% xlabel('UTM Easting [m]');
% ylabel('UTM Northing [m]');
% axis([min(UTM_east) max(UTM_east) min(UTM_north) max(UTM_north)]);
% colormap(flipud(autumn));
% p2 = pcolor(EAST, NORTH, DroneFluxMean(:,:,time_index)');
% set(p2, 'EdgeColor','none');
% colorbar;
% hbar_2 = colorbar;
% ylabel(hbar_2, 'Mean Heat Flux [kWm^{-2}]','FontWeight','bold');
% title(['Mean Heat Flux at Time: ',num2str(T), ' min.']);
% set(gca,'FontWeight','bold')
% hold off

%%% Gues Path Test:
nodes    = [];
edges    = [];
polySize = [];
sXY = [200, 200];
tXY = [1730, 2040];
sXY = [357, 663];
tXY = [1888,1888];
% plannerType = 'naive';
% [~,guessGen,dist] = GuessPathGrid(nodes,edges,polySize,agent(1),env.dom,sXY,tXY,env.heatflux,plannerType);

% plannerType = 'naive2';
% [~,guessGen4,dist4] = GuessPathGrid(nodes,edges,polySize,agent(1),env.dom,sXY,tXY,env.heatflux,plannerType);

% plannerType = 'hf-threshold';
% [~,guessGen2,dist2] = GuessPathGrid(nodes,edges,polySize,agent(1),env.dom,sXY,tXY,env.heatflux,plannerType);

% plannerType = 'hf-threshold2';
% [~,guessGen5,dist5] = GuessPathGrid(nodes,edges,polySize,agent(1),env.dom,sXY,tXY,env.heatflux,plannerType);
% plannerType = 'hf-threshold3';
% [~,guessGen8,dist8] = GuessPathGrid(nodes,edges,polySize,agent(1),env.dom,sXY,tXY,env.heatflux,plannerType);
% plannerType = 'hf-threshold4';
% [~,guessGen10,dist10] = GuessPathGrid(nodes,edges,polySize,agent(1),env.dom,sXY,tXY,env.heatflux,plannerType);

% plannerType = 'temp-const';
% [~,guessGen3,dist3] = GuessPathGrid(nodes,edges,polySize,agent(1),env.dom,sXY,tXY,env.heatflux,plannerType);
plannerType = 'temp-const2';
[~,guessGen6,dist6] = GuessPathGrid(nodes,edges,polySize,agent(1),env.dom,sXY,tXY,env.heatflux,plannerType);
plannerType = 'temp-const3';
[~,guessGen9,dist9] = GuessPathGrid(nodes,edges,polySize,agent(1),env.dom,sXY,tXY,env.heatflux,plannerType);


figNum = figure('position', [50, 50, 900, 800]);
cmap = colormap('hot');
new_cmap = flipud(cmap(20:end,:));
hold on;
grid on;
box on;
xlabel('UTM Easting [m]');
ylabel('UTM Northing [m]');
axis([min(UTM_east) max(UTM_east) min(UTM_north) max(UTM_north)]);
colormap(new_cmap);
% p2 = pcolor(EAST, NORTH, DroneFluxMean(:,:,time_index)');
p2 = pcolor(env.heatflux.X, env.heatflux.Y, env.heatflux.hfmean);
set(p2, 'EdgeColor','none');
colorbar;
hbar_2 = colorbar;

for i = 1:size(env.heatflux.hazardCell,1)
    plot(env.heatflux.hazardCell{i,3},'FaceColor',[0.9290 0.6940 0.1250],'FaceAlpha',0.1,...
        'EdgeColor','r','LineWidth',1.5);
end
% p1= plot(guessGen.x,guessGen.y,':','Linewidth',2);

% p4 = plot(guessGen4.x,guessGen4.y,'--','Linewidth',2);
% p2 = plot(guessGen2.x,guessGen2.y,'-','Linewidth',2);

% p5 = plot(guessGen5.x,guessGen5.y,'--','Linewidth',2);
% p8 = plot(guessGen8.x,guessGen8.y,'--','Linewidth',2);
% p10 = plot(guessGen10.x,guessGen10.y,':','Linewidth',2);
% p3 = plot(guessGen3.x,guessGen3.y,'-.','Linewidth',2);
p6 = plot(guessGen6.x,guessGen6.y,'--','Linewidth',2);
p9 = plot(guessGen9.x,guessGen9.y,':','Linewidth',2);
% s1 = plot(sXY(1,1),sXY(1,2),'bo');
s1 = scatter(sXY(1,1),sXY(1,2),'MarkerFaceColor','b','MarkerEdgeColor','k');
t1 = scatter(tXY(1,1),tXY(1,2),'MarkerFaceColor','r','MarkerEdgeColor','k');
% t1 = plot(tXY(1,1),tXY(1,2),'ro');
ylabel(hbar_2, 'Mean Heat Flux [kWm^{-2}]','FontWeight','bold');
title(['Mean Heat Flux at Time: ',num2str(T), ' min.']);
% legend([p5,p8],{'thresh-dijkstra','thresh-astar'});
legend([p6,p9],{'temp-const iDijkstra','temp-const iDijkstra-bin'});
% legend([p1,p5,p8,p10,p3,p6,p9,s1,t1],{'naive','thresh-dijkstra','thresh-BFS','thresh-astar','temp-const MILP','temp-const iDijkstra','temp-const iDijkstra-bin','start','goal'});

set(gca,'FontWeight','bold')
hold off

% [h_rad_mean, h_rad_var] =  GetTaosRadiationFigures([3 4], dom, DroneFluxMean, DroneFluxVar, T);
