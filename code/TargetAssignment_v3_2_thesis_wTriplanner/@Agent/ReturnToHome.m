function obj = ReturnToHome(obj,returnHomeEn,PlannerType,env,time2nextMission)
if nargin ~=0
    for k = 1:size(obj,1)
        if (returnHomeEn == 1) && all(obj(k,1).currLoc ~= obj(k,1).homeLoc)
            if isempty(obj(k,1).remainPath)
                % [dist,path] = GetGuessDistPath(obj(k,1).currLoc,obj(k,1).homeLoc,obj(k,1).speed,env,PlannerType);
                dist = pdist2(obj(k,1).currLoc,obj(k,1).homeLoc);
                time2energy = obj(k,1).hoverPower*(1+diag(obj(k,1).motionPowerFac)*diag(obj(k,1).speed));
                time2home = dist/obj(k,1).speed;
                energy = time2energy*time2home;
                remainEnergyForecast = obj(k,1).remainEnergy - energy;
                
                if remainEnergyForecast < obj(k,1).resEnergy
                    [dist,path] = GetGuessDistPath(obj(k,1).currLoc,obj(k,1).homeLoc,obj(k,1).speed,env,PlannerType);
                    obj(k,1).agentStatus = 'mission';
                    obj(k,1).targType = 'home';
                    obj(k,1).targLoc = obj(k,1).homeLoc;
                    obj(k,1).confVal  = [];
                    
                    obj(k,1).fullPath = path{1,1};
                    obj(k,1).remainPath = obj(k,1).fullPath;
                end
            end
        end
    end
end
end