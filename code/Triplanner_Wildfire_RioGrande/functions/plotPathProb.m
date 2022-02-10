%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualization of Final Path
function plotPathProb(conv_obs,domain,startPoint,finalPoint,status,path,broken_poly,unc,risk)
obs = combineBroken(conv_obs,broken_poly);

risk.Mode = 0;

N = 10;
delta = unc.mu + linspace(0,3*unc.sigma,N)';
alpha = linspace(1,0.1,N)';

figure;
hold on;
% show the obstacles
for i = 1:N
    newObs = polygonResize(obs,delta(i,1));
    %     fill(obs(i).polygon(:,1),obs(i).polygon(:,2), 'y');
    for j = 1:size(obs,2)
        if alpha(i,1) == 1
            patch('XData',newObs(j).polygon(:,1),'YData',newObs(j).polygon(:,2),...
            'FaceColor',[0.9290 0.6940 0.1250], 'FaceAlpha',1, ...
            'edgecolor',[0.9290 0.6940 0.1250],'edgealpha',alpha(i,1), 'linewidth',1.5);
        else
            patch('XData',newObs(j).polygon(:,1),'YData',newObs(j).polygon(:,2),...
                'FaceColor',[0.9290 0.6940 0.1250], 'FaceAlpha',0, ...
                'edgecolor',[0.9290 0.6940 0.1250],'edgealpha',alpha(i,1), 'linewidth',1.5);
        end
    end
end

% show the path
cmap = colormap(cool(size(path,2)));
if status ~=1
    if risk.Mode == 1
        for i = 1:2:size(path,2)
%             plot(path{i}(:,1),path{i}(:,2),'LineWidth',0.5,'Color',[0 0.4470 0.7410 (1-i/size(path,2))]);
            plot(path{i}(:,1),path{i}(:,2),'LineWidth',1.5,'Color',[cmap(i,:)]);
            c = colorbar('location','eastoutside','TickLabels',{linspace(0,0.2,11)});
            c.Label.String = 'Risk';
            c.Label.FontWeight = 'bold';
        end
    else
        plot(path(:,1),path(:,2),'LineWidth',1.5);
    end
end

% show the start/end points
plot(startPoint(1),startPoint(2),'*','LineWidth',3,'Color',[0.4660 0.6740 0.1880]);
plot(finalPoint(1),finalPoint(2),'*','LineWidth',3,'Color',[1 0 0]);
xlim(domain(1,[1,3]));
ylim(domain(1,[2,4]));
% title('Triplanner generated path');
daspect([1 1.5 1.5]);

end