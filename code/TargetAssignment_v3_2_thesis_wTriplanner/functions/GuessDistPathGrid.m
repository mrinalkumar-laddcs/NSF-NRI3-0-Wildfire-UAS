function [dist,path] = GuessDistPathGrid(sXY,tXY,agentSpeed,env,PlannerType)
tic

node = env.const.nodes;
edge = env.const.edges;
polygonSize = env.const.polySize;

% Choose the grid resolution
grid_step = 50;

% Generate a mesh grid and the find the number nodes along row and column
[X_grid, Y_grid] = meshgrid([env.dom.xMin:grid_step:env.dom.xMax],[env.dom.yMin:grid_step:env.dom.yMax]);
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
    
    % Exclude Hard Constraints for Obstacle Avoidance
    if size(polygonSize,1) ~= 0
        node_struct(i).out = PointPolyTest(node,edge,polygonSize,node_struct(i).loc(1,1),node_struct(i).loc(1,2));
    else
        node_struct(i).out = 1;
    end
    
    node_struct(i).heatflux = interp2(env.heatflux.X,env.heatflux.Y,env.heatflux.hfmean,node_struct(i).loc(1,1),node_struct(i).loc(1,2));

    % if Planner == 2 ...      % Obstacle Avoidance without Heat
    % Do Nothing
    if PlannerType == 3        % Obstacle Avoidance with Heat Threshold
        if node_struct(i).heatflux < env.heatflux.thresh
            node_struct(i).out = 1;
        else
            node_struct(i).out = 0;            
        end
    elseif PlannerType == 4    % Obstacle Avoidance with Temp Limits
        if node_struct(i).heatflux < 0
            node_struct(i).heatflux = 0;
        end
    end
    inout_grid(node_struct(i).sub(1,1),node_struct(i).sub(1,2)) = node_struct(i).out;
    node_struct(i).v = agentSpeed;
end
toc

tic
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
edgeDist = [];
edgeDeltaTemp = [];
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
                        
                        edgeLen  = edgeWeights(node_struct(i),node_struct(sub2ind([nR,nC],p,q)));
                        edgeDist = [edgeDist; edgeLen];
                        
                        % heatflux is provided in kW/m^2
                        Area = 0.25;     % m^2
                        Mass = 3;        % kg
                        specHeatCap = 2; % kJ/kg/K
                        deltaTemp = (node_struct(i).heatflux*Area*edgeLen/agentSpeed)/(Mass*specHeatCap);
                        edgeDeltaTemp = [edgeDeltaTemp; deltaTemp];
                    end
                end
            end
        end
    end
end
toc

MaxTempGain = 20;

% Find the shortest path
tic
if PlannerType == 2 ... % Obstacle Avoidance without Heat
   || PlannerType == 3  % Obstacle Avoidance with Heat Threshold
    % Create a directional graph
    % CAUTION: the edgepath output of the shortest path does necessarily use
    % the edge order used to define the graph at the first place.
    % Generally easier to find nodepath from edgepath but not the opposite!
    mesh_graph = digraph(s,t,edgeDist);
    [NodePath,~,EdgePath] = shortestpath(mesh_graph,S_idx,T_idx);
    EdgePath = zeros(1,length(NodePath)-1);
    for i = 1:length(NodePath)-1
        EdgePath(1,i) = find(s==NodePath(i) & t==NodePath(i+1));
    end
elseif PlannerType == 4     % Obstacle Avoidance with Temp Limits
%     [NodePath, EdgePath]  = SPintprog(s,t,edgeDist,edgeDeltaTemp,S_idx,T_idx,MaxTempGain);
    [NodePath, EdgePath]  = LARAC_dijkstra(s,t,edgeDist,S_idx,T_idx,edgeDeltaTemp,MaxTempGain);
end
toc

dist = sum(edgeDist(EdgePath'));
path = reshape([node_struct(NodePath).loc],[2,length(NodePath)])';
TempGain = sum(edgeDeltaTemp(EdgePath'));
end

%% %%%% Local Functions %%%%
function dist = edgeWeights(startNode,endNode)
dist = sqrt((startNode.loc(:,1)-endNode.loc(:,1)).^2 + (startNode.loc(:,2)-endNode.loc(:,2)).^2);
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