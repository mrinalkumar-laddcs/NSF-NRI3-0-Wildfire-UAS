function violation = post_analysis(X,Y,auxdata,risk,nTrials)
% rng default;
polySize = auxdata.polySize;
nodes = auxdata.nodes;
edges = auxdata.edges;

delta_rnd_vec = normrnd(risk.mu,risk.sigma,[nTrials, 1]);
constraint = zeros(size(X,1),size(polySize,1));
violation_count = zeros(size(constraint,1),1);

for k = 1:size(delta_rnd_vec,1)
    [nodesN,edgesN,polySizeN] = polgonReSizing(nodes,edges,polySize,delta_rnd_vec(k,1));
    
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
            violation_count(j,1) = violation_count(j,1)+1;
        end
    end
end

violation = violation_count/nTrials;
end