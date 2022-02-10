function [nodeList,edgeList] = SPintprog(s,t,edgeCost,edgeResource,S_idx,T_idx,ResourceMax)
% Optimization Problem:
% min \sum c_ij x_ij
%
% subject to:
% 
% \sum x_sj = 1             (one path from source) C1
% \sum x_it = 1             (one path to sink)     C2
% \sum x_ij - \sum x_ji = 0 (conservation)         C3

%
% \sum t_ij x_ij <= threshold

% Objective Function
% min c'*x
c = edgeCost;

%Constraints
nVars = length(edgeCost);
% Aeq*x == beq
% C1:
A1 = zeros(1,nVars);
A1(s==S_idx) = 1;

% C2:
A2 = zeros(1,nVars);
A2(t==T_idx) = 1;

% C3:
all_nodes = unique([s;t]);
inter_nodes = all_nodes(all_nodes~=S_idx & all_nodes~=T_idx);
A3 = zeros(size(inter_nodes,1),nVars);
for i=1:size(inter_nodes)
    A3(i,(s==inter_nodes(i) & t~=S_idx)') = 1;
    A3(i,(t==inter_nodes(i) & s~=T_idx)') = -1;
end

Aeq = [A1; A2; A3];
beq = [1; 1; zeros(size(inter_nodes,1),1)];

% A*x <= b
A = edgeResource';
b = ResourceMax;
% A = [];
% b = [];

% Setup bounds:
lb = zeros(size(c));
ub = ones(size(c));
intvars = 1:length(c);
options = optimoptions('intlinprog','Display','none');
% options = optimoptions('intlinprog','Display','iter');
[sol,fval,exitflag,output] = intlinprog(c,intvars,A,b,Aeq,beq,lb,ub,options);

sol = uint8(sol);
edgeList = find(sol==1)';
s_path = s(edgeList);
t_path = t(edgeList);

nodeList = zeros(size(s_path,1)+1,1);
nodeList(1,1) = S_idx;
for i = 1:length(s_path)
    nodeList(i+1,1) = t_path(s_path==nodeList(i,1));
end
edgeList = zeros(length(nodeList)-1,1);
for i = 1:length(nodeList)-1
    edgeList(i,1) = find(s==nodeList(i) & t==nodeList(i+1));
end
end