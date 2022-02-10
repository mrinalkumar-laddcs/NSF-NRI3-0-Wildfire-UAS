function obj = SetHome(obj,homeLoc)
% Set Home Location
if nargin ~=0
    for i = 1:size(homeLoc,1)
        obj(i,1).homeLoc = homeLoc(i,:);
    end
end
end