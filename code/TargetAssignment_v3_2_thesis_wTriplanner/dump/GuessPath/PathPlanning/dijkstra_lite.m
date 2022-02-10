function [NodePath, cost] = dijkstra_lite(s,t,edgeWeight,source,target)
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
%   2. Ideally integer for indices would reduce the memory requirements,
%      but the conversion takes significantly longer time. Hence,
%      conversion is dropped.

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
    
    OrigNodeIDs = sort(unique([s;t]));
    totalNodes  = length(OrigNodeIDs);
    nodeID     = (1:totalNodes)';
    
    sNew        = arrayfun(@(i) find(OrigNodeIDs == s(i)),(1:length(s))');
    tNew        = arrayfun(@(i) find(OrigNodeIDs == t(i)),(1:length(s))');
    sourceNew   = find(OrigNodeIDs == source);
    targetNew   = find(OrigNodeIDs == target);
    
    [NodePath, cost] = dijkstra_kernel(totalNodes,sNew,tNew,edgeWeight,sourceNew,targetNew);
    
    NodePath = OrigNodeIDs(NodePath);
else
    error('Invalid inputs! The length of source and target nodes and edge cost should be equal.');
end
end