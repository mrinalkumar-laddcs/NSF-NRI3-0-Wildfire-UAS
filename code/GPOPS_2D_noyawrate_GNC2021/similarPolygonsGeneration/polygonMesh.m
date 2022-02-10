function [polyNodes,polyEdges,polySize,startPt,finalPt,bound,guessGen] = polygonMesh(node,edge,polygonSize,xMin,xMax,yMin,yMax)

%---------------------------- Problem Setup ------------------------------%
% Start Point
X0  = 90;
Y0  = 5;
% X0  = 60;
% Y0  = 50;
% X0  = 140;
% Y0  = 20;

% Start Point
Xf = 60;
Yf = 150;
% Xf = 60;
% Yf = 100;
% Xf = 20;
% Yf = 140;

%---------------------------- End of Setup -------------------------------%

boundRectXY = [xMin yMin; xMax yMin; xMax yMax; xMin yMax]; % coordinates of Bounding Box
boundEdges = [(1:3)' (2:4)'; 4 1];

% Start and End Points
sXY = [X0 Y0];
tXY = [Xf Yf];

% Trigulation Process
nodeList = [boundRectXY; node];
edgeList = [boundEdges; size(boundRectXY,1)+edge];
opts.kind = 'delaunay';
opts.rho2 = +1.0;
[vert,etri,tria,tnum] = refine2(nodeList,edgeList,[],opts); % triangulation mesh
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
% G_dual = graph(s,t,edgeWeights(inCenters(s,:),inCenters(t,:)));

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
% preFunnel = triangulation(triKO.ConnectivityList(TR,:),triKO.Points);
[~,sReplace] = setdiff(triKO.ConnectivityList(TR(1,1),:),triKO.ConnectivityList(TR(1,2),:));
[~,tReplace] = setdiff(triKO.ConnectivityList(TR(1,end),:),triKO.ConnectivityList(TR(1,end-1),:));
funnelPoints = triKO.Points;
funnelPoints(triKO.ConnectivityList(TR(1,1),sReplace),:) = sXY;
funnelPoints(triKO.ConnectivityList(TR(1,end),tReplace),:) = tXY;
funnel = triangulation(triKO.ConnectivityList(TR,:),funnelPoints);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate Plots
figure('color','w','Position', [200 80 500 350]);
patch('faces',tria(:,1:3),'vertices',vert, ...
    'facecolor','w', ...
    'edgecolor',[.2,.2,.2]) ;
hold on; 
triplot(funnel,'Color','r','LineWidth',0.5);
plot(dualVertices(TR,1),dualVertices(TR,2),'-g','LineWidth',1);
patch('faces',edgeList(:,1:2),'vertices',nodeList, ...
    'FaceColor','w', ...
    'edgecolor',[.1,.1,.1], ...
    'linewidth',1.5) ;
xlabel('UTM Easting (m)');
ylabel('UTM Northing (m)');
xlim([boundRectXY(1,1) boundRectXY(2,1)]);
ylim([boundRectXY(1,2) boundRectXY(3,2)]);
daspect([1 1 1]);
box on


% Return Outputs
polyNodes = node;
polyEdges = edge;
polySize = polygonSize;
startPt = sXY;
finalPt = tXY;
bound = boundRectXY;
guessGen.x = dualVertices(TR,1);
guessGen.y = dualVertices(TR,2);
end

%% %%%% Local Functions %%%%
function output = edgeWeights(startList,endList)
output = sqrt((startList(:,1)-endList(:,1)).^2 + (startList(:,2)-endList(:,2)).^2);
end