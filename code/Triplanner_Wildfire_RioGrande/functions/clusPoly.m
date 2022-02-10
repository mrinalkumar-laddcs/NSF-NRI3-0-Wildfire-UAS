function [status, obs] = clusPoly(bdry,domain)
global transform
global fig_draw
for i = 1:size(bdry,2)
    obs(i).polygon = bdry(i).ll;  % Construct a list of polygon vertices
    if transform == 1
        obs(i).polygon(:,1) = obs(i).polygon(:,1)-domain.longmin;
        obs(i).polygon(:,2) = obs(i).polygon(:,2)-domain.latmin;
    end
    obs(i).polySize = size(obs(i).polygon,1);
end

% Refined Obstacle Coordinates
newObs = polygonResize(obs,0); % Cleans up collinear Points

% Plot obstacle and its boundaries
if fig_draw == 1
    plotObstacles(obs,newObs,domain,0,0);
end

obs = newObs;
status = 1;
end