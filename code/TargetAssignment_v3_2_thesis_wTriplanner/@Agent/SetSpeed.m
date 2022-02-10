function obj = SetSpeed(obj,speed)
% Set Agent Speed
if nargin ~=0
    for i = 1:size(speed,1)
        obj(i,1).speed = speed(i,:);
    end
end
end