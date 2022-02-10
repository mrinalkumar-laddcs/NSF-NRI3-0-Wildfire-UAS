function violation = post_analysis_path_noise(t,X,Y,thetar,auxdata,risk,path_noise,nTrials)
% rng default;
polySize = auxdata.polySize;
nodes = auxdata.nodes;
edges = auxdata.edges;
V = auxdata.V;

nSteps = size(X,1);
delta_t = [0; t(2:end,1) - t(1:end-1,1)];

delta_rnd_vec = normrnd(risk.mu,risk.sigma,[nTrials, 1]);
constraint = zeros(nSteps,size(polySize,1));
violation_count = zeros(size(constraint,1),1);

for k = 1:size(delta_rnd_vec,1)
    u_sam = normrnd(0,path_noise.sigma_u,[nSteps,1]);
    
    % Addition of Noise (via Integration)    
    % Method 2
    X_rnd = zeros(nSteps,1);
    Y_rnd = zeros(nSteps,1);
    thetar_rnd = thetar(:,1) + u_sam.*sqrt(delta_t);
    X_rnd(1,1) = X(1,1);
    Y_rnd(1,1) = Y(1,1);
    thetar_rnd(1,1) = thetar(1,1);
    for i = 2:nSteps
        X_rnd(i,1) = X(i-1,1) + V*cos(thetar_rnd(i,1)).*delta_t(i,1);
        Y_rnd(i,1) = Y(i-1,1) + V*sin(thetar_rnd(i,1)).*delta_t(i,1);
    end
    
    [nodesN,edgesN,polySizeN] = polgonReSizing(nodes,edges,polySize,delta_rnd_vec(k,1));
    edgeCon = -((repmat(X_rnd,1,size(edgesN,1))...
        -repmat(nodesN(edgesN(:,1),1)',size(X_rnd,1),1)).*(repmat(nodesN(edgesN(:,2),2)',size(X_rnd,1),1)...
        -repmat(nodesN(edgesN(:,1),2)',size(X_rnd,1),1))...
        - (repmat(Y_rnd,1,size(edgesN,1))...
        -repmat(nodesN(edgesN(:,1),2)',size(Y_rnd,1),1)).*(repmat(nodesN(edgesN(:,2),1)',size(X_rnd,1),1)...
        -repmat(nodesN(edgesN(:,1),1)',size(X_rnd,1),1)));
    
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