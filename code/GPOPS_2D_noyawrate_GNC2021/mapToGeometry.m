function [node,edge,polySize] = mapToGeometry(ShapeIn,boundRect,boundary,reducePoints)
% boundary     : 0 - As is, 1 - Boundary, 2 - Convex Hull, 3 - Bounding Quad
% reducePoints : % 0 - False, 1 - True

numBldg = size(ShapeIn,1);
% boundRect = [minLon minLat; maxLon minLat; maxLon maxLat; minLon maxLat];

% areaRect = [xMin; xMax; xMax; xMin; yMin; yMin; yMax; yMax];

for i = 1:numBldg
    xList = ShapeIn{i,1};
    yList = ShapeIn{i,2};
    xList = xList(isfinite(xList(:, 1)), :);
    yList = yList(isfinite(yList(:, 1)), :);
    switch boundary
        case 1
            K = boundary(xList,yList,0.3);
            xList = xList(K,1);
            yList = yList(K,1);
        case 2
            K = convhull(xList,yList,'simplify',true);
            xList = xList(K,1);
            yList = yList(K,1);
        case 3
            if size(xList,1)>4
                [xList,yList,~] = minboundquad(xList,yList);
                xList = xList';
                yList = yList';
                xList = xList(1:end-1,1);
                yList = yList(1:end-1,1);
            end
        otherwise
    end
    if reducePoints
        [yList,xList] = reducem(yList,xList,0.00001);
        xList = xList(1:end-1,1);
        yList = yList(1:end-1,1);
    end

    ShapeIn{i,1} = xList;
    ShapeIn{i,2} = yList;
end

shapeList = [mat2cell(boundRect,size(boundRect,1),[1 1]);ShapeIn];
cellSize = cellfun(@(x) size(x,1), shapeList);
cellSize = cellSize(:,1);
maxCellSize = max(cellSize);
node = zeros(sum(cellSize,1),2);

% node(1:cellSize(1,1),:) = [boundRect(:,1) boundRect(:,2)];
% edge = [(1:(cellSize(1,1)-1))' (2:cellSize(1,1))'; cellSize(1,1) 1];
edge = [];
offset = 0;
for i = 1:size(cellSize,1)
    node((offset+1):(offset + cellSize(i,1)),:) = [shapeList{i,1}(1:cellSize(i,1),1) shapeList{i,2}(1:cellSize(i,1),1)];
    edges_temp = offset+[(1:(cellSize(i,1)-1))' (2:cellSize(i,1))'; cellSize(i,1) 1];
    edge = [edge; edges_temp];
    offset = sum(cellSize(1:i,1));
end

polySize = cellSize(2:end,1);
end