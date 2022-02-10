function [distMat,pathMat] = GetGuessDistPath(currAgentLoc,confLoc,agentSpeed,env,PlannerType)
nAgents = size(currAgentLoc,1);
nConf   = size(confLoc,1);

distMat = zeros(nAgents,nConf);
pathMat = cell(nAgents,nConf);

if PlannerType == 1 % No Obstacle Avoidance
    distMat = pdist2(currAgentLoc,confLoc);
end

k = 1;
for i = 1:nAgents
    for j = 1:nConf
        disp(['solving path #',num2str(k)]);
        k = k + 1;
        if     PlannerType == 1     % No Obstacle Avoidance
            pathMat{i,j} = [currAgentLoc(i,:); confLoc(j,:)];
        elseif PlannerType == 2 ... % Obstacle Avoidance without Heat
               || PlannerType == 3  % Obstacle Avoidance with Heat Threshold
            % Grid or Triplanner
            [distMat(i,j),pathMat{i,j}] = GuessDistPathGrid(currAgentLoc(i,:),confLoc(j,:),agentSpeed(i,1),env,PlannerType);
            % [distMat(i,j),pathMat{i,j}] = GuessDistPathTriplanner(currAgentLoc(i,:),confLoc(j,:),agentSpeed,env,dom,PlannerType);
        elseif PlannerType == 4     % Obstacle Avoidance with Temp Limits
            % Grid
            [distMat(i,j),pathMat{i,j}] = GuessDistPathGrid(currAgentLoc(i,:),confLoc(j,:),agentSpeed(i,1),env,PlannerType);
        end
    end
end

if ~(PlannerType >= 1 && PlannerType <=4)
    error('Invalid Planner Type Selection');
end
end