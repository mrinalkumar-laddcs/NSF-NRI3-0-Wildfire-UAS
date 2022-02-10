%-------------------------------------------------------------------------%
% Problem Setup
%-------------------------------------------------------------------------%
rng default;
%--------- Initialize Agents ---------%
% Setup Agent IDs
agentIDs = (1:nAgents)';

% Setup Agent Home Locations
if AgentStartType == 1
    homeAgentLoc = [(home.loc(1,1) + home.r*cos(2*pi*(1:nAgents)'/nAgents)), (home.loc(1,2) + home.r*sin(2*pi*(1:nAgents)'/nAgents))];
%     homeAgentLoc = [1122.45, 1683.67;
%                     1479.59, 867.35;
%                     1683.67, 765.31];
%     homeAgentLoc = [510.204081632653,510.204081632653;
%                     510.204081632653,1224.48979591837;
%                     1683.67346938776,765.306122448980];
elseif AgentStartType == 2
    homeAgentLoc = [env.dom.xMin+(env.dom.xMax-env.dom.xMin)*rand(nAgents,1), env.dom.yMin+(env.dom.yMax-env.dom.yMin)*rand(nAgents,1)];
else
    error('Invalid Agent Start Location Type');
end

% Setup Agent Current Locations
currAgentLoc = [1327.204081632653,1327.204081632653;
                510.204081632653,1224.48979591837;
                1683.67346938776,765.306122448980];
% currAgentLoc = [1276.204081632653,1378.204081632653;
%                 510.204081632653,1224.48979591837;
%                 1683.67346938776,765.306122448980];
% currAgentLoc = [510.204081632653,510.204081632653;
%                 510.204081632653,1224.48979591837;
%                 1683.67346938776,765.306122448980];

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

% Set Current Locations
agent.SetCurrLoc(currAgentLoc);