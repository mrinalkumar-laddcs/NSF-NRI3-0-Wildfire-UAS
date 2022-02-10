
% tic
% homeAgentLoc = reshape([agent.homeLoc]',[size(agent(1).homeLoc,2), nAgents])';
% toc
% homeAgentLoc
% 
% 
% tic
% homeAgentLoc   = cell2mat({agent(:).currLoc}');
% toc
% homeAgentLoc


% clear all;close all; clc;
% figNum = figure;
% m = magic(3); % Make a 3-by-3 array.
% cmap = colormap('hot');
% for i = 1:5
% cmap = colormap('hot');
% figure(figNum);
% 
% colormap(flipud(cmap(20:end,:)));
% pcolor(m); % Attempt to display the 3-by-3 array.
% title('Only 2 by 2 array shown instead of 3 by 3');
% 
% pause(0.5);
% end