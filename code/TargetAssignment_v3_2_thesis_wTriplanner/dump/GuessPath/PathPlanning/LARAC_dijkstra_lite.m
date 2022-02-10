function [NodePath,EdgePath] = LARAC_dijkstra_lite(s,t,edgeCost,source,target,edgeResource,ResourceMax)
% Standalong function for LARAC Dijkstra Algorithm for constrained shortest
% path
%
% Algo Source: https://cs.ou.edu/~thulasi/Misc/AKCE%20October%2025.pdf
%
% Improvements:
%   1. All basic Dijkstra sanity checks are performed in this function
%      earlier on to reduce redudant checks in the Dijkstra function.
%   2. The unconnected are re-indexed with new indices. This allows to skip
%      tracking of indices or repeated re-indexing in the Dijkstra
%      function.
%   3. Ideally integer for indices would reduce the memory requirements,
%      but the conversion takes significantly longer time. Hence,
%      conversion is dropped.
% 
% INPUTS:
%   s:
%       For the list of edges, s is the list of source/start nodes
%
%   t: 
%       For the list of edges, t is the list of taget nodes
%
%   edgeCost:
%       the weight or cost of each edge
%
%   source:
%       source/start node
%
%   target:
%       target node
%
%   edgeResource:
%       amount of resource spent in traversing each edge
%
%   ResourceMax:
%       maximum resource that can spent along the path
% 
% OUTPUTS:
%   NodePath:
%       ordered list of nodes defining the shortest path
%
%   EdgePath:
%       ordered list of edges defining the shortest path

% Make all inputs as vectors
if size(s,1) == 1
    s = s';
end

if size(t,1) == 1
    t = t';
end

if size(edgeCost,1) == 1
    edgeCost = edgeCost';
end

% Sanity Checks
% Check if the source and target are 1x1 scalars
if ~(size(source,1) == 1 && size(source,2) == 1)
    error('Source should be a 1x1 scalar.');
end

if ~(size(target,1) == 1 && size(target,2) == 1)
    error('Target should be a 1x1 scalar.');
end

% Check if source and target are present in the given set
if ~any(s==source)
    error('Invalid Source node! It is not present in the graph.');
end

% Check if source and target are present in the given set
if ~any(t==target)
    error('Invalid Target node! It is not present in the graph.');
end

% Check if the inputs are of same length
if length(s) == length(t) && length(s) == length(edgeCost)
    
    OrigNodeIDs = sort(unique([s;t]));
    totalNodes  = length(OrigNodeIDs);
    nodeID     = (1:totalNodes)';
    
    sNew        = arrayfun(@(i) find(OrigNodeIDs == s(i)),(1:length(s))');
    tNew        = arrayfun(@(i) find(OrigNodeIDs == t(i)),(1:length(s))');
    sourceNew   = find(OrigNodeIDs == source);
    targetNew   = find(OrigNodeIDs == target);
    
    [NodePathC,~] = dijkstra_kernel(totalNodes,sNew,tNew,edgeCost,sourceNew,targetNew);
    EdgePathC = zeros(length(NodePathC)-1,1);
    for i = 1:length(NodePathC)-1
        EdgePathC(i,1) = find(sNew==NodePathC(i) & tNew==NodePathC(i+1));
    end
    
    % Cost  = sum(edgeCost(EdgePath))
    ResourceC = sum(edgeResource(EdgePathC));
    
    if ResourceC <= ResourceMax
        NodePath = NodePathC;
        EdgePath = EdgePathC;
        return
    end
    
    [NodePathD,~] = dijkstra_kernel(totalNodes,sNew,tNew,edgeResource,sourceNew,targetNew);
    EdgePathD = zeros(length(NodePathD)-1,1);
    for i = 1:length(NodePathD)-1
        EdgePathD(i,1) = find(sNew==NodePathD(i) & tNew==NodePathD(i+1));
    end
    ResourceD = sum(edgeResource(EdgePathD));
    
    if ResourceD > ResourceMax
        NodePath = [];
        EdgePath = [];
        return
    else
        while true            
            CostC  = sum(edgeCost(EdgePathC));
            ResourceC = sum(edgeResource(EdgePathC));
            CostD  = sum(edgeCost(EdgePathD));
            ResourceD = sum(edgeResource(EdgePathD));
            
            L = (CostC - CostD)/(ResourceD - ResourceC);
            edgeCostL = edgeCost + L*edgeResource;
            
            [NodePathR,~] = dijkstra_kernel(totalNodes,sNew,tNew,edgeCostL,sourceNew,targetNew);
            EdgePathR = zeros(length(NodePathR)-1,1);
            for i = 1:length(NodePathR)-1
                EdgePathR(i,1) = find(sNew==NodePathR(i) & tNew==NodePathR(i+1));
            end
            
            CostLR  = sum(edgeCostL(EdgePathR));
            CostLC  = sum(edgeCostL(EdgePathC));
            ResourceR = sum(edgeResource(EdgePathR));
            
            if abs(CostLR - CostLC) < 1e-1 % CostLR == CostLC
                EdgePath = EdgePathD;
                break
            elseif ResourceR <= ResourceMax
                EdgePathD = EdgePathR;
            else
                EdgePathC = EdgePathR;
            end
        end
    end
    
    NodePath = [sNew(EdgePath);tNew(EdgePath(end))];
    
    NodePath = OrigNodeIDs(NodePath);
else
    error('Invalid inputs! The length of source and target nodes and edge cost should be equal.');
end
end