function phased_bary = phased_cart2bary(phased_cart,tri)
numPhases = size(phased_cart.phase,2);
% phased_bary.phase = struct('time',cell(1,numPhases),'state',cell(1,numPhases),'control',cell(1,numPhases));
phased_bary = phased_cart;
for i = 1:numPhases
    for j = 1:size(phased_cart.phase(i).state,1)
        phased_bary.phase(i).state(j,1:3) = cart2bary(tri.Points(tri.ConnectivityList(i,:)',:),phased_cart.phase(i).state(j,1:2))';
    end
    phased_bary.phase(i).state(:,4) = phased_cart.phase(i).state(:,3);
end
end