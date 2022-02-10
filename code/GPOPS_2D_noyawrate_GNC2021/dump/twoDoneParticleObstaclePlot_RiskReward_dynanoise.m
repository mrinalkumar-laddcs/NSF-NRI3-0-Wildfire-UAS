clear all; close all; clc;

mode = 'poly';
% mode = 'map'

unc_mode = 'risk';
% unc_mode = 'bound';

polyCase = 1;
% polyCase = 4;

% conservativeness = 0;
conservativeness = 1;

load_file = ['Result_dyna_',mode];
if strcmp(mode,'map')
else
    load_file = [load_file,num2str(polyCase)];
end
load_file = [load_file,'_',unc_mode];
load(load_file);

thetar_end = zeros(size(path,2),1);
thetar_start = zeros(size(path,2),1);
risk_reward = zeros(size(path,2),2);
for i=1:size(path,2)
    thetar_start(i,1) = path(i).thetar_star(1,1);
    thetar_end(i,1) = path(i).thetar_star(end,1);
    risk_reward(i,:) = [risk.values(i) round(path(i).t_star(end,1),3)];
end

figure;
set(gcf, 'Position', [700 80 500 350]);
set(gcf,'color','w');
h1 = plot(X0,Y0,'*','LineWidth',2');
hold on
h2 = plot(Xf,Yf,'*','LineWidth',2');

if strcmp(unc_mode,'risk')
    num_paths = size(path,2);
    
    [nodes,edges,polySize] = polgonReSizing(nodes,edges,polySize,-delta);
    nodesD = nodes;
    edgesD = edges;
    polySizeD = polySize;
    
    n = 10;
    rDelta = linspace(4,0,n);
    alpha = 0.01;
    for i = 1:n
        [nodesD,edgesD,polySizeD] = polgonReSizing(nodes,edges,polySize,rDelta(i));
        patch('faces',edgesD(:,1:2),'vertices',nodesD, ...
            'FaceColor','w', ...
            'edgecolor',[0.9290 0.6940 0.1250],'edgealpha',alpha, ...
            'linewidth',0.8) ;
        [nodesD,edgesD,polySizeD] = polgonReSizing(nodes,edges,polySize,-rDelta(i));
        patch('faces',edgesD(:,1:2),'vertices',nodesD, ...
            'FaceColor','w', ...
            'edgecolor',[0.9290 0.6940 0.1250],'edgealpha',alpha, ...
            'linewidth',0.8);
        alpha = alpha + 0.025;
    end
    [nodes,edges,polySize] = polgonReSizing(nodes,edges,polySize,delta);
    
    if num_paths>=1
        risk_vec = risk.low:risk.step:risk.low+(num_paths-1)*risk.step;
        for i=1:num_paths
            h = plot(path(i).X_star(:,1),path(i).Y_star(:,1),'LineWidth',1,'Color','k');
            h.Color = [0,0,0,1];
        end
    else
    end
    legend([h1 h2],{'Initial Point', 'Final Point'},'location','northwest');
    title('Chance-constrainted Scenario');
else
end

% grid on
xlabel('X');
ylabel('Y');
xlim([xMin xMax]);
ylim([yMin yMax]);
daspect([1 1 1]);

% % print(gcf,'Chance','-dpng','-r1200')
