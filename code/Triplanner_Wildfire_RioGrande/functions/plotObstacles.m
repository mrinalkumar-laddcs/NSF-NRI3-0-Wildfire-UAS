%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualization of obstacle shrinkage/relaxation
function plotObstacles(obs,newObs,domain,conservatism,conservativeDelta)
global transform
figure
hold on

switch conservatism
    case 0       
        for i = 1:size(obs,2)
            fill(obs(i).polygon(:,1),obs(i).polygon(:,2),[0.9290 0.6940 0.1250]);  % Visualize: filled-polygons
            plot(obs(i).polygon(:,1),obs(i).polygon(:,2),'o');
        end
        for i = 1:size(newObs,2)
            fill(newObs(i).polygon(:,1),newObs(i).polygon(:,2),'y');  % Visualize: filled-polygons
            plot(newObs(i).polygon(:,1),newObs(i).polygon(:,2),'k+');
        end
    case 1
        if conservativeDelta > 0
            for i = 1:size(newObs,2)
                fill(newObs(i).polygon(:,1),newObs(i).polygon(:,2),'y');  % Visualize: filled-polygons
                plot(newObs(i).polygon(:,1),newObs(i).polygon(:,2),'o');
            end
            for i = 1:size(obs,2)
                fill(obs(i).polygon(:,1),obs(i).polygon(:,2),[0.9290 0.6940 0.1250]);  % Visualize: filled-polygons
                plot(obs(i).polygon(:,1),obs(i).polygon(:,2),'o');
            end
        else
            for i = 1:size(obs,2)
                fill(obs(i).polygon(:,1),obs(i).polygon(:,2),[0.9290 0.6940 0.1250]);  % Visualize: filled-polygons
                plot(obs(i).polygon(:,1),obs(i).polygon(:,2),'o');
            end
            for i = 1:size(newObs,2)
                fill(newObs(i).polygon(:,1),newObs(i).polygon(:,2),'y');  % Visualize: filled-polygons
                plot(newObs(i).polygon(:,1),newObs(i).polygon(:,2),'o');
            end
        end
end

if transform == 1
    xlim([domain.xmin, domain.xmax]);
    ylim([domain.ymin, domain.ymax]);
else
    xlim([domain.longmin, domain.longmax]);
    ylim([domain.latmin, domain.latmax]);
end
title('Generation of Random Obstacle Boundaries');
daspect([1 1 1]);
end