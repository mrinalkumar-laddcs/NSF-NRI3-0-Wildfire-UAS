function obj = SetCurrLoc(obj,currLoc)
% Set Current Location
if nargin ~=0
    for i = 1:size(obj,1)
        obj(i,1).currLoc    = currLoc(i,:);
        obj(i,1).targLoc    = currLoc(i,:);
    end
end
end

