function [polyNodes,polyEdges,polySize,startPt,finalPt,bound,imageFile] = mapExtract()

% Choose Area Size
small_area = 1; % 0 - for original area, 1 - for reduced area

if small_area == 1
    % For Smaller Area
    % Generate a trimmed region using ArcGIS
    shapefilename = 'Export_Output_Small.shp';
    
    % Number of buildings to be considered
    selectBldg = 23; % Max 23
    
    % Geodetic Coordinates of Start and End Points
%     X0 = -87.61903;
%     Y0 = 41.88662;
%     Xf = -87.62378;
%     Yf = 41.88717;
    
    X0 = -87.62378;
    Y0 = 41.88717;
    Xf = -87.61903;
    Yf = 41.88662;
    
    imageFile = 'chicagoMap_Small.png';
else
    % For Bigger Area
    % Generate a trimmed region using ArcGIS
    shapefilename = 'Export_Output.shp';
    
    % Number of buildings to be considered
    selectBldg = 30; % Max 40
    
    % Geodetic Coordinates of Start and End Points
    X0 = -87.61547;
    Y0 = 41.88501;
    Xf = -87.62378;
    Yf = 41.88717;
    
    imageFile = 'chicagoMap.png';
end

% Amount of Padding in degree
padLat = 0.0001;
padLon = 0.0001;

boundary = 2;     % 0 - As is, 1 - Boundary, 2 - Convex Hull, 3 - Bounding Quad
reducePoints = 1; % 0 - False, 1 - True


% Extract Buildings from the trimmed shapefile
BldgMapStruct = shaperead(shapefilename);

% Rename X and Y to Lat and Lon
f = fieldnames(BldgMapStruct);
v = struct2cell(BldgMapStruct);
f{strmatch('X',f,'exact')} = 'Lon';
f{strmatch('Y',f,'exact')} = 'Lat';
BldgMapStruct = cell2struct(v,f);

% Generate a Bounding Box with padding
deltaLat = padLat;
deltaLon = padLon;
[minLat, maxLat, minLon, maxLon] = mapBox(BldgMapStruct,deltaLat,deltaLon);
boundRectLL = [minLon minLat; maxLon minLat; maxLon maxLat; minLon maxLat]; % coordinates of Bounding Box

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract the polygons in to geoshape file
% Full Map
BldgMapStructAll = BldgMapStruct;
BldgShapesAll = geoshape(BldgMapStructAll);

% Selected Buildings
BldgMapStruct = BldgMapStruct([1:selectBldg],1);
BldgShapes = geoshape(BldgMapStruct);
numBldg = size(BldgMapStruct,1);

% Extract Building Coordinates
obsCoords = cell(numBldg,2);
for i = 1:numBldg
    obsCoords{i,1} = BldgMapStruct(i).Lon';
    obsCoords{i,2} = BldgMapStruct(i).Lat';
end

% Convert the Obstacle Coordinates into Nodes and Edge List
% convert to XY coordinates from LL
[nodeLL,edge,polySize] = mapToGeometry(obsCoords,boundRectLL,boundary,reducePoints);
nodeXY = zeros(size(nodeLL));
[nodeXY(:,1),nodeXY(:,2),~] = geodetic2enu(nodeLL(:,2),nodeLL(:,1),zeros(size(nodeLL,1),1),minLat,minLon,0,wgs84Ellipsoid); 

% Start and End Points - convert to XY coordinates from LL
sLL = [X0 Y0];
tLL = [Xf Yf];
[sXY(:,1),sXY(:,2),~] = geodetic2enu(sLL(:,2),sLL(:,1),zeros(size(sLL,1),1),minLat,minLon,0,wgs84Ellipsoid);
[tXY(:,1),tXY(:,2),~] = geodetic2enu(tLL(:,2),tLL(:,1),zeros(size(tLL,1),1),minLat,minLon,0,wgs84Ellipsoid);

% Bounding Box - convert to XY coordinates from LL
[boundRectXY(:,1),boundRectXY(:,2),~] = geodetic2enu(boundRectLL(:,2),boundRectLL(:,1),zeros(size(boundRectLL,1),1),minLat,minLon,0,wgs84Ellipsoid);

% if delta ~=0
%     nodeSansBB = nodeXY(size(boundRectXY,1)+1:end,:);
%     edgeSansBB = edge(size(boundRectXY,1)+1:end,:)-size(boundRectXY,1);
%     [nodeSansBB,edgeSansBB,polySize] = polgonReSizing(nodeSansBB,edgeSansBB,polySize,delta);
%     nodeXY = [nodeXY(1:size(boundRectXY,1),:); nodeSansBB];
%     edge = [edge(1:size(boundRectXY,1),:); edgeSansBB+size(boundRectXY,1)];
% end

% Return Outputs
polyNodes = nodeXY(size(boundRectXY,1)+1:end,:);
polyEdges = edge(size(boundRectXY,1)+1:end,:)-size(boundRectXY,1);
startPt = sXY;
finalPt = tXY;
bound = boundRectXY;
% guessGen.x = dualVertices(TR,1);
% guessGen.y = dualVertices(TR,2);
% 
% guessGen = smoothen(guessGen);
end