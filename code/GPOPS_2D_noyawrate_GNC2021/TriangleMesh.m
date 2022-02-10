% clear all; close all; clc;
% %---------------------%
% %%% Given Constants %%%
% %---------------------%
% V     = 10;
% umax  = 1;
% Xc    = [40 129.5];
% Yc    = [80 80];
% r     = [50 40];
% r_min = 10;
% delta = -1;
% 
% %------------------------------%
% %%% Given Initial Conditions %%%
% %------------------------------%
% t0  = 0;
% thetar0 = pi()/2;
% % thetar0 = pi()/4;
% % X0  = 60;
% % Y0  = 5;
% X0  = 150;
% Y0  = 20;
% 
% %-------------------------------%
% %%% Given Final Conditions %%%
% %-------------------------------%
% % tf is free
% thetarf = pi()/45;
% % Xf = 60;
% % Yf = 150;
% Xf = 20;
% Yf = 140;
% 
% %---------------------%
% %%% Variable Ranges %%%
% %---------------------%
% tfMin     =  0;     tfMax     = 100;
% xMin      =  -20;   xMax      = 180;
% yMin      =  0;     yMax      = 170;
% thetarMin = -pi();  thetarMax = pi();
% uMin      = -umax;  uMax      = umax;
% 
% %-------------------------------------------------------------------------%
% %---------------------- Provide Guess of Solution ------------------------%
% %-------------------------------------------------------------------------%
% u0 = 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
% Vertices of the square
xSq = [Xc(2)-r(2); Xc(2)+r(2); Xc(2)+r(2); Xc(2)-r(2)];
ySq = [Yc(2)-r(2); Yc(2)-r(2); Yc(2)+r(2); Yc(2)+r(2)];

areaRect = [3; 4; xMin; xMax; xMax; xMin; yMin; yMin; yMax; yMax];
obsRect = [3; 4; xSq; ySq];
obsCir = [1; Xc(1); Yc(1); r(1)+delta];
obsCir = [obsCir;zeros(length(obsRect) - length(obsCir),1)];
gd = [areaRect,obsRect,obsCir];
ns = char('areaRect','obsRect','obsCir');
ns = ns';
sf = 'areaRect-obsRect-obsCir';
dl = decsg(gd,sf,ns);

model = createpde;
geometryFromEdges(model,dl);
% mesh_default = generateMesh(model,'GeometricOrder','linear');
mesh_default = generateMesh(model,'GeometricOrder','linear','Hmax',15,'Hmin',3);

pointList = (mesh_default.Nodes)';
connList = (mesh_default.Elements(1:3,:))';
triKO = triangulation(connList,pointList);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S = [X0 Y0];
T = [Xf Yf];

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
S_idx = pointLocation(triKO,S);
T_idx = pointLocation(triKO,T);
dualVertices = inCenters;
dualVertices(S_idx,:) = S;
dualVertices(T_idx,:) = T;

% Generate the shortestpath in the dual.
G_dual_update = graph(s,t,edgeWeights(dualVertices(s,:),dualVertices(t,:)));
TR = shortestpath(G_dual_update,S_idx,T_idx);

% Generate the funnel
preFunnel = triangulation(triKO.ConnectivityList(TR,:),triKO.Points);
[~,sReplace] = setdiff(triKO.ConnectivityList(TR(1,1),:),triKO.ConnectivityList(TR(1,2),:));
[~,tReplace] = setdiff(triKO.ConnectivityList(TR(1,end),:),triKO.ConnectivityList(TR(1,end-1),:));
funnelPoints = triKO.Points;
funnelPoints(triKO.ConnectivityList(TR(1,1),sReplace),:) = S;
funnelPoints(triKO.ConnectivityList(TR(1,end),tReplace),:) = T;
funnel = triangulation(triKO.ConnectivityList(TR,:),funnelPoints);


x(:,1) = dualVertices(TR,1);
x(:,2) = dualVertices(TR,2);
x(:,3) = atan2(x(:,2),x(:,1))';
deltaT = zeros(length(x(:,1)),1);
for i = 2:length(x(:,1))
    deltaT(i,1) = sqrt((x(i,1)-x(i-1,1))^2+(x(i,2)-x(i-1,2))^2)/V;
end
tspan = cumsum(deltaT);

guess.phase.time     = tspan;
guess.phase.state    = x;
guess.phase.control  = u0*ones(size(tspan));
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure('color','w','Position', [200 80 500 350]);
triplot(triKO, 'LineWidth',1)
hold on
triplot(funnel,'Color','r','LineWidth',1);
% scatter(inCenters(:,1),inCenters(:,2),'.');
% plot(G_dual,'XData',inCenters(:,1),'YData',inCenters(:,2),'NodeLabel',{});
graphPlot = plot(G_dual,'XData',dualVertices(:,1),'YData',dualVertices(:,2),'NodeLabel',{});
highlight(graphPlot,TR,'EdgeColor','g','LineWidth',3);
% scatter(x(:,1),x(:,2));
daspect([1 1 1]);
xlabel('x');
ylabel('y');
xlim([xMin xMax]);
ylim([yMin yMax]);

%% %%%% Local Functions %%%%
function output = edgeWeights(startList,endList)
output = sqrt((startList(:,1)-endList(:,1)).^2 + (startList(:,2)-endList(:,2)).^2);
end