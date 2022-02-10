function [NodePath, cost] = dijkstra_wrapper(totalNodes,sNew,tNew,edgeWeight,sourceNew,targetNew)
% Wrapper for directing the Dijkstra Shortest path solution process to
% either in-built function or the custom function.
%
% INPUTS:
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


% Uncomment lines below to use in-built Dijkstra
%--------%
% mesh_graph = digraph(sNew,tNew,edgeWeight);
% [NodePath,cost,~] = shortestpath(mesh_graph,sourceNew,targetNew);
% NodePath = NodePath';
% return
%--------%

% Uncomment lines below to try custom Djikstra
%--------%
[NodePath, cost] = dijkstra_kernel(totalNodes,sNew,tNew,edgeWeight,sourceNew,targetNew);
%--------%
end