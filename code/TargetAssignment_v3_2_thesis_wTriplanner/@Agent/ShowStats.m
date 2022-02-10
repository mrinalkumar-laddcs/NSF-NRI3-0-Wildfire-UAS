function obj = ShowStats(obj)
% Update the Energy Level by reducing the energy spent to reach the target
if nargin ~=0
    for i = 1:size(obj,1)
        disp(['ID ',num2str(obj(i,1).agentID),' | Status: ',obj(i,1).agentStatus,...
            ' | Targ Type: ',obj(i,1).targType,' | Curr Location: ',num2str(obj(i,1).currLoc(1,1)),'m ',...
            num2str(obj(i,1).currLoc(1,2)),'m | Remaining Energy: ',num2str(obj(i,1).remainEnergy),' kJ']);
    end
end
end