function [NodePath, cost] = dijkstra_kernel(totalNodes,sNew,tNew,edgeWeight,sourceNew,targetNew)
% Kernel for Dijkstra Shortest Path
%
% Note:
%   1. It cannot accept unconnected nodes. Hence recommended to be used
%      with the function dijkstra_lite();
%   2. Ideally integer for indices would reduce the memory requirements,
%      but the conversion takes significantly longer time. Hence,
%      conversion is dropped.
%   3. This function ties to minimize the use of find() and unique() which
%      consume significant execution time.
%
% INPUTS:
%   totalNodes:
%       total number of nodes in the graph
%
%   sNew:
%       For the list of edges, s is the list of source/start nodes
%
%   tNew: 
%       For the list of edges, t is the list of taget nodes
%
%   edgeWeight:
%       the weight or cost of each edge
%
%   sourceNew:
%       source/start node
%
%   targetNew:
%       target node
% 
% OUTPUTS:
%   NodePath:
%       ordered list of nodes defining the shortest path
%
%   cost:
%       cost of the shortest path

isVisited      = false(totalNodes,1);
pred           = -1*ones(totalNodes,1);
minArrivalCost = Inf*ones(totalNodes,1);

minArrivalCost(sourceNew) = 0;

while ~isVisited(targetNew)
    nodesNotVisited       = find(~isVisited);
    [~,minIndex]          = min(minArrivalCost(nodesNotVisited,1));
    sNodeIndex            = nodesNotVisited(minIndex);
    isVisited(sNodeIndex) = true;
    
    tNodeIndices = tNew(sNew == sNodeIndex,1);
    tCost        = edgeWeight(sNew == sNodeIndex,1);
    
    if ~isempty(tNodeIndices)
        for j = 1:length(tNodeIndices)
            jNodeIndex = tNodeIndices(j);
            if minArrivalCost(jNodeIndex) > minArrivalCost(sNodeIndex) + tCost(j)
                minArrivalCost(jNodeIndex) = minArrivalCost(sNodeIndex) + tCost(j);
                pred(jNodeIndex) = sNodeIndex;
            end
        end
    end
end

cost = minArrivalCost(targetNew);

NodePath = targetNew;
while NodePath(end,1) ~= sourceNew
    NodePath = [NodePath; pred(NodePath(end,1))];
end
NodePath = flipud(NodePath);
end