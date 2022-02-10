% For non self intersecting polygons
clear all; close all; clc;

polySize = [5]';
nodes = [40 30; 70 50; 80 100; 40 130; 20 120];
edges = [];
offset = 0;
for i = 1:size(polySize,1)
    edges_temp = offset+[(1:(polySize(i,1)-1))' (2:polySize(i,1))'; polySize(i,1) 1];
    edges = [edges; edges_temp];
    offset = sum(polySize(1:i,1));
end

testPt = [31.15, 70];

% inPoly = zeros(size(polySize));
% ctr = 0;
% for i = size(polySize,1)
%     polyNodes = nodes(ctr+(1:polySize(i,1)),:);
%     polyEdges = edges(ctr+(1:polySize(i,1)),:);
%     for j = 1:polySize(i,1)
%         x1 = testPt(1,1)-polyNode(
%         if
%         end
%     end
%     ctr = sum(polySize(1:i));
% end

outFlag = 0;
flag = zeros(size(edges,1),1);
class = zeros(size(edges,1),1);
s = 0.1*50;
for i = 1:size(edges,1)
    x1 = testPt(1,1)-nodes(edges(i,1),1);
    y1 = testPt(1,2)-nodes(edges(i,1),2);
    
    x2 = nodes(edges(i,2),1)-nodes(edges(i,1),1);
    y2 = nodes(edges(i,2),2)-nodes(edges(i,1),2);
    k(i,1) = x1*y2-y1*x2;
    class(i,1) = 1/(1+exp(s*k(i,1)));
    if k(i,1) < 0
        flag(i,1) = 1;
    end
end

k
flag
class

tol = 1e-6;
if sum(class) < (size(edges,1)-tol)
    disp('Out');
else
    disp('In');
end


figure;
hold on
scatter(testPt(:,1),testPt(:,2),'o');
scatter(testPt(:,1),testPt(:,2),'.');
patch('faces',edges(:,1:2),'vertices',nodes, ...
    'FaceColor','w', ...
    'edgecolor',[.1,.1,.1], ...
    'linewidth',1.5) ;