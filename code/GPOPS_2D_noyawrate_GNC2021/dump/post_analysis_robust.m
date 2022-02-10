function violation = post_analysis_robust(X,Y,auxdata,bnd)
% rng default;
polySize = auxdata.polySize;
nodes = auxdata.nodes;
edges = auxdata.edges;

constraint = zeros(size(X,1),size(polySize,1));
violation = zeros(size(constraint,1),1);

[nodesN,edgesN,polySizeN] = polgonReSizing(nodes,edges,polySize,bnd.upp);

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
        violation(j,1) = 1;
    end
end
end