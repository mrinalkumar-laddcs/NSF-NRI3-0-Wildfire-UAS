function [status,path] = TriMesh(obs,domain,startPoint,finalPoint)

node = [];
edge = [];
for i = 1:size(obs,2)
    obs(i).polySize = size(obs(i).polygon,1);
    edge = [edge; size(node,1)+[(1:(obs(i).polySize-1))' (2:obs(i).polySize)'; obs(i).polySize 1]];
    node = [node; obs(i).polygon];
end

% Domain
xMin = domain(1,1);
xMax = domain(1,3);
yMin = domain(1,2);
yMax = domain(1,4);
boundRectXY = [xMin yMin; xMax yMin; xMax yMax; xMin yMax]; % coordinates of Bounding Box
boundEdges = [(1:3)' (2:4)'; 4 1];

% Trigulation Process
nodeList = [boundRectXY; node];
edgeList = [boundEdges; size(boundRectXY,1)+edge];
opts.kind = 'delaunay';
opts.rho2 = +1.0;
[vert,etri,tria,tnum] = refine2(nodeList,edgeList,[],opts); % triangulation mesh
% [vert,etri,tria,tnum] = smooth2(vert,etri,tria,tnum);       % optimization of mesh for smoothness
% [vnew,enew,tnew,tnum] = tridiv2(vert,etri,tria,tnum);       % mesh division
% [vert,etri,tria,tnum] = smooth2(vnew,enew,tnew,tnum);       % optimization of mesh for smoothness
% [vnew,enew,tnew,tnum] = tridiv2(vert,etri,tria,tnum);       % mesh division
% [vert,etri,tria,tnum] = smooth2(vnew,enew,tnew,tnum);       % optimization of mesh for smoothness
triKO = triangulation(tria,vert);                   % triangulation object
edgeList = edges(triKO);

% % Generate Dual of Delaunay Triangulation
% inCenters = incenter(triKO);
% edgeTable_cell = edgeAttachments(triKO,edgeList(:,1),edgeList(:,2));
% edgeTable_mat = cell2mat(edgeTable_cell(cellfun('size',edgeTable_cell,2)==2));
% s = edgeTable_mat(:,1);
% t = edgeTable_mat(:,2);
% 
% % Replace the incenter by the start and end point and update the dual
% S_idx = pointLocation(triKO,startPoint);
% T_idx = pointLocation(triKO,finalPoint);
% dualVertices = inCenters;
% dualVertices(S_idx,:) = startPoint;
% dualVertices(T_idx,:) = finalPoint;
% 
% % Generate the shortestpath in the dual.
% G_dual_update = graph(s,t,edgeWeights(dualVertices(s,:),dualVertices(t,:)));
% TR = shortestpath(G_dual_update,S_idx,T_idx);
% 
% % Generate the funnel
% % preFunnel = triangulation(triKO.ConnectivityList(TR,:),triKO.Points);
% [~,sReplace] = setdiff(triKO.ConnectivityList(TR(1,1),:),triKO.ConnectivityList(TR(1,2),:));
% [~,tReplace] = setdiff(triKO.ConnectivityList(TR(1,end),:),triKO.ConnectivityList(TR(1,end-1),:));
% funnelPoints = triKO.Points;
% funnelPoints(triKO.ConnectivityList(TR(1,1),sReplace),:) = startPoint;
% funnelPoints(triKO.ConnectivityList(TR(1,end),tReplace),:) = finalPoint;
% funnel = triangulation(triKO.ConnectivityList(TR,:),funnelPoints);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate Plots
figure('color','w','Position', [200 80 500 350]);
patch('faces',tria(:,1:3),'vertices',vert, ...
    'FaceColor','w', ...
    'EdgeAlpha',0.3, ...
    'EdgeColor',[.2,.2,.2]) ;
hold on; 
% triplot(funnel,'Color','b','LineWidth',0.5);
% plot(dualVertices(TR,1),dualVertices(TR,2),'-r','LineWidth',1);
% patch('faces',edge(:,1:2),'vertices',node, ...
%     'FaceColor','w', ...
%     'EdgeColor',[.1,.1,.1], ...
%     'LineWidth',1.5) ;
xlabel('X');
ylabel('Y');
% xlim([boundRectXY(1,1) boundRectXY(2,1)]);
% ylim([boundRectXY(1,2) boundRectXY(3,2)]);
% daspect([1 1 1]);
box on

% % Return Outputs
% polyNodes = node;
% polyEdges = edge;
% polySize = polygonSize;
% startPt = startPoint;
% finalPt = finalPoint;
% bound = boundRectXY;
% guessGen.x = dualVertices(TR,1);
% guessGen.y = dualVertices(TR,2);

guessGen.x = 0;
guessGen.y = 0;

status = 0;
path = 0;

end