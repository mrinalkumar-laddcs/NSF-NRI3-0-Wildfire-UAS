%------------------------------------------%
% BEGIN: twoDoneParticleObstacleEndpoint.m %
%------------------------------------------%
function output = twoDoneParticleObstacleEndpoint(input)

% Declare Objective: Min Time
output.objective = input.phase.finaltime;

% % Declare Objective: Min Distance
% output.objective = input.phase.integral;
end
%----------------------------------------%
% END: twoDoneParticleObstacleEndpoint.m %
%----------------------------------------%
