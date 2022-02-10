function obj = SetEnergyParameters(obj,maxEnergy,resEnergy,hoverPower,motionPowerFac)
%Set Energy Limits - Maximum and Reserve
if nargin ~=0
    if size(maxEnergy,1) == size(resEnergy,1)
        for i = 1:size(maxEnergy,1)
            obj(i,1).maxEnergy = maxEnergy(i,1);
            obj(i,1).resEnergy = resEnergy(i,1);
            obj(i,1).hoverPower = hoverPower(i,1);
            obj(i,1).motionPowerFac = motionPowerFac(i,1);
        end
    end
end
end