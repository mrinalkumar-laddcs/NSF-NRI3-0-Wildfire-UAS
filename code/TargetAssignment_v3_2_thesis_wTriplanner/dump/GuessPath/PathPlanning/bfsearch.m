function [path, cost] = bfsearch(A,CostMat,NodeCoords,source,target)

% Supply s,t and NodeCoords as Nx1 vectors

% Sanity Checks
% Check if the source and target are 1x1 scalars
if ~(size(source,1) == 1 && size(source,2) == 1)
    error('Source should be a 1x1 scalar.');
end

if ~(size(target,1) == 1 && size(target,2) == 1)
    error('Target should be a 1x1 scalar.');
end

% Check if adjacency and cost matrix are of same size
if ~(size(A,1) == size(A,2) && all(size(A) == size(CostMat)))
    error('Invalid Adjacency matrix A or Cost Matrix');
end

% Check if node coordinates are provided for all nodes
if ~(size(NodeCoords,1) == size(A,1))
    error('Invalid size of Node Coordinates Matrix. It should be Nx2 or Nx3.');
end

% Check if the source and target are valid nodes
if ~(source <= size(A,1) && target <= size(A,1))
    error('Either (or both) Source or Target is (are) not valid nodes');
end

   
    totalNodes = size(A,1);
    
    isVisited   = false(totalNodes,1);
    predecessor    = -1*ones(totalNodes,1);
    minArrivalCost = Inf*ones(totalNodes,1);
    priorityCost   = Inf*ones(totalNodes,1);

    sNodeIndex                 = source;
    minArrivalCost(sNodeIndex) = 0;
    priorityCost(sNodeIndex)   = 0;
    
    while any(~isVisited)
        
        nodesNotVisited       = find(~isVisited);
        [~,priorityIndex]     = min(priorityCost(nodesNotVisited,1));
        sNodeIndex            = nodesNotVisited(priorityIndex);

        if sNodeIndex == target
            break
        end
        
        isVisited(sNodeIndex) = true;
        
        tNodeIndices = find((A(sNodeIndex,:)==1)');
        tCost        = CostMat(sNodeIndex,tNodeIndices);

        if ~isempty(tNodeIndices)
            for j = 1:length(tNodeIndices)
                jNodeIndex = tNodeIndices(j);
                newArrivalCost = minArrivalCost(sNodeIndex) + tCost(j);
                if minArrivalCost(jNodeIndex) > newArrivalCost
                    minArrivalCost(jNodeIndex) = newArrivalCost;
                    priorityCost(jNodeIndex) = pdist2(NodeCoords(jNodeIndex,:),NodeCoords(target,:));
                    predecessor(jNodeIndex) = sNodeIndex;
                end
            end
        end
    end
    
    cost = minArrivalCost(target);
    
    path = target;
    while path(end,1) ~= source
        path = [path; predecessor(path(end,1))];
    end
    path = flipud(path);

end