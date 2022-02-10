function [approach,boundary,data_file] = verifySettings(settingsFile)
load(settingsFile);

% Approach -  'rolling': Rolling Window (time varying map), 'static': Static (fixed map)
switch approach.type
    case 'rolling'
        approach.typeID = 1;
        time   = approach.rolling.tStart:approach.rolling.tDelta:approach.rolling.tFinal;
        nSteps = length(time);
        if size(approach.rolling.finalPoint,1) ~= (nSteps-1)
            error('Number of final (x,y) points is inconsistent with the number of final time check points');
        end
        
    case 'static'
        approach.typeID = 2;
        
    otherwise
        error('Invalid approach type');
end

% Map Boundary Type - 'probab': Probabilistic Heat Flux Map, 'nominal': Nominal Boundary Map 
switch boundary.type
    case 'probab'
        boundary.typeID = 1;
        
    case 'nominal'
        boundary.typeID = 2;
        
    otherwise
        error('Invalid boundary type');
end

% Data File Type - 'flux': Probabilistic Flux Data File, 'clus': Clustered Data File
switch data_file.type
    case 'flux'
        data_file.typeID = 1;
        
    case 'clus'
        data_file.typeID = 2;
        
    otherwise
        error('Invalid data file type');
end

% LOGIC: probab boundary aproach requires probab flux data only. nominal 
% boundary approach uses probab flux data to get nominal contour or use
% clustered data.
if boundary.typeID == 1 && data_file.typeID ~= 1
    error('Invalid combination of Map boundary type and Data File type');
end
end