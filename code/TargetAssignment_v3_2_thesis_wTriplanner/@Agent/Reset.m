function obj = Reset(obj)
% Reset Current & Target Location to Home Loc 
% and Current Energy level to Max Energy Level
if nargin ~=0
    for i = 1:size(obj,1)
        obj(i,1).currLoc    = obj(i,1).homeLoc;
        obj(i,1).targLoc    = obj(i,1).homeLoc;
        obj(i,1).remainEnergy = obj(i,1).maxEnergy;
    end
end
end