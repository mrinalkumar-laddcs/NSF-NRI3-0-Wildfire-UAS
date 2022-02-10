function [NodePath, cost] = dijkstra_kernel2(totalNodes,sNew,tNew,edgeWeight,sourceNew,targetNew)
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

error('dijkstra_kernel2() is still buggy. Proceed at own risk by commenting this statement.');
% The loop does not exit properly

pred           = -1*ones(totalNodes,1);

% costMap = containers.Map('KeyType','uint32','ValueType','double');
costMap = containers.Map(sourceNew,0);

while true
    [~,minIndex]          = min(cell2mat(values(costMap)));
    keySet                = keys(costMap);
    sNodeIndex            = keySet{minIndex};
    
    if sNodeIndex == targetNew
        break
    end
    
    tNodeIndices = tNew(sNew == sNodeIndex,1);
    tCost        = edgeWeight(sNew == sNodeIndex,1);
    
    if ~isempty(tNodeIndices)
        for j = 1:length(tNodeIndices)
            jNodeIndex = tNodeIndices(j);
            if isKey(costMap,jNodeIndex)
                if cell2mat(values(costMap,{jNodeIndex})) > cell2mat(values(costMap,{sNodeIndex})) + tCost(j)
                    costMap(jNodeIndex) = cell2mat(values(costMap,{sNodeIndex})) + tCost(j);
                    pred(jNodeIndex) = sNodeIndex;
                end
            else
                costMap(jNodeIndex) = cell2mat(values(costMap,{sNodeIndex})) + tCost(j);
                pred(jNodeIndex) = sNodeIndex;
            end
        end
    end
    remove(costMap,{sNodeIndex});
    if any(cell2mat(keys(costMap)) == targetNew)
        break
    end
    
end

cost = cell2mat(values(costMap,{targetNew}));

NodePath = targetNew;
while NodePath(end,1) ~= sourceNew
    NodePath = [NodePath; pred(NodePath(end,1))];
end
NodePath = flipud(NodePath);
end