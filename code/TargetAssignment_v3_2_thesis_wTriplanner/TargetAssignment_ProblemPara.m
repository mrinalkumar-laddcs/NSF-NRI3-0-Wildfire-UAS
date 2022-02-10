%-------------------------------------------------------------------------%
% Setup Problem Parameters
%-------------------------------------------------------------------------%
% Domain
% Region of Interest
% Home Location, Number of Agents
% Number of Conflict Points
% Time Horizon
% Time Step Size

if DomainScenarioType == 1
    % Load in all of the necessary data
    load('FireRadiationData.mat','UTM_east');
    load('FireRadiationData.mat','UTM_north');
    
    dom.xMin = 0;  dom.xMax = max(UTM_east) - min(UTM_east);   % Domain
    dom.yMin = 0;  dom.yMax = max(UTM_north)-min(UTM_north);   % Domain
elseif DomainScenarioType == 2
    dom.xMin = 0;  dom.xMax = 2500;   % Domain
    dom.yMin = 0;  dom.yMax = 2500;   % Domain
else
    error('Invalid Domain Selection');
end

if FireScenarioType == 1
    % Load in all of the necessary data
    load('FireRadiationData.mat','DroneFluxCube_hard');
    
    % Get the mean and variance of the heat flux
    [DroneFluxMean, DroneFluxVar] =  DroneFluxStats(DroneFluxCube_hard);
elseif FireScenarioType == 2
    error('No Toy fire data available yet');
else
    error('Invalid Fire Scenario Type');
end

if ConfScenarioType == 1
    % Load in all of the necessary data
    load('FireRadiationData.mat','ConflictCell');
elseif ConfScenarioType == 2 || ConfScenarioType == 3
else
    error('Invalid Conflict Scenario Type');
end

roi.xMin = 200; roi.xMax = dom.xMax;   % Region of Interest
roi.yMin = 200; roi.yMax = dom.yMax;   % Region of Interest

% Environment Parameters
env.dom = dom;
env.roi = roi;
env.const.nodes = [];
env.const.edges = [];
env.const.polySize = [];
% env.heatflux.X 
% env.heatflux.Y
% env.heatflux.hfmean
% env.heatflux.hfvar

% Problem Parameters
home.loc  = [100,100];% Home Location Center
home.r    = 70;     % radial distance of agents from Home Location Center
AgentSpeed  = 12;   % Agent speed (unit: m/s)
AgentEnergyMax = 600;  % Max distance an agent can travel (1000kJ approx 6S1P 12.5Ah Batt)
AgentEnergyRes = 150;  % Reserve Energy of the Agent
AgentHoverPower     = 0.6;    % Hover Power Consumption (units: kW)
AgentMotionPowerFac = 0.5/15; % Additional Power Factor (func of speed) when in motion
nAgents   = 3;      % Number of Agents

nConf_min = 4;      % Min number of Conflict Points (when using Random Case)
nConf_max = 9;      % Max number of Conflict Points (when using Random Case)
nConf_fix = 4;      % Fixed number of Conflict Point (when using Fixed Case)

deltaTdyna    = 0.25;% Time Step Size for Dynamics (unit: minutes)
deltaTconf    = 0.5;  % Time Step Size for Conf update (unit: minutes)
deltaTmission = 5;  % Time Step Size for Mission Update (unit: minutes)
deltaTfireEst = 10; % Time Step Size for New Fire Estimate (unit: minutes)
T_start    = 80;    % Simulation Start Time
T_end      = 100;    % Simulation End Time

alpha      = 0.5;   % 0 <= alpha <= 1

% Auxilary Parameters
txtOffset = 40;      % Offset for showing agent label text