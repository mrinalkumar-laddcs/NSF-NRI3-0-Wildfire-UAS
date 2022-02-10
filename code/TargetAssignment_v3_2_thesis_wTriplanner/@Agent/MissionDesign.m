function obj = MissionDesign(obj,conf,alpha,returnHomeEn,PlannerType,env)
%-------------------------------------------------------------------------%
% Mission Design Philosophy
%-------------------------------------------------------------------------%
% Current Mission Design approach does not exclude agents that have not
% completed the previous mission when the next mission is being executed.
% During Mission Design, it is assummed that all agents are available for
% the next mission planning.
% In Mission Design, the agent is at some Current Location - that could be
% Home, some previous target, or a middle location.
%
% The goal is to assign a target.
%
% There are two considerations:
% 1. Agent can go to the target assigned
% 2. Agent can NOT go to a target. For two possible reasons:
%       a. target is identified in a no-fly zome
%       b. the battery is not enough to complete the target and then go
%       home
%
% It is important to consider the agents's inability in the mission design.
% Otherwise, the allocation may not be optimal.
%
% Note that the agent shall return home only when the battery is
% significantly lower. For that the agent shall constantly monitor it's
% return-to-home distance and execute RTH when low. It should ideally
% happen onboard.
%
% Decision Making for RTH would unnecessarily require the agent to invoke
% path generation and planning on the ground station. Therefore, only
% straight line measures (with buffers) are used. Once the RTH is executed,
% the path generation is carried out for safe travels to home. The reserve 
% battery would be used if the path significantly deviant from the straight
% line one.

%-------------------------------------------------------------------------%
% Mission Design Steps
%-------------------------------------------------------------------------%
% 1. Extract Data
% 2. Get Energy Metrics based on Approx Path
% 3. Cost Matrix Design
% 4. Perform Assignment
% 5. Check Assignment - go or no go
% 6. Perform Target and Path Allocation

%---------------------------- Extract Data -------------------------------%

nAgents = size(obj,1);
nConf   = size(conf,1);

