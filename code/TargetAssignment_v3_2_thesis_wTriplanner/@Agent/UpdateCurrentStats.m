function obj = UpdateCurrentStats(obj,deltaTdyna,returnHomeEn)
if nargin ==0
    return
end
% Update Current Location
for k = 1:size(obj,1)
    if ~isempty(obj(k,1).remainPath)
        %-----------------------------------------------------------------%
        % When the agent has not reached the target, i.e. path is remaining
        %-----------------------------------------------------------------%
        edgeDist = sqrt(diff(obj(k,1).remainPath(:,1)).^2 + diff(obj(k,1).remainPath(:,2)).^2);
        cumDist = [0;cumsum(edgeDist)];
        
        % max distance the agent could travel in given time step
        maxDistCovered = obj(k,1).speed*deltaTdyna*60;
        
        if maxDistCovered > cumDist(end,1)
            % When agent could have travelled more than the remainng distance
            obj(k,1).agentStatus = 'avail';
            obj(k,1).targType = 'none';
            obj(k,1).currLoc = obj(k,1).targLoc;
            obj(k,1).confVal  = [];
            obj(k,1).fullPath = [];
            obj(k,1).remainPath = [];
            
            % Calculate Energy Spent to Reach and Hover only time after reaching
            if returnHomeEn == 1
            remainTime = (maxDistCovered-cumDist(end,1))/obj(k,1).speed;
            obj(k,1).remainEnergy = obj(k,1).remainEnergy...
                - obj(k,1).hoverPower*((cumDist(end,1)/obj(k,1).speed)*(1+obj(k,1).speed*obj(k,1).motionPowerFac)+remainTime);
            end
        else
            % When agent could not have reached the goal in this time step
            
            % identify which waypoints are covered
            indices = find((cumDist - maxDistCovered) > 0);
            next_idx = indices(1);
            prev_idx = indices(1)-1;
            
            % calculate heading of the way segment it is in
            heading = atan2((obj(k,1).remainPath(next_idx,2)-obj(k,1).remainPath(prev_idx,2)),...
                (obj(k,1).remainPath(next_idx,1)-obj(k,1).remainPath(prev_idx,1)));
            
            % update current location; remaing path and energy  based on the distance travelled
            obj(k,1).currLoc = obj(k,1).remainPath(prev_idx,:) + (maxDistCovered-cumDist(prev_idx))*[cos(heading) sin(heading)];
            obj(k,1).remainPath = [obj(k,1).currLoc; obj(k,1).remainPath(next_idx:end,:)];
            if returnHomeEn == 1
            obj(k,1).remainEnergy = obj(k,1).remainEnergy - deltaTdyna*60*obj(k,1).hoverPower*(1+obj(k,1).speed*obj(k,1).motionPowerFac);
            end
        end
        
%         totalDist = sum(sqrt(diff(obj(k,1).fullPath(:,1)).^2 + diff(obj(k,1).fullPath(:,2)).^2));
%         remainDist = sum(sqrt(diff(obj(k,1).remainPath(:,1)).^2 + diff(obj(k,1).remainPath(:,2)).^2));
%         distCovered = totalDist - remainDist;
%         disp(['ID ',num2str(obj(k,1).agentID),', Distance Covered = ',num2str(distCovered),'m']);
    else
        %-----------------------------------------------------------------%
        % When the agent has reached the conf target, it hovers
        % When the agent has reached the home target, it stops
        %-----------------------------------------------------------------%
        if returnHomeEn == 1 && all(obj(k,1).currLoc ~= obj(k,1).homeLoc)
        obj(k,1).remainEnergy = obj(k,1).remainEnergy - deltaTdyna*60*obj(k,1).hoverPower;
        end
    end
end
end