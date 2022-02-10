%--------------------------------------------%
% BEGIN: twoDoneParticleObstacleContinuous.m %
%--------------------------------------------%
function phaseout = twoDoneParticleObstacleContinuousFor(input)

%-----------------%
% Extract auxdata %
%-----------------%
V                   = input.auxdata.V;
r_min               = input.auxdata.r_min;
TriPoints           = input.auxdata.Tri.Points;
TriConnectivityList = input.auxdata.Tri.ConnectivityList;

%----------%
% Dynamics %
%----------%
for phNum = 1:size(TriConnectivityList,1)
    % Phase #phNum
    Tri = TriPoints(TriConnectivityList(phNum,:)',:);
    x1 = Tri(1,1);
    x2 = Tri(2,1);
    x3 = Tri(3,1);
    y1 = Tri(1,2);
    y2 = Tri(2,2);
    y3 = Tri(3,2);
    
    detT = (x1-x3)*(y2-y3)-(x2-x3)*(y1-y3);
    
    t = input.phase(phNum).time;
    x = input.phase(phNum).state;
    u = input.phase(phNum).control;
    
    alpha = x(:,1:3);
    theta = x(:,4);
    alphadot1 = ((y2-y3)*V*cos(theta)+(x3-x2)*V*sin(theta))/detT;
    alphadot2 = ((y3-y1)*V*cos(theta)+(x1-x3)*V*sin(theta))/detT;
    alphadot3 = -alphadot1-alphadot2;
    phaseout(phNum).dynamics = [alphadot1, alphadot2, alphadot3, u.*V./r_min];
    phaseout(phNum).path = alpha(:,1)+alpha(:,2)+alpha(:,3);
    
end

% phaseout.integrand = [0; sqrt((x(2:end,1)-x(1:(end-1),1)).^2 + (x(2:end,2)-x(1:(end-1),2)).^2)];
end

%------------------------------------------%
% END: twoDoneParticleObstacleContinuous.m %
%------------------------------------------%
