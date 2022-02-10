%------------------------------------------%
% BEGIN: twoDoneParticleObstacleEndpoint.m %
%------------------------------------------%
function output = twoDoneParticleObstacleEndpoint(input)

% Declare Objective: Min Time
% output.objective = input.phase.finaltime;

% Declare Objective: Min Energy
output.objective = input.phase.integral;

% % Declare Objective: Min Distance
% output.objective = input.phase.integral;

% % Declare Objective: Min TempRise
% output.objective = input.phase.integral;

% % Declare Objective: Min Effort & Min Time
% output.objective = input.phase.integral + input.phase.finaltime;
end
%----------------------------------------%
% END: twoDoneParticleObstacleEndpoint.m %
%----------------------------------------%
