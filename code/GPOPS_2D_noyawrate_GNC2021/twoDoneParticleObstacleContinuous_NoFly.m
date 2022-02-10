%--------------------------------------------%
% BEGIN: twoDoneParticleObstacleContinuous.m %
%--------------------------------------------%
function phaseout = twoDoneParticleObstacleContinuous_NoFly(input)

%-----------------%
% Extract auxdata %
%-----------------%
V0       = input.auxdata.V0;
r_min    = input.auxdata.r_min;
delta    = input.auxdata.delta;
polySize = input.auxdata.polySize;
nodes    = input.auxdata.nodes;
edges    = input.auxdata.edges;
heatdata = input.auxdata.heatdata;
Tmin     = input.auxdata.Tmin;
Ph       = input.auxdata.Ph;
Pm       = input.auxdata.Pm;

%----------%
% Dynamics %
%----------%
t = input.phase.time;
x = input.phase.state;
u = input.phase.control;

thetar = x(:,3);
vX = V0.*cos(thetar);
vY = V0.*sin(thetar);
phaseout.dynamics = [vX, vY, u(:,1)];

if ~isempty(polySize)
phaseout.path = zeros(size(x,1),size(polySize,1));

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
end

delta_t = [diff(t)];

% Energy Integral
E_hover  = Ph*delta_t;
E_motion = Pm*V0.*delta_t;
E = (E_hover + E_motion)/1000;

% Distance Integral
dist = V0.*delta_t;
% dist = [0; sqrt(diff(x(:,1)).^2 + diff(x(:,2)).^2)];

% Temperature Integral
% temp = delta_t.*interp2(heatdata.X,heatdata.Y,heatdata.HF,x(:,1),x(:,2))*0.08;
% temp = delta_t.*interp2(heatdata.X,heatdata.Y,heatdata.HF,(x(1:end-1,1)+x(2:end,1))/2,(x(1:end-1,2)+x(2:end,2))/2)*0.08;

% phaseout.integrand = [dist, temp; 0 0];
% phaseout.integrand = [E, temp; 0 0];
phaseout.integrand = [E; 0];

% phaseout.integrand = 0.5*u.^2;
% phaseout.integrand = 0.5*u.^2 + 0.5*(x(:,1).^2+x(:,2).^2+x(:,3).^2);
end

%------------------------------------------%
% END: twoDoneParticleObstacleContinuous.m %
%------------------------------------------%