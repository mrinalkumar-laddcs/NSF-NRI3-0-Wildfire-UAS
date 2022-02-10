clear all;
close all;
clc;

addpath('PathPlanning');

% Problem:
% Graph:
s            = [1, 1, 1, 2, 2, 2, 2, 3, 3, 4, 5]';
t            = [2, 4, 5, 3, 4, 5, 6, 5, 6, 5, 6]';
% edgeCost     = [1, 10, 1, 2, 1, 5, 12, 10, 1, 2]';
edgeResource = [10,3, 1, 3, 2, 7, 3,  1, 7, 2, 1]';
ResourceMax  = 10;

NodeCoords = [0, 0;
              1, 0;
              2, 0;
              0, 1;
              1, 1;
              2, 1];

edgeCost = zeros(size(s));
for i = 1:size(s,1)
    edgeCost(i,1) = pdist2(NodeCoords(s(i),:),NodeCoords(t(i),:));
end

% Start and End Points
S_idx = 1;
T_idx = 6;

% SHORTEST PATH USING GRAPHS
% Using Graph and in-built Shortest Path Function (Djikstara)
mesh_graph = digraph(s,t,edgeCost);
tic
[NodePath1,~,~] = shortestpath(mesh_graph,S_idx,T_idx);
NodePath1 = NodePath1';
EdgePath1 = zeros(length(NodePath1)-1,1);
    for i = 1:length(NodePath1)-1
        EdgePath1(i,1) = find(s==NodePath1(i) & t==NodePath1(i+1));
    end
toc
Cost1  = sum(edgeCost(EdgePath1))
Const1 = sum(edgeResource(EdgePath1))

% Using Graph and user-defined Shortest Path Function (Djikstara)
tic
[NodePath2,~] = dijkstra(s,t,edgeCost,S_idx,T_idx);
EdgePath2 = zeros(length(NodePath2)-1,1);
    for i = 1:length(NodePath2)-1
        EdgePath2(i,1) = find(s==NodePath2(i) & t==NodePath2(i+1));
    end
toc
Cost2  = sum(edgeCost(EdgePath2))
Const2 = sum(edgeResource(EdgePath2))

% Using Graph and user-defined Shortest Path Function (Djikstara)
tic
[NodePath2,~] = dijkstra_new(s,t,edgeCost,S_idx,T_idx);
EdgePath2 = zeros(length(NodePath2)-1,1);
    for i = 1:length(NodePath2)-1
        EdgePath2(i,1) = find(s==NodePath2(i) & t==NodePath2(i+1));
    end
toc
Cost2  = sum(edgeCost(EdgePath2))
Const2 = sum(edgeResource(EdgePath2))

% Using Graph and user-defined Shortest Path Function (Djikstara)
% tic
G = digraph(s,t,edgeCost);
A = adjacency(G);
CostMat = adjacency(G,'weighted');
tic
[NodePath2,~] = astar(A,CostMat,NodeCoords,S_idx,T_idx);
EdgePath2 = zeros(length(NodePath2)-1,1);
    for i = 1:length(NodePath2)-1
        EdgePath2(i,1) = find(s==NodePath2(i) & t==NodePath2(i+1));
    end
toc
Cost2  = sum(edgeCost(EdgePath2))
Const2 = sum(edgeResource(EdgePath2))

% Using Graph and user-defined Shortest Path Function (Djikstara)
% tic
G = digraph(s,t,edgeCost);
A = adjacency(G);
CostMat = adjacency(G,'weighted');
tic
[NodePath2,~] = bfsearch(A,CostMat,NodeCoords,S_idx,T_idx);
EdgePath2 = zeros(length(NodePath2)-1,1);
    for i = 1:length(NodePath2)-1
        EdgePath2(i,1) = find(s==NodePath2(i) & t==NodePath2(i+1));
    end
toc
Cost2  = sum(edgeCost(EdgePath2))
Const2 = sum(edgeResource(EdgePath2))

% % SHORTEST PATH USING MIXED INT PROGRAMMING WITH RESOURCE CONSTRAINT
% % Using MILP
% tic
% [NodePath3,EdgePath3] = SPintprog(s,t,edgeCost,edgeResource,S_idx,T_idx,ResourceMax);
% toc
% Cost3  = sum(edgeCost(EdgePath3))
% Const3 = sum(edgeResource(EdgePath3))
% 
% % Using LARAC Djikstra
% tic
% [NodePath4,EdgePath4] = LARAC_dijkstra(s,t,edgeCost,S_idx,T_idx,edgeResource,ResourceMax);
% toc
% Cost4  = sum(edgeCost(EdgePath4))
% Const4 = sum(edgeResource(EdgePath4))