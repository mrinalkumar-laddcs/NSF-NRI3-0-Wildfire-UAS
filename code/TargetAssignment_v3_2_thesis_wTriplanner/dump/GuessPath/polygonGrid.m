function [grid_mesh,guessGen] = polygonGrid(node,edge,polygonSize,sXY,tXY,boundRectXY,vehdata,winddata,plannertype)

% Choose the grid resolution
grid_step = 3;

% Extract the x-y bounds, use the template below
% boundRectXY = [xMin yMin; xMax yMin; xMax yMax; xMin yMax]; % coordinates of Bounding Box
xMin = boundRectXY(1,1);
xMax = boundRectXY(2,1);
yMin = boundRectXY(1,2);
yMax = boundRectXY(3,2);

% Generate a mesh grid and the find the number nodes along row and column
[X_grid, Y_grid] = meshgrid([xMin:grid_step:xMax],[yMin:grid_step:yMax]);
[nR,nC] = size(X_grid);
tot_nodes = nR*nC;
inout_grid = ones(nR,nC);

% Create an empty structure for nodes
node_struct = struct('ind',{},'sub',{},'loc',{},'out',{},'v_a',{},'v_w',{});

% Populate the node properties
for i=1:tot_nodes
    node_struct(i).ind = i;
    [node_struct(i).sub(1,1), node_struct(i).sub(1,2)] = ind2sub([nR,nC],i);
    node_struct(i).loc = [X_grid(1,node_struct(i).sub(1,2)),Y_grid(node_struct(i).sub(1,1),1)];
    node_struct(i).out = PointPolyTest(node,edge,polygonSize,node_struct(i).loc(1,1),node_struct(i).loc(1,2));
    inout_grid(node_struct(i).sub(1,1),node_struct(i).sub(1,2)) = node_struct(i).out;
    node_struct(i).v_a = vehdata.V;
%     if strcmp(plannertype,'naive')
%         node_struct(i).v_w = [0,0];
%     else
%         if node_struct(i).loc(1,1)>=50 && node_struct(i).loc(1,1)<=90 && node_struct(i).loc(1,2)>=40 && node_struct(i).loc(1,2)<=100
%             node_struct(i).v_w = [0,-7];
%         else
%             node_struct(i).v_w = [0,0];
%         end
%     end
    node_struct(i).v_w = [interp2(winddata.X,winddata.Y,winddata.Wx,node_struct(i).loc(1,1),node_struct(i).loc(1,2)),...
                          interp2(winddata.X,winddata.Y,winddata.Wy,node_struct(i).loc(1,1),node_struct(i).loc(1,2))]; 
end


