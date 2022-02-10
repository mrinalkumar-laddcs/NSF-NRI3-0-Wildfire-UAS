function UpdateFigureTemp(figNum,cmap,agent,conf,env,timeStamp,AgentSpeed,AgentEnergyMax,txtOffset)

nAgents = size(agent,1);
nConf   = size(conf,1);

%homeAgentLoc   = cell2mat({agent(:).currLoc}');
homeAgentLoc = reshape([agent.homeLoc]',[size(agent(1).homeLoc,2), nAgents])';
currAgentLoc = reshape([agent.currLoc]',[size(agent(1).currLoc,2), nAgents])';
targAgentLoc = reshape([agent.targLoc]',[size(agent(1).targLoc,2), nAgents])';
confLoc = reshape([conf.Loc]',[size(conf(1).Loc,2), nConf])';
confVal = reshape([conf.Val]',[size(conf(1).Val,1), nConf])';

h = figure(figNum);
% clf(h);
hold on
colormap(cmap);
p2 = pcolor(env.heatflux.X, env.heatflux.Y, env.heatflux.hfmean);
set(p2, 'EdgeColor','none');
colorbar;
hbar_2 = colorbar;

patch('faces',[1:4],'vertices',[env.dom.xMin env.dom.yMin; env.dom.xMin env.dom.yMax; env.dom.xMax, ...
    env.dom.yMax; env.dom.xMax env.dom.yMin], ...
    'FaceColor','w', ...
    'FaceAlpha',0, ...
    'EdgeColor',[.1,.1,.1], ...
    'LineWidth',0.5) ;

for i = 1:size(env.heatflux.hazardCell,1)
    plot(env.heatflux.hazardCell{i,3},'FaceColor',[0.9290 0.6940 0.1250],'FaceAlpha',0.1,...
        'EdgeColor','r','LineWidth',1.5);
end

% plot(homeAgentLoc(:,1),homeAgentLoc(:,2),'o','Linewidth',1,'MarkerSize',12,'Color',[0 0.4470 0.7410]);
% text(homeAgentLoc(:,1)-10,homeAgentLoc(:,2)+5,arrayfun(@num2str, 1:nAgents, 'UniformOutput', false));

scatter(confLoc(:,1), confLoc(:,2), 200*confVal(:,1),'MarkerFaceColor',[0 0.4470 0.7410],'MarkerFaceAlpha',0.3,'MarkerEdgeColor','black');
plot(confLoc(:,1),confLoc(:,2),'k.','Linewidth',1,'MarkerSize',12)
% text(confLoc(:,1)+txtOffset,confLoc(:,2)+txtOffset,arrayfun(@num2str, 1:nConf, 'UniformOutput', false))

% plot(currAgentLoc(:,1),currAgentLoc(:,2),'x','Linewidth',2,'MarkerSize',12,'Color',[0.4660 0.6740 0.1880])
% text(currAgentLoc(:,1)+txtOffset,currAgentLoc(:,2)+txtOffset,arrayfun(@num2str, 1:nAgents, 'UniformOutput', false))

% for k = 1:nAgents
%     % if the agent' is not at its and target location, then draw the path
%     if all(currAgentLoc(k,:) ~= targAgentLoc(k,:))
%         p_hand = plot(agent(k,1).fullPath(:,1),agent(k,1).fullPath(:,2),'k--','LineWidth',1.5);
%         p_hand.Color(4) = 0.5;
%         
%         if isempty(agent(k,1).remainPath)
%             flag = 1;
%         end
%         plot(agent(k,1).remainPath(:,1),agent(k,1).remainPath(:,2),'k-','LineWidth',1.5);
%     end
% end

xlim([env.dom.xMin, env.dom.xMax]);
ylim([env.dom.yMin, env.dom.yMax]);
daspect([1 1 1]);
hold off
xlabel('UTM Easting [m]');
ylabel('UTM Northing [m]');
ylabel(hbar_2, 'Mean Heat Flux [kWm^{-2}]','FontSize',12,'FontWeight','bold');
set(gca,'FontWeight','bold');
% title(['T = ',num2str(timeStamp,'%1.2f'),'mins, Speed = ',num2str(AgentSpeed),...
%     'm/s, Max Energy = ',num2str(AgentEnergyMax),'kJ']);
title(['T = ',num2str(timeStamp,'%1.2f'),'mins']);
hold off
pause(0.10);
end