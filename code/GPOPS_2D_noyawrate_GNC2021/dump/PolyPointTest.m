% For non self intersecting polygons
clear all; close all; clc;

% polySize = [5 6]';
% nodes = [40 30; 70 50; 80 100; 40 130; 20 120;
%          110 30; 140 50; 150 100; 110 130; 90 120; 75 60];
     
polySize = [5]';
nodes = [40 30; 70 50; 80 100; 40 130; 20 120];

% polySize = [7 6]';
% nodes = [40 30; 80 40; 70 70; 80 90; 80 100; 40 130; 20 120;
%          110 30; 140 50; 150 100; 110 130; 90 120; 75 60];
edges = [];
offset = 0;
for i = 1:size(polySize,1)
    edges_temp = offset+[(1:(polySize(i,1)-1))' (2:polySize(i,1))'; polySize(i,1) 1];
    edges = [edges; edges_temp];
    offset = sum(polySize(1:i,1));
end

polyEdges = cell(size(polySize,1),1);
ctr = 0;
for i = 1:size(polySize,1)
%     polyEdges{i,1} = [ctr+(1:polySize(i)); ctr+(1:polySize(i))];
    polyEdges{i,1} = ctr+(1:polySize(i));
    ctr = sum(polySize(1:i));
end

% x = [33, 70;
% %     [31.15, 70;
%      65, 45;
%      120, 80;
%      95.01, 60;
%      75, 70];
 
 x = [33, 70;
     65, 45;
     120, 80];
%  x = [33, 70];
% s = 100;
% edgeClass = zeros(size(x,1),size(edges,1));
% edgeCon = zeros(size(x,1),size(edges,1));
% path = zeros(size(x,1),size(polySize,1));
% path2 = zeros(size(x,1),size(polySize,1));
% 
% for i = 1:size(edges,1)
%     x1 = x(:,1)-nodes(edges(i,1),1);
%     y1 = x(:,2)-nodes(edges(i,1),2);
%     x2 = nodes(edges(i,2),1)-nodes(edges(i,1),1);
%     y2 = nodes(edges(i,2),2)-nodes(edges(i,1),2);
%     edgeClass(:,i) = 1./(1+exp(s*(x1*y2-y1*x2)));
%     edgeCon(:,i) = -(x1*y2-y1*x2);
% end
% 
% edgeCon2 = -((repmat(x(:,1),1,size(edges,1))...
%     -repmat(nodes(edges(:,1),1)',size(x(:,1),1),1)).*(repmat(nodes(edges(:,2),2)',size(x(:,1),1),1)...
%     -repmat(nodes(edges(:,1),2)',size(x(:,1),1),1))...
%     - (repmat(x(:,2),1,size(edges,1))...
%     -repmat(nodes(edges(:,1),2)',size(x(:,2),1),1)).*(repmat(nodes(edges(:,2),1)',size(x(:,1),1),1)...
%     -repmat(nodes(edges(:,1),1)',size(x(:,1),1),1)));
% 
% ctr = 0;
% for i = 1:size(polySize,1)
%     path(:,i) = sum(edgeClass(:,ctr+(1:polySize(i))),2);
%     poly(:,i) = min(edgeCon(:,ctr+(1:polySize(i))),[],2);
%     ctr = sum(polySize(1:i));
% end

for i = 1:size(polySize,1)
    x1 = nodes(edges(polyEdges{i,1},1),1)'-x(:,1);
    y1 = nodes(edges(polyEdges{i,1},1),2)'-x(:,2);
    x2 = nodes(edges(polyEdges{i,1},2),1)'-x(:,1);
    y2 = nodes(edges(polyEdges{i,1},2),2)'-x(:,2);
    angle = atan2d(y2, x2) - atan2d(y1, x1);
    angle(angle<0) = angle(angle<0) + 360;
    angleSum = sum(abs(angle),2);
%     edgeCon(:,i) = -(x1.*y2-y1.*x2);
%     path2(:,i) = min(-(x1.*y2-y1.*x2),[],2);
%     poly(:,i) = min(-(x1.*y2-y1.*x2),[],2);
end


for i = 1:size(polySize,1)
    x1 = x(:,1)-nodes(edges(polyEdges{i,1},1),1)';
    y1 = x(:,2)-nodes(edges(polyEdges{i,1},1),2)';
    x2 = repmat(nodes(edges(polyEdges{i,1},2),1)'-nodes(edges(polyEdges{i,1},1),1)',size(x,1),1);
    y2 = repmat(nodes(edges(polyEdges{i,1},2),2)'-nodes(edges(polyEdges{i,1},1),2)',size(x,1),1);
%     edgeCon(:,i) = -(x1.*y2-y1.*x2);
%     path2(:,i) = min(-(x1.*y2-y1.*x2),[],2);
    poly(:,i) = min(-(x1.*y2-y1.*x2),[],2);
end


% tol = 1e-6;
% for i = 1:size(x,1)
%     if sum(path(i,:) < (polySize'-tol)) == size(polySize,1)
%         disp('Out');
%     else
%         disp('In');
%     end
% end
% disp(' ');

% path
% path2
% polySize'-tol

for i = 1:size(x,1)
    if poly(i,:) < 0
        disp('Out');
    else
        disp('In');
    end
end


figure;
hold on
scatter(x(:,1),x(:,2),'o');
scatter(x(:,1),x(:,2),'.');
patch('faces',edges(:,1:2),'vertices',nodes, ...
    'FaceColor','w', ...
    'edgecolor',[.1,.1,.1], ...
    'linewidth',1.5) ;