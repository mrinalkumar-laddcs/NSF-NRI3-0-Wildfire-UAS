function [NodePath,EdgePath] = LARAC_dijkstra(s,t,edgeCost,source,target,edgeResource,ResourceMax)
% Standalong function for LARAC Dijkstra Algorithm for constrained shortest
% path
%
% Algo Source: https://cs.ou.edu/~thulasi/Misc/AKCE%20October%2025.pdf
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

[NodePathC,~] = dijkstra(s,t,edgeCost,source,target);
EdgePathC = zeros(length(NodePathC)-1,1);
    for i = 1:length(NodePathC)-1
        EdgePathC(i,1) = find(s==NodePathC(i) & t==NodePathC(i+1));
    end
    
CostC     = sum(edgeCost(EdgePathC));
ResourceC = sum(edgeResource(EdgePathC));

if ResourceC <= ResourceMax
    NodePath = NodePathC;
    EdgePath = EdgePathC;
    return
end

[NodePathD,~] = dijkstra(s,t,edgeResource,source,target);
EdgePathD = zeros(length(NodePathD)-1,1);
    for i = 1:length(NodePathD)-1
        EdgePathD(i,1) = find(s==NodePathD(i) & t==NodePathD(i+1));
    end
CostD     = sum(edgeCost(EdgePathD));
ResourceD = sum(edgeResource(EdgePathD));

if ResourceD > ResourceMax
    NodePath = [];
    EdgePath = [];
    return
elseif (ResourceMax-ResourceD > 0 && ResourceMax-ResourceD < 1e-2) || abs(CostC - CostD) < 1e-1
    EdgePath = EdgePathD;
else
    LB = 0;
    LU = (CostD - CostC)/(ResourceMax - ResourceD);
    iter = 1;
    while (LU-LB)*(ResourceMax - ResourceD) > 1e-1       
        L = (LB+LU)/2;
%         CostC  = sum(edgeCost(EdgePathC));
%         ResourceC = sum(edgeResource(EdgePathC));
%         CostD  = sum(edgeCost(EdgePathD));
%         ResourceD = sum(edgeResource(EdgePathD));
        
%         L = (CostC - CostD)/(ResourceD - ResourceC);
        edgeCostL = edgeCost + L*edgeResource;
        
        [NodePathR,~] = dijkstra(s,t,edgeCostL,source,target);
        EdgePathR = zeros(length(NodePathR)-1,1);
        for i = 1:length(NodePathR)-1
            EdgePathR(i,1) = find(s==NodePathR(i) & t==NodePathR(i+1));
        end
        
%         CostLR  = sum(edgeCostL(EdgePathR));
%         CostLC  = sum(edgeCostL(EdgePathC));
        ResourceR = sum(edgeResource(EdgePathR));
        
        if (ResourceMax-ResourceD > 0 && ResourceMax-ResourceD < 1e-2)
            EdgePath = EdgePathR;
            break
        elseif ResourceR <= ResourceMax
            LU = L;
%             EdgePathD = EdgePathR;
        else 
            LB = L;
%             EdgePathC = EdgePathR;
        end
        iter = iter + 1;
    end
    edgeCostL = edgeCost + LU*edgeResource;
    [NodePath,~] = dijkstra(s,t,edgeCostL,source,target);
    EdgePath = zeros(length(NodePath)-1,1);
    for i = 1:length(NodePath)-1
        EdgePath(i,1) = find(s==NodePath(i) & t==NodePath(i+1));
    end
    
    disp(['Number of iterations: ',num2str(iter)]);
end
NodePath = [s(EdgePath);t(EdgePath(end))];
end