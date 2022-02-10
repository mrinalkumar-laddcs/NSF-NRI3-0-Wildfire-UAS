function [grid_mesh,guessGen,dist] = GuessPathGrid(node,edge,polygonSize,agent,domain,sXY,tXY,heatFlux,plannerType)
tic
% Three types of Planner:
% 'naive'       : ignores heat flux, still uses grid based shortest path approach
% 'temp-const'  : uses heat flux to compute temperature gain and cooling
% 'hf-threshold': uses heat flux threshold to determine safe/unsafe regions

% heatFluxData.thresh = 7;

% Choose the grid resolution
grid_step = 50;

% Generate a mesh grid and the find the number nodes along row and column
[X_grid, Y_grid] = meshgrid([domain.xMin:grid_step:domain.xMax],[domain.yMin:grid_step:domain.yMax]);
[nR,nC] = size(X_grid);
tot_nodes = nR*nC;
inout_grid = ones(nR,nC);

% Create an empty structure for nodes
node_struct = struct('ind',{},'sub',{},'loc',{},'out',{},'heatflux',{});

% Populate the node properties
for i=1:tot_nodes
    node_struct(i).ind = i;
    [node_struct(i).sub(1,1), node_struct(i).sub(1,2)] = ind2sub([nR,nC],i);
    node_struct(i).loc = [X_grid(1,node_struct(i).sub(1,2)),Y_grid(node_struct(i).sub(1,1),1)];
    
    if size(polygonSize,1) ~= 0
        node_struct(i).out = PointPolyTest(node,edge,polygonSize,node_struct(i).loc(1,1),node_struct(i).loc(1,2));
    else
        node_struct(i).out = 1;
    end
    
    node_struct(i).heatflux = interp2(heatFlux.X,heatFlux.Y,heatFlux.hfmean,node_struct(i).loc(1,1),node_struct(i).loc(1,2));
%     if node_struct(i).heatflux < 0
%         node_struct(i).heatflux = 0;
%     end
    if strcmp(plannerType,'hf-threshold') || strcmp(plannerType,'hf-threshold2')...
            || strcmp(plannerType,'hf-threshold3') || strcmp(plannerType,'hf-threshold4')
        if node_struct(i).heatflux < heatFlux.thresh
            node_struct(i).out = 1;
        else
            node_struct(i).out = 0;            
        end
    end
    
    inout_grid(node_struct(i).sub(1,1),node_struct(i).sub(1,2)) = node_struct(i).out;
    node_struct(i).v = agent.speed;
end

