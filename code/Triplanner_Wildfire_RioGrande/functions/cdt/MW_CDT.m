function [status,path] = MW_CDT(obs,domain,startPoint,finalPoint)

node = [];
edge = [];
for i = 1:size(obs,2)
    obs(i).polySize = size(obs(i).polygon,1);
    edge = [edge; size(node,1)+[(1:(obs(i).polySize-1))' (2:obs(i).polySize)'; obs(i).polySize 1]];
    node = [node; obs(i).polygon];
end

% Domain
xMin = domain(1,1);
xMax = domain(1,3);
yMin = domain(1,2);
yMax = domain(1,4);
boundRectXY = [xMin yMin; xMax yMin; xMax yMax; xMin yMax]; % coordinates of Bounding Box
boundEdges = [(1:3)' (2:4)'; 4 1];

% Trigulation Process
nodeList = [boundRectXY; node];
edgeList = [boundEdges; size(boundRectXY,1)+edge];

DT = delaunayTriangulation(nodeList);
CDT = delaunayTriangulation(nodeList,edgeList);

figure;
triplot(DT);
daspect([1 1.5 1.5]);

figure;
triplot(CDT);
daspect([1 1.5 1.5]);

status = 0;
path = 0;

end