function [NodePath,EdgePath] = constrained_dijkstra(s,t,edgeCost,source,target,edgeResource,ResourceMax)
%     (s,t,edgeWeight,source,target)
% Make all inputs as vectors
if size(s,1) == 1
    s = s';
end

if size(t,1) == 1
    t = t';
end

if size(edgeCost,1) == 1
    edgeCost = edgeCost';
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
if length(s) == length(t) && length(s) == length(edgeCost)
    
    OrigNodeIDs = sort(unique([s;t]));
    totalNodes  = length(OrigNodeIDs);
    nodeID      = (1:totalNodes)';
    deltaR      = 1;
    nR          = round(ResourceMax/deltaR);
    
    sNew        = arrayfun(@(i) find(OrigNodeIDs == s(i)),(1:length(s))');
    tNew        = arrayfun(@(i) find(OrigNodeIDs == t(i)),(1:length(s))');
    sourceNew   = find(OrigNodeIDs == source);
    targetNew   = find(OrigNodeIDs == target);
    
    isVisited      = false(totalNodes,1);
    pred           = -1*ones(totalNodes,1);
    minArrivalCost = Inf*ones(totalNodes,nR);
    
    minArrivalCost(sourceNew,nR) = 0;
    
    while ~isVisited(targetNew)
        
        nodesNotVisited       = find(~isVisited);
        [~,minIndex]          = min(minArrivalCost(nodesNotVisited,1));
        sNodeIndex            = nodesNotVisited(minIndex);
        isVisited(sNodeIndex) = true;
        
        tEdgeIndices = sNew == sNodeIndex;
        tNodeIndices = tNew(tEdgeIndices,1);
        tCost        = edgeCost(tEdgeIndices,1);
        tResource    = edgeResource(tEdgeIndices,1);

        if ~isempty(tNodeIndices)
        for j = 1:length(tNodeIndices)
            
            jNodeIndex = find(nodeID == tNodeIndices(j));
            
            c = m - tResource(j);
            
            if minArrivalCost(jNodeIndex,c) > minArrivalCost(sNodeIndex,m) + tCost(j)
                minArrivalCost(jNodeIndex,c) = minArrivalCost(sNodeIndex,m) + tCost(j);
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