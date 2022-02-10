%------------------------------------------%
% BEGIN: twoDoneParticleObstacleEndpoint.m %
%------------------------------------------%
function output = twoDoneParticleObstacleEndpointFor(input)

% Extract auxdata
TriPoints           = input.auxdata.Tri.Points;
TriConnectivityList = input.auxdata.Tri.ConnectivityList;


for phNum = 1:size(TriConnectivityList,1)    
    if phNum > 1        
        % Extract States
        % Variables at Start and Terminus of Phase #phNum
        t0_curr = input.phase(phNum).initialtime;
        tf_prev = input.phase(phNum-1).finaltime;
        
        Tri_curr = TriPoints(TriConnectivityList(phNum,:)',:);
        a0_curr = input.phase(phNum).initialstate;
        x0_curr = [bary2cart(Tri_curr,a0_curr(1:3)')' a0_curr(4)];
        
        Tri_prev = TriPoints(TriConnectivityList(phNum-1,:)',:);
        af_prev = input.phase(phNum-1).finalstate;
        xf_prev = [bary2cart(Tri_prev,af_prev(1:3)')' af_prev(4)];
        
        % Event Group 1: Linkage Constraints Between Current Phase #phNum
        % and Previous Phase #phNum-1
        output.eventgroup(phNum-1).event = [x0_curr(1:3)-xf_prev(1:3), t0_curr-tf_prev];
    end    
end

% Declare Objective: Min Time
output.objective = input.phase(phNum).finaltime;

% % Declare Objective: Min Distance
% output.objective = input.phase.integral;
end
%----------------------------------------%
% END: twoDoneParticleObstacleEndpoint.m %
%----------------------------------------%