% Identify the nearest node to the START and FINAL locations
[~,S_idx] = min(pdist2(reshape([node_struct.loc],[2,tot_nodes])',sXY,'euclidean'));
[~,T_idx] = min(pdist2(reshape([node_struct.loc],[2,tot_nodes])',tXY,'euclidean'));

% Replace the location values in the node by the START and FINAL locations
node_struct(S_idx).loc = sXY;
node_struct(T_idx).loc = tXY;

% Identify the connecting edges in the 5x5 neighborhood grid create a
% node connectivity and edge weight list
%
% I: identify the useful 16 nodes in the 5x5 grid
search_nodes = [];
nRmin = - 2;
nCmin = - 2;
nRmax = + 2;
nCmax = + 2;
for j = nRmin:nRmax
    for k = nCmin:nCmax
        if (abs(j)==abs(k) && abs(j)+abs(k)==2) || (abs(j)+abs(k)==1) || (abs(j)+abs(k)==3)          
%         if ~(abs(j)+abs(k)==0)
            search_nodes = [search_nodes; j,k];
        end
    end
end

% II: Use those 16 neighbor nodes and compute those edge weights
s = [];
t = [];
edgeWts = [];
for i=1:tot_nodes
    % i                  : start node index
    % node_struct(i).sub : start node subscript
    % [p,q]              : end node subscript
    if node_struct(i).out == 1 % check if the start node is outside the polygons
        
        for j = 1:size(search_nodes,1)
            p = node_struct(i).sub(1,1) + search_nodes(j,1);
            q = node_struct(i).sub(1,2) + search_nodes(j,2);
            if p>=1 && p<=nR % check for boundary cases
                if q>=1 && q<=nC % check for boundary cases
                    if node_struct(sub2ind([nR,nC],p,q)).out == 1
                        s = [s; i];
                        t = [t; sub2ind([nR,nC],p,q)];
                        if strcmp(plannertype,'naive')
                            edgeWts = [edgeWts; edgeWeights(node_struct(i),node_struct(sub2ind([nR,nC],p,q)))];
                        else
                            edgeWts = [edgeWts; edgeWeightsWind(node_struct(i),node_struct(sub2ind([nR,nC],p,q)))];
                        end
                    end
                end
            end
        end
    end
end

% Create a directional graph
mesh_graph = digraph(s,t,edgeWts);
% Find the shortest path
tic
TR = shortestpath(mesh_graph,S_idx,T_idx);
toc
path = reshape([node_struct(TR).loc],[2,length(TR)])';



grid_mesh.xgrid = X_grid;
grid_mesh.ygrid = Y_grid;
grid_mesh.inout = inout_grid;
guessGen.x = path(:,1);
guessGen.y = path(:,2);
end

%% %%%% Local Functions %%%%
function deltaT = edgeWeights(startNode,endNode)
deltaT = sqrt((startNode.loc(:,1)-endNode.loc(:,1)).^2 + (startNode.loc(:,2)-endNode.loc(:,2)).^2)/mean([startNode.v_a, endNode.v_a]);
end

function deltaT = edgeWeightsWind(startNode,endNode,vehdata)
dist = sqrt((startNode.loc(:,1)-endNode.loc(:,1)).^2 + (startNode.loc(:,2)-endNode.loc(:,2)).^2);
unit_vec = [endNode.loc(:,1)-startNode.loc(:,1), endNode.loc(:,2)-startNode.loc(:,2)];
unit_vec = unit_vec/norm(unit_vec);
dir_theta = atan2(unit_vec(1,2),unit_vec(1,1));

the = linspace(0,2*pi,61)';
dir_vec = atan2(startNode.v_a*sin(the(1:end-1))+startNode.v_w(1,2),startNode.v_a*cos(the(1:end-1))+startNode.v_w(1,1));
[~,idx] = min(abs(dir_vec-dir_theta));

if dir_vec(idx,1) >= (dir_theta-2*pi/16) && the(idx,1) <= (dir_theta+2*pi/16)
    v_g = startNode.v_a*[cos(the(idx)),sin(the(idx))] + startNode.v_w;
    deltaT  = dist/dot(v_g,unit_vec);
else
    deltaT = 1e6;
end
end

function out = PointPolyTest(nodesN,edgesN,polySizeN,X,Y)
edgeCon = -((repmat(X,1,size(edgesN,1))...
    -repmat(nodesN(edgesN(:,1),1)',size(X,1),1)).*(repmat(nodesN(edgesN(:,2),2)',size(X,1),1)...
    -repmat(nodesN(edgesN(:,1),2)',size(X,1),1))...
    - (repmat(Y,1,size(edgesN,1))...
    -repmat(nodesN(edgesN(:,1),2)',size(Y,1),1)).*(repmat(nodesN(edgesN(:,2),1)',size(X,1),1)...
    -repmat(nodesN(edgesN(:,1),1)',size(X,1),1)));

ctr = 0;
for i = 1:size(polySizeN,1)
    constraint(:,i) = min(edgeCon(:,ctr+(1:polySizeN(i))),[],2);
    ctr = sum(polySizeN(1:i));
end

for j = 1:size(constraint,1)
    if any(constraint(j,:) > 0)
        out(j,1) = 0;
    else
        out(j,1) = 1;
    end
end
end