homeAgentLoc  = reshape([obj.homeLoc]',[size(obj(1).homeLoc,2), nAgents])';
currAgentLoc  = reshape([obj.currLoc]',[size(obj(1).currLoc,2), nAgents])';
agentSpeed    = reshape([obj.speed]',[size(obj(1).speed,2), nAgents])';
hoverPower    = reshape([obj.hoverPower]',[size(obj(1).hoverPower,2), nAgents])';
motionPowerFac= reshape([obj.motionPowerFac]',[size(obj(1).motionPowerFac,2), nAgents])';
currAgentLoc  = reshape([obj.currLoc]',[size(obj(1).currLoc,2), nAgents])';
remainEnergy  = reshape([obj.remainEnergy]',[size(obj(1).remainEnergy,1), nAgents])';
resEnergy     = reshape([obj.resEnergy],[size(obj(1).resEnergy,1), nAgents])';

confLoc = reshape([conf.Loc]',[size(conf(1).Loc,2), nConf])';
confVal = reshape([conf.Val]',[size(conf(1).Val,1), nConf])';


%-------------------------- Get Energy Metrics ---------------------------%
time2energy = diag(hoverPower)*(eye(nAgents)+diag(motionPowerFac)*diag(agentSpeed));

[distMat,pathMat] = GetGuessDistPath(currAgentLoc,confLoc,agentSpeed,env,PlannerType);
timeMat           = diag(1./agentSpeed)*distMat;
energyMat         = time2energy*timeMat;
 if returnHomeEn == 1
    targetHomeDistMat   = GetGuessDistPath(homeAgentLoc,confLoc,agentSpeed,env,PlannerType);
    targetHometimeMat   = diag(1./agentSpeed)*targetHomeDistMat;
    targetHomeEnergyMat = time2energy*targetHometimeMat;
end

%-------------------------- Cost Matrix Design ---------------------------%

% EM = energyMat; % energy
EM = energyMat./max(energyMat(:)); % normalized energy

% Cost Matrix:
% Min Distance only
% CM = EM;

% Max Conflict only
% CM = -ones(nAgents,nConf)*diag(confVal);
% CM = -ones(nAgents,nConf)*diag(1./(1-confVal));

% Distance and Conf Based:
CM = -alpha*ones(nAgents,nConf)*diag(confVal) + (1-alpha)*EM;
% CM = -alpha*ones(nAgents,nConf)*diag(1./(1-confVal)) + (1-alpha)*EM;
% CM = EM*diag(1./confVal);

% If the target is invalid/unsafe, then increase the cost.
[r,c] = ind2sub([nAgents,nConf],find(cellfun(@isempty,pathMat)));
for i = 1:size(r,1)
    CM(r(i),c(i)) = CM(r(i),c(i)) + 10;
end

% If the agent cannot return after mission, then increase the cost.
if returnHomeEn == 1
    resEnergyMat            = repmat(resEnergy,1,nConf);
    remainEnergyMat         = repmat(remainEnergy,1,nConf);
    remainEnergyForecastMat = remainEnergyMat - energyMat - targetHomeEnergyMat;
    [r,c] = ind2sub([nAgents,nConf],find(remainEnergyForecastMat<resEnergyMat));
    for i = 1:size(r,1)
        CM(r(i),c(i)) = CM(r(i),c(i)) + 10;
    end
end


%-------------------------- Perform Assignment ---------------------------%

if nAgents<=nConf
    % Agent = i, Conf Point = j
    iLoc = currAgentLoc;
    jLoc = confLoc;
    nI = nAgents;
    nJ = nConf;
    
    CM = CM';
else
    % Conf Point = i, Agent = j
    iLoc = confLoc;
    jLoc = currAgentLoc;
    nI = nConf;
    nJ = nAgents;
end

assign = Assignment(CM,nI,nJ);

matchedPairs = zeros(min(nAgents,nConf),2);
if nAgents<=nConf
    % Agent = i, Conf Point = j
    % nI = nAgents;
    % nJ = nConf;
    k = 1;
    for i=1:nAgents
        target = find(assign(:,i)');
        if ~isempty(target)
            matchedPairs(k,:) = [i, target(1,1)];
            k = k+1;
        end
    end
else
    % Conf Point = i, Agent = j
    % nI = nConf;
    % nJ = nAgents;
    k = 1;
    for i=1:nConf
        target = find(assign(:,i)');
        if ~isempty(target)
            matchedPairs(k,:) = [target(1,1) i];
            k = k+1;
        end
    end
end


%------------------ Check Assignment for Return Home ---------------------%
% if returnHomeEn == 1
%     for k = 1:size(matchedPairs,1)
%         if remainEnergyForecastMat(matchedPairs(k,1),matchedPairs(k,2))...
%                 < resEnergyMat(matchedPairs(k,1),matchedPairs(k,2))
%             matchedPairs(k,2) = -1*matchedPairs(k,1); % return home
%         end
%     end
% end
%------------------ Check Assignment for feasibility ---------------------%
matchedPairsFinal = matchedPairs;
for k = 1:size(matchedPairs,1)
    if isempty(pathMat{matchedPairs(k,1),matchedPairs(k,2)})
        matchedPairsFinal(k,2) = 0;
    end
    if returnHomeEn == 1
        if remainEnergyForecastMat(matchedPairs(k,1),matchedPairs(k,2))...
                < resEnergyMat(matchedPairs(k,1),matchedPairs(k,2))
            matchedPairsFinal(k,2) = 0;
        end
    end
end


%------------------ Perform Target and Path Allocation -------------------%

for k = 1:size(matchedPairsFinal,1)
%     if matchedPairs(k,2)< 0
%         % -ve sign indicates the agent is assigned to go to home location
%         obj(k,1).agentStatus = 'mission';
%         obj(k,1).targType = 'home';
%         obj(k,1).targLoc  = obj(-1*matchedPairs(k,2),1).homeLoc;
%         obj(k,1).confVal  = 1;
%         % DESIGN PATH FOR HOME
    if matchedPairsFinal(k,2) == 0
        % -ve sign indicates the agent is assigned to go to home location
        obj(k,1).agentStatus = 'avail';
        obj(k,1).targType = 'none';
        obj(k,1).targLoc  = obj(k,1).currLoc;
        obj(k,1).confVal  = [];
        obj(k,1).fullPath = [];
        obj(k,1).remainPath = [];
    else
        % non-negative target is the index of conflict point at the assignment time step
        obj(k,1).agentStatus = 'mission';
        obj(k,1).targType = 'conf';
        obj(k,1).targLoc  = conf(matchedPairsFinal(k,2),1).Loc;
        obj(k,1).confVal  = confVal(matchedPairsFinal(k,2),1);
        obj(k,1).fullPath = pathMat{matchedPairsFinal(k,1),matchedPairsFinal(k,2)};
        obj(k,1).remainPath = obj(k,1).fullPath;
    end
end

end