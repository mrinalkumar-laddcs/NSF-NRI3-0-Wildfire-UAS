function [NodePath, cost] = dijkstra_new(s,t,edgeWeight,source,target)
% Standalone function for Dijkstra Shortest Path
%
% INPUTS:
%   s:
%       For the list of edges, s is the list of source/start nodes
%
%   t: 
%       For the list of edges, t is the list of taget nodes
%
%   edgeWeight:
%       the weight or cost of each edge
%
%   source:
%       source/start node
%
%   target:
%       target node
% 
% OUTPUTS:
%   NodePath:
%       ordered list of nodes defining the shortest path
%
%   cost:
%       cost of the shortest path
%
% Note:
%   1. It can accept unconnected nodes
%   2. It checks the order number of the original node indices while 
%      iterating. This was taken care by replacing the node indices
%      altogether in dijkstra_lite().

% Make all inputs as vectors
if size(s,1) == 1
    s = s';
end

if size(t,1) == 1
    t = t';
end

if size(edgeWeight,1) == 1
    edgeWeight = edgeWeight';
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
if length(s) == length(t) && length(s) == length(edgeWeight)
    
    nodeID     = sort(unique([s;t]));
    totalNodes = length(nodeID);
    
    isVisited      = false(totalNodes,1);
    predecessor    = -1*ones(totalNodes,1);
    minArrivalCost = Inf*ones(totalNodes,1);
    priorityCost   = Inf*ones(totalNodes,1);
    
    sNodeIndex                 = find(nodeID == source);
    tNodeIndex                 = find(nodeID == target);
    minArrivalCost(sNodeIndex) = 0;
    priorityCost(sNodeIndex)   = 0;
    
    while any(~isVisited)
        
        nodesNotVisited       = find(~isVisited);
        [~,priorityIndex]     = min(priorityCost(nodesNotVisited,1));
        sNodeIndex            = nodesNotVisited(priorityIndex);
        
        if sNodeIndex == tNodeIndex
            break
        end
        
        isVisited(sNodeIndex) = true;
        
        tEdgeIndices = s == nodeID(sNodeIndex);
        tNodeIndices = t(tEdgeIndices,1);
        tCost        = edgeWeight(tEdgeIndices,1);

        if any(tEdgeIndices)
            for j = 1:length(tNodeIndices)
                jNodeIndex = find(nodeID == tNodeIndices(j));
                newArrivalCost = minArrivalCost(sNodeIndex) + tCost(j);
                if minArrivalCost(jNodeIndex) > newArrivalCost
                    minArrivalCost(jNodeIndex) = newArrivalCost;
                    priorityCost(jNodeIndex) = newArrivalCost;
                    predecessor(jNodeIndex) = sNodeIndex;
                end
            end
        end
    end
    
    cost = minArrivalCost(tNodeIndex);
    
    sNodeIndex = find(nodeID == source);
    NodePath = tNodeIndex;
    while NodePath(end,1) ~= sNodeIndex 
        NodePath = [NodePath; predecessor(NodePath(end,1))];
    end
    NodePath = nodeID(flipud(NodePath));
else
    error('Invalid inputs! The length of source and target nodes and edge cost should be equal.');
end

end