% Identify the nearest node to the START and FINAL locations
[~,S_idx] = min(pdist2(reshape([node_struct.loc],[2,tot_nodes])',sXY,'euclidean'));
[~,T_idx] = min(pdist2(reshape([node_struct.loc],[2,tot_nodes])',tXY,'euclidean'));

% Replace the location values in the node by the START and FINAL locations
node_struct(S_idx).loc = sXY;
node_struct(T_idx).loc = tXY;

% Identify the connecting edges in the 5x5 neighborhood grid create a
% node connectivity and edge weight list
%
% I: identify the useful 16 nodes in the 5x5 grid
search_nodes = [];
nRmin = - 2;
nCmin = - 2;
nRmax = + 2;
nCmax = + 2;
for j = nRmin:nRmax
    for k = nCmin:nCmax
        if (abs(j)==abs(k) && abs(j)+abs(k)==2) || (abs(j)+abs(k)==1) || (abs(j)+abs(k)==3)          
%         if ~(abs(j)+abs(k)==0)
            search_nodes = [search_nodes; j,k];
        end
    end
end

% II: Use those 16 neighbor nodes and compute those edge weights
s = [];
t = [];
edgeTime = [];
edgeTempGain = [];
for i=1:tot_nodes
    % i                  : start node index
    % node_struct(i).sub : start node subscript
    % [p,q]              : end node subscript
    if node_struct(i).out == 1 % check if the start node is outside the polygons
        
        for j = 1:size(search_nodes,1)
            p = node_struct(i).sub(1,1) + search_nodes(j,1);
            q = node_struct(i).sub(1,2) + search_nodes(j,2);
            if p>=1 && p<=nR % check for boundary cases
                if q>=1 && q<=nC % check for boundary cases
                    if node_struct(sub2ind([nR,nC],p,q)).out == 1
                        s = [s; i];
                        t = [t; sub2ind([nR,nC],p,q)];
                        edgeTime = [edgeTime; edgeWeights(node_struct(i),node_struct(sub2ind([nR,nC],p,q)))];
                        edgeTempGain = [edgeTempGain; mean([node_struct(i).heatflux,node_struct(sub2ind([nR,nC],p,q)).heatflux])/(edgeWeights(node_struct(i),node_struct(sub2ind([nR,nC],p,q))))];
                    end
                end
            end
        end
    end
end
toc

TempMax = 20;

% Create a directional graph
mesh_graph = digraph(s,t,edgeTime);
% Find the shortest path
if strcmp(plannerType,'naive')
    tic
    [NodePath,~,~] = shortestpath(mesh_graph,S_idx,T_idx);
    NodePath = NodePath';
    EdgePath = zeros(length(NodePath)-1,1);
    for i = 1:length(NodePath)-1
        EdgePath(i,1) = find(s==NodePath(i) & t==NodePath(i+1));
    end
    toc
elseif strcmp(plannerType,'naive2')
    tic
    [NodePath,~] = dijkstra(s,t,edgeTime,S_idx,T_idx);
    EdgePath = zeros(length(NodePath)-1,1);
    for i = 1:length(NodePath)-1
        EdgePath(i,1) = find(s==NodePath(i) & t==NodePath(i+1));
    end
    toc
elseif strcmp(plannerType,'hf-threshold')
    tic
    [NodePath,~,~] = shortestpath(mesh_graph,S_idx,T_idx);
    NodePath = NodePath';
    EdgePath = zeros(length(NodePath)-1,1);
    for i = 1:length(NodePath)-1
        EdgePath(i,1) = find(s==NodePath(i) & t==NodePath(i+1));
    end
    toc
elseif strcmp(plannerType,'hf-threshold2')
    tic
    [NodePath,~] = dijkstra_new(s,t,edgeTime,S_idx,T_idx);
    EdgePath = zeros(length(NodePath)-1,1);
    for i = 1:length(NodePath)-1
        EdgePath(i,1) = find(s==NodePath(i) & t==NodePath(i+1));
    end
    toc
elseif strcmp(plannerType,'hf-threshold3')
    tic
    A = adjacency(mesh_graph);
    CostMat = adjacency(mesh_graph,'weighted')*agent.speed;
    NodeCoords = reshape([node_struct(:).loc],[2,length(node_struct)])';
    [NodePath,~] = bfsearch(A,CostMat,NodeCoords,S_idx,T_idx);
    EdgePath = zeros(length(NodePath)-1,1);
    for i = 1:length(NodePath)-1
        EdgePath(i,1) = find(s==NodePath(i) & t==NodePath(i+1));
    end
    toc
elseif strcmp(plannerType,'hf-threshold4')
    tic
    A = adjacency(mesh_graph);
    CostMat = adjacency(mesh_graph,'weighted')*agent.speed;
    NodeCoords = reshape([node_struct(:).loc],[2,length(node_struct)])';
    [NodePath,~] = astar(A,CostMat,NodeCoords,S_idx,T_idx);
    EdgePath = zeros(length(NodePath)-1,1);
    for i = 1:length(NodePath)-1
        EdgePath(i,1) = find(s==NodePath(i) & t==NodePath(i+1));
    end
    toc
elseif strcmp(plannerType,'temp-const')
    tic
    [NodePath, EdgePath] = SPintprog(s,t,edgeTime,edgeTempGain,S_idx,T_idx,TempMax);
    toc
elseif strcmp(plannerType,'temp-const2')
    tic
    [NodePath, EdgePath] = LARAC_dijkstra(s,t,edgeTime,S_idx,T_idx,edgeTempGain,TempMax);
    toc
elseif strcmp(plannerType,'temp-const3')
    tic
    [NodePath, EdgePath] = LARAC_dijkstra_bin(s,t,edgeTime,S_idx,T_idx,edgeTempGain,TempMax);
    toc
end
path = reshape([node_struct(NodePath).loc],[2,length(NodePath)])';
grid_mesh.xgrid = X_grid;
grid_mesh.ygrid = Y_grid;
grid_mesh.inout = inout_grid;
guessGen.x = path(:,1);
guessGen.y = path(:,2);
dist = sum(edgeTime(EdgePath'))*agent.speed;
resource_consumed = sum(edgeTempGain(EdgePath'));
disp(['Planner Type: ',plannerType,';    Path Computation Complete!']);
disp(['Distance = ',num2str(dist),'m; Temp Gain = ',num2str(resource_consumed),'C']);
disp(' ');
disp(' ');

% COMPARE Shortest Path and IntLinProg,
% THEN add the heat constraint
% [NodePath2, EdgePath2] = SPintprog(s,t,edgeTime,edgeTempGain,S_idx,T_idx,TempMax);
% path2 = reshape([node_struct(NodePath2).loc],[2,length(NodePath2)])';
% guessGen2.x = path2(:,1);
% guessGen2.y = path2(:,2);
% dist2 = sum(edgeTime(EdgePath2'))*agent.speed;
end

%% %%%% Local Functions %%%%
function deltaT = edgeWeights(startNode,endNode)
deltaT = sqrt((startNode.loc(:,1)-endNode.loc(:,1)).^2 + (startNode.loc(:,2)-endNode.loc(:,2)).^2)/mean([startNode.v, endNode.v]);
end

function out = PointPolyTest(nodesN,edgesN,polySizeN,X,Y)
edgeCon = -((repmat(X,1,size(edgesN,1))...
    -repmat(nodesN(edgesN(:,1),1)',size(X,1),1)).*(repmat(nodesN(edgesN(:,2),2)',size(X,1),1)...
    -repmat(nodesN(edgesN(:,1),2)',size(X,1),1))...
    - (repmat(Y,1,size(edgesN,1))...
    -repmat(nodesN(edgesN(:,1),2)',size(Y,1),1)).*(repmat(nodesN(edgesN(:,2),1)',size(X,1),1)...
    -repmat(nodesN(edgesN(:,1),1)',size(X,1),1)));

ctr = 0;
for i = 1:size(polySizeN,1)
    constraint(:,i) = min(edgeCon(:,ctr+(1:polySizeN(i))),[],2);
    ctr = sum(polySizeN(1:i));
end

for j = 1:size(constraint,1)
    if any(constraint(j,:) > 0)
        out(j,1) = 0;
    else
        out(j,1) = 1;
    end
end
end