function obj = AssignTargetLoc(obj,conf,targetAssign)
% Assign Target Location to each Agent
% Target Locations are extracted from the Target Assignments
if nargin ~=0
    for k = 1:size(targetAssign,1)
        if targetAssign(k,2)< 0
            % -ve sign indicates the agent is assigned to go to home location
            obj(k,1).targLoc = obj(-1*targetAssign(k,2),1).homeLoc;
        else
            % non-negative target is the index of conflict point at the
            % assignment time step
            obj(k,1).targLoc = conf(targetAssign(k,2),1).Loc;
        end
    end
end
end