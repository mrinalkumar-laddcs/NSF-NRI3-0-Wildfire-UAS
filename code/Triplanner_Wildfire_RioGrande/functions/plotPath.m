%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualization of Final Path
function plotPath(conv_obs,domain,startPoint,finalPoint,status,path,broken_poly)
obs = combineBroken(conv_obs,broken_poly);

figure;
hold on;
% show the obstacles
for i = 1:size(obs,2)
    fill(obs(i).polygon(:,1),obs(i).polygon(:,2), 'y');
end
% show the path
if status ~=1
    plot(path(:,1),path(:,2),'LineWidth',2);
end
% show the start/end points
plot(startPoint(1),startPoint(2),'*','LineWidth',3,'Color',[0.4660 0.6740 0.1880]);
plot(finalPoint(1),finalPoint(2),'*','LineWidth',3,'Color',[1 0 0]);
xlim(domain(1,[1,3]));
ylim(domain(1,[2,4]));
title('Triplanner generated path');
end