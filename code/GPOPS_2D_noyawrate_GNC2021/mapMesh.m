% clear all; close all; clc;

function [polyNodes,polyEdges,polySize,startPt,finalPt,bound,guessGen] = mapMesh(delta)
%---------------------------- Problem Setup ------------------------------%
% Choose Area Size
small_area = 1; % 0 - for original area, 1 - for reduced area


if small_area == 1
    % For Smaller Area
    % Generate a trimmed region using ArcGIS
    shapefilename = 'Export_Output_Small.shp';
    
    % Number of buildings to be considered
    selectBldg = 15; % Max 23
    
    % Geodetic Coordinates of Start and End Points
    X0 = -87.61903;
    Y0 = 41.88662;
    Xf = -87.62378;
    Yf = 41.88717;
    
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

boundary = 2;      % 0 - As is, 1 - Boundary, 2 - Convex Hull, 3 - Bounding Quad
reducePoints = 1; % 0 - False, 1 - True

%---------------------------- End of Setup -------------------------------%


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
[nodeLL,edge,polySize] = mapToGeometry(obsCoords,boundRectLL,boundary,reducePoints);
nodeXY = zeros(size(nodeLL));
[nodeXY(:,1),nodeXY(:,2),~] = geodetic2enu(nodeLL(:,2),nodeLL(:,1),zeros(size(nodeLL,1),1),minLat,minLon,0,wgs84Ellipsoid); 



% Start and End Points
sLL = [X0 Y0];
tLL = [Xf Yf];
[sXY(:,1),sXY(:,2),~] = geodetic2enu(sLL(:,2),sLL(:,1),zeros(size(sLL,1),1),minLat,minLon,0,wgs84Ellipsoid);
[tXY(:,1),tXY(:,2),~] = geodetic2enu(tLL(:,2),tLL(:,1),zeros(size(tLL,1),1),minLat,minLon,0,wgs84Ellipsoid);
% Bounding Box
[boundRectXY(:,1),boundRectXY(:,2),~] = geodetic2enu(boundRectLL(:,2),boundRectLL(:,1),zeros(size(boundRectLL,1),1),minLat,minLon,0,wgs84Ellipsoid);

if delta ~=0
    nodeSansBB = nodeXY(size(boundRectXY,1)+1:end,:);
    edgeSansBB = edge(size(boundRectXY,1)+1:end,:)-size(boundRectXY,1);
    [nodeSansBB,edgeSansBB,polySize] = polgonReSizing(nodeSansBB,edgeSansBB,polySize,delta);
    nodeXY = [nodeXY(1:size(boundRectXY,1),:); nodeSansBB];
    edge = [edge(1:size(boundRectXY,1),:); edgeSansBB+size(boundRectXY,1)];
end

% Trigulation Process
node = nodeXY;
opts.kind = 'delaunay';
opts.rho2 = +1.0;
[vert,etri,tria,tnum] = refine2(node,edge,[],opts);         % triangulation mesh
[vert,etri,tria,tnum] = smooth2(vert,etri,tria,tnum);       % optimization of mesh for smoothness
[vnew,enew,tnew,tnum] = tridiv2(vert,etri,tria,tnum);       % mesh division
[vert,etri,tria,tnum] = smooth2(vnew,enew,tnew,tnum);       % optimization of mesh for smoothness
% [vnew,enew,tnew,tnum] = tridiv2(vert,etri,tria,tnum);       % mesh division
% [vert,etri,tria,tnum] = smooth2(vnew,enew,tnew,tnum);       % optimization of mesh for smoothness
triKO = triangulation(tria,vert);                   % triangulation object
edgeList = edges(triKO);
% s = edgeList(:,1);
% t = edgeList(:,2);
% G = graph(s,t,edgeWeights(CDT_KO.Points(s,:),CDT_KO.Points(t,:)));

% Generate Dual of Delaunay Triangulation
inCenters = incenter(triKO);
edgeTable_cell = edgeAttachments(triKO,edgeList(:,1),edgeList(:,2));
edgeTable_mat = cell2mat(edgeTable_cell(cellfun('size',edgeTable_cell,2)==2));
s = edgeTable_mat(:,1);
t = edgeTable_mat(:,2);
G_dual = graph(s,t,edgeWeights(inCenters(s,:),inCenters(t,:)));

% Replace the incenter by the start and end point and update the dual
S_idx = pointLocation(triKO,sXY);
T_idx = pointLocation(triKO,tXY);
dualVertices = inCenters;
dualVertices(S_idx,:) = sXY;
dualVertices(T_idx,:) = tXY;

% Generate the shortestpath in the dual.
G_dual_update = graph(s,t,edgeWeights(dualVertices(s,:),dualVertices(t,:)));
TR = shortestpath(G_dual_update,S_idx,T_idx);

% Generate the funnel
preFunnel = triangulation(triKO.ConnectivityList(TR,:),triKO.Points);
[~,sReplace] = setdiff(triKO.ConnectivityList(TR(1,1),:),triKO.ConnectivityList(TR(1,2),:));
[~,tReplace] = setdiff(triKO.ConnectivityList(TR(1,end),:),triKO.ConnectivityList(TR(1,end-1),:));
funnelPoints = triKO.Points;
funnelPoints(triKO.ConnectivityList(TR(1,1),sReplace),:) = sXY;
funnelPoints(triKO.ConnectivityList(TR(1,end),tReplace),:) = tXY;
funnel = triangulation(triKO.ConnectivityList(TR,:),funnelPoints);

% Path in Geodetic Coordinates
[pathLL(:,2),pathLL(:,1),~] = enu2geodetic(dualVertices(TR,1),dualVertices(TR,2),zeros(size(dualVertices(TR,1),1),1),minLat,minLon,0,wgs84Ellipsoid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate Plots
img = imread(imageFile);
figure('color','w','Position', [200 80 500 350]);
imagesc([boundRectXY(1,1) boundRectXY(2,1)],[boundRectXY(1,2) boundRectXY(3,2)],flipud(img));
patch('faces',tria(:,1:3),'vertices',vert, ...
    'facecolor','none', ...
    'edgecolor',[.2,.2,.2],'EdgeAlpha',0.3);
hold on; 
% triplot(funnel,'Color','r','LineWidth',0.5);
plot(dualVertices(TR,1),dualVertices(TR,2),'-','Color',[0    0.4470    0.7410],'LineWidth',1.5);
patch('faces',edge(:,1:2),'vertices',node, ...
    'FaceColor','none', ...
    'edgecolor',[0.6350    0.0780    0.1840],'EdgeAlpha',0.6, ...
    'linewidth',1.5) ;
%     'edgecolor',[.9,.3,.3],'EdgeAlpha',0.6, ...
patch('XData',[boundRectXY(1,1) boundRectXY(2,1) boundRectXY(2,1) boundRectXY(1,1)],'YData',[boundRectXY(1,2) boundRectXY(1,2) boundRectXY(3,2) boundRectXY(3,2)], ...
    'FaceColor','none', ...
    'edgecolor',[.1,.1,.1],'EdgeAlpha',0.6, ...
    'linewidth',1.5) ;
scatter(sXY(:,1),sXY(:,2),'filled','MarkerFaceColor',[0.4660    0.8740    0.3880]);
scatter(tXY(:,1),tXY(:,2),'filled','MarkerFaceColor',[0.8500    0.3250    0.0980]);
% wmmarker(tLL(:,2),tLL(:,1),'Color','r','IconScale',0.5);
xlabel('UTM Easting (m)');
ylabel('UTM Northing (m)');
% xlim([boundRectXY(1,1) boundRectXY(2,1)]);
% ylim([boundRectXY(1,2) boundRectXY(3,2)]);
set(gca,'ydir','normal');
daspect([1 1 1]);
box on


% % Return Outputs
% polyNodes = nodeXY;
% polyEdges = edge;
% startPt = sXY;
% finalPt = tXY;
% bound = boundRectXY;
% guessGen.x = dualVertices(TR,1);
% guessGen.y = dualVertices(TR,2);

% Return Outputs
polyNodes = nodeXY(size(boundRectXY,1)+1:end,:);
polyEdges = edge(size(boundRectXY,1)+1:end,:)-size(boundRectXY,1);
startPt = sXY;
finalPt = tXY;
bound = boundRectXY;
guessGen.x = dualVertices(TR,1);
guessGen.y = dualVertices(TR,2);

guessGen = smoothen(guessGen);
end

% % Generate Maps Overlays
% wmclose all
% wm = webmap('World Topographic Map');
% wmpolygon([boundRectLL(:,2); boundRectLL(1,2)],[boundRectLL(:,1); boundRectLL(1,1)],'EdgeColor','k','FaceColor','none');
% wmpolygon(BldgShapes,'EdgeColor','r','FaceColor','black','FaceAlpha',.3);
% wmline(pathLL(:,2),pathLL(:,1),'Color','g');
% wmmarker(sLL(:,2),sLL(:,1),'Color','b','IconScale',0.5);
% wmmarker(tLL(:,2),tLL(:,1),'Color','r','IconScale',0.5);
% wmlimits([minLat maxLat],[minLon maxLon]);

%% %%%% Local Functions %%%%
function output = edgeWeights(startList,endList)
output = sqrt((startList(:,1)-endList(:,1)).^2 + (startList(:,2)-endList(:,2)).^2);
end

function smooth_output = smoothen(guessGen)
init_len = length(guessGen.x);
final_len = 2*(init_len-1);
smooth_output.x = zeros(final_len,1);
smooth_output.y = zeros(final_len,1);

for i = 1:(init_len-1)
    if i == 1
    smooth_output.x(1,1) = guessGen.x(1,1);
    smooth_output.x(2,1) = (guessGen.x(1,1)+guessGen.x(2,1))/2;
    smooth_output.y(1,1) = guessGen.y(1,1);
    smooth_output.y(2,1) = (guessGen.y(1,1)+guessGen.y(2,1))/2;
    else
        if i == (init_len-1)
            smooth_output.x((init_len-2)*2+1,1) = (guessGen.x(init_len-1,1)+guessGen.x(init_len,1))/2;
            smooth_output.x((init_len-2)*2+2,1) = guessGen.x(init_len,1);
            smooth_output.y((init_len-2)*2+1,1) = (guessGen.y(init_len-1,1)+guessGen.y(init_len,1))/2;
            smooth_output.y((init_len-2)*2+2,1) = guessGen.y(init_len,1);
        else
            smooth_output.x((i-1)*2+1,1) = (2*guessGen.x(i,1)+guessGen.x(i+1,1))/3;
            smooth_output.x((i-1)*2+2,1) = (guessGen.x(i,1)+2*guessGen.x(i+1,1))/3;
            smooth_output.y((i-1)*2+1,1) = (2*guessGen.y(i,1)+guessGen.y(i+1,1))/3;
            smooth_output.y((i-1)*2+2,1) = (guessGen.y(i,1)+2*guessGen.y(i+1,1))/3;
        end
    end
end
end

