clear all;
close all;
clc;

addpath('PathPlanning');

rng default;

% Problem:
% Graph:
% s = [1 1 2 3 3 4 4 6 6 7 8 7 5]';
% t = [2 3 4 4 5 5 6 1 8 1 3 2 8]';
s = [1 1 2 3 3 4 4 6 6 7 9 7 5]';
t = [2 3 4 4 5 5 6 1 9 1 3 2 9]';
edgeCost = ones(size(s));
edgeResource = randi([2,10],size(s));
ResourceMax  = 30;

% Start and End Points
S_idx = 7;
T_idx = 9;

% SHORTEST PATH USING GRAPHS
% Using Graph and in-built Shortest Path Function (Djikstara)
tic
mesh_graph = digraph(s,t,edgeCost);
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
% [NodePath2,~] = dijkstra2(s,t,edgeCost,S_idx,T_idx);
% [NodePath2,~] = dijkstra_lite(s,t,edgeCost,S_idx,T_idx);
EdgePath2 = zeros(length(NodePath2)-1,1);
    for i = 1:length(NodePath2)-1
        EdgePath2(i,1) = find(s==NodePath2(i) & t==NodePath2(i+1));
    end
toc
Cost2  = sum(edgeCost(EdgePath2))
Const2 = sum(edgeResource(EdgePath2))

% % SHORTEST PATH USING MIXED INT PROGRAMMING WITH RESOURCE CONSTRAINT
% Using MILP
tic
[NodePath3,EdgePath3] = SPintprog(s,t,edgeCost,edgeResource,S_idx,T_idx,ResourceMax);
toc
Cost3  = sum(edgeCost(EdgePath3))
Const3 = sum(edgeResource(EdgePath3))

% Using LARAC Djikstra
tic
[NodePath4,EdgePath4] = LARAC_dijkstra(s,t,edgeCost,S_idx,T_idx,edgeResource,ResourceMax);
toc
Cost4  = sum(edgeCost(EdgePath4))
Const4 = sum(edgeResource(EdgePath4))

% Using LARAC Djikstra
tic
[NodePath4,EdgePath4] = LARAC_dijkstra_bin(s,t,edgeCost,S_idx,T_idx,edgeResource,ResourceMax);
toc
Cost4  = sum(edgeCost(EdgePath4))
Const4 = sum(edgeResource(EdgePath4))

% % Using LARAC Djikstra
% tic
% [NodePath4,EdgePath4] = LARAC_dijkstra_lite(s,t,edgeCost,S_idx,T_idx,edgeResource,ResourceMax);
% toc
% Cost4  = sum(edgeCost(EdgePath4))
% Const4 = sum(edgeResource(EdgePath4))
% 
% % Using LARAC Djikstra
% tic
% [NodePath4,EdgePath4] = LARAC_dijkstra_lite2(s,t,edgeCost,S_idx,T_idx,edgeResource,ResourceMax);
% toc
% Cost4  = sum(edgeCost(EdgePath4))
% Const4 = sum(edgeResource(EdgePath4))