function obj = ResetEnergy(obj,restoreBatt)
% Reset Current Energy level to Max Energy Level
if nargin ~=0
    if restoreBatt == 1
        for k = 1:size(obj,1)
            if isempty(obj(k,1).remainPath) && all(obj(k,1).currLoc == obj(k,1).homeLoc)
                %-----------------------------------------------------------------%
                % When the agent has reached the home target, charge battery
                %-----------------------------------------------------------------%
                
                obj(k,1).remainEnergy = obj(k,1).maxEnergy;
            end
        end
    end
end
end