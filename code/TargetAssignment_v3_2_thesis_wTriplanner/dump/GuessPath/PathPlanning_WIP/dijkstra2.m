function [NodePath, cost] = dijkstra2(s,t,edgeWeight,source,target)

% Make all inputs as vectors
if size(s,1) == 1
    s = s';
end

if size(t,1) == 1
    t = t';
end

if size(edgeWeight,1) == 1
    edgeWeight = edgeWeight';
end

% Sanity Checks
% Check if the source and target are 1x1 scalars
if ~(size(source,1) == 1 && size(source,2) == 1)
    error('Source should be a 1x1 scalar.');
end

if ~(size(target,1) == 1 && size(target,2) == 1)
    error('Target should be a 1x1 scalar.');
end

% Check if source and target are present in the given set
if ~any(s==source)
    error('Invalid Source node! It is not present in the graph.');
end

% Check if source and target are present in the given set
if ~any(t==target)
    error('Invalid Target node! It is not present in the graph.');
end

% Check if the inputs are of same length
if length(s) == length(t) && length(s) == length(edgeWeight)
    
    OrigNodeIDs = uint32(sort(unique([s;t])));
    totalNodes  = uint32(length(OrigNodeIDs));
    nodeID     = (1:totalNodes)';
    
    sNew        = uint32(arrayfun(@(i) find(OrigNodeIDs == s(i)),(1:length(s))'));
    tNew        = uint32(arrayfun(@(i) find(OrigNodeIDs == t(i)),(1:length(s))'));
    sourceNew   = uint32(find(OrigNodeIDs == source));
    targetNew   = uint32(find(OrigNodeIDs == target));
    
    isVisited      = false(totalNodes,1);
    pred           = -1*uint32(ones(totalNodes,1));
    minArrivalCost = Inf*ones(totalNodes,1);
    
    minArrivalCost(sourceNew) = 0;
    
    while ~isVisited(targetNew)
        
        nodesNotVisited       = uint32(find(~isVisited));
        [~,minIndex]          = min(minArrivalCost(nodesNotVisited,1));
        sNodeIndex            = nodesNotVisited(minIndex);
        isVisited(sNodeIndex) = true;
        
        tEdgeIndices = sNew == sNodeIndex;
        tNodeIndices = tNew(tEdgeIndices,1);
        tCost        = edgeWeight(tEdgeIndices,1);

        if ~isempty(tNodeIndices)
        for j = uint32(1:length(tNodeIndices))
            jNodeIndex = uint32(find(nodeID == tNodeIndices(j)));
            if minArrivalCost(jNodeIndex) > minArrivalCost(sNodeIndex) + tCost(j)
                minArrivalCost(jNodeIndex) = minArrivalCost(sNodeIndex) + tCost(j);
                pred(jNodeIndex) = sNodeIndex;
            end
        end
        end
    end
    
    cost = minArrivalCost(targetNew);
    
    NodePath = targetNew;
    while NodePath(end,1) ~= sourceNew
        NodePath = [NodePath; pred(NodePath(end,1))];
    end
    NodePath = OrigNodeIDs(flipud(NodePath));
else
    error('Invalid inputs! The length of source and target nodes and edge cost should be equal.');
end

end