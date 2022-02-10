%--------------------------------------------%
% BEGIN: twoDoneParticleObstacleContinuous.m %
%--------------------------------------------%
function phaseout = twoDoneParticleObstacleContinuous(input)

%-----------------%
% Extract auxdata %
%-----------------%
V  = input.auxdata.V;
r_min  = input.auxdata.r_min;
delta = input.auxdata.delta;
polySize = input.auxdata.polySize;
nodes = input.auxdata.nodes;
edges = input.auxdata.edges;


%----------%
% Dynamics %
%----------%
t = input.phase.time;
x = input.phase.state;
u = input.phase.control;

thetar = x(:,3);
vX = V*cos(thetar);
vY = V*sin(thetar);
phaseout.dynamics = [vX, vY, u.*V./r_min];

% phaseout.path = [((x(:,1)-Xc(1)).^2 + (x(:,2)-Yc(1)).^2 - (r(1)+delta)^2), (abs((x(:,1)-Xc(2)) + (x(:,2)-Yc(2))) + abs((x(:,1)-Xc(2)) - (x(:,2)-Yc(2))) - 2*r(2))];

% edgeClass = zeros(size(x,1),size(edges,1));
% edgeCon = zeros(size(x,1),size(edges,1));
phaseout.path = zeros(size(x,1),size(polySize,1));
% s = 5;
% for i = 1:size(edges,1)
%     x1 = x(:,1)-nodes(edges(i,1),1);
%     y1 = x(:,2)-nodes(edges(i,1),2);
%     x2 = nodes(edges(i,2),1)-nodes(edges(i,1),1);
%     y2 = nodes(edges(i,2),2)-nodes(edges(i,1),2);
% %     edgeClass(:,i) = 1./(1+exp(s*(x1*y2-y1*x2)));
% %     edgeClass(:,i) = 1 - 1./(1+exp(s*(x1*y2-y1*x2)));
%     edgeCon(:,i) = -(x1*y2-y1*x2);
% end

edgeCon = -((repmat(x(:,1),1,size(edges,1))...
    -repmat(nodes(edges(:,1),1)',size(x(:,1),1),1)).*(repmat(nodes(edges(:,2),2)',size(x(:,1),1),1)...
    -repmat(nodes(edges(:,1),2)',size(x(:,1),1),1))...
    - (repmat(x(:,2),1,size(edges,1))...
    -repmat(nodes(edges(:,1),2)',size(x(:,2),1),1)).*(repmat(nodes(edges(:,2),1)',size(x(:,1),1),1)...
    -repmat(nodes(edges(:,1),1)',size(x(:,1),1),1)));


ctr = 0;
for i = 1:size(polySize,1)
    phaseout.path(:,i) = min(edgeCon(:,ctr+(1:polySize(i))),[],2);
    ctr = sum(polySize(1:i));
end
% phaseout.integrand = [0; sqrt((x(2:end,1)-x(1:(end-1),1)).^2 + (x(2:end,2)-x(1:(end-1),2)).^2)];
end

%------------------------------------------%
% END: twoDoneParticleObstacleContinuous.m %
%------------------------------------------%