clear all; close all; clc;

mode = 'poly';
% mode = 'map'

unc_mode = 'risk';
% unc_mode = 'bound';

polyCase = 1;
polyCase = 4;

% conservativeness = 0;
conservativeness = 1;

load_file = ['Result','_',mode];
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
plot(risk_reward(:,1),risk_reward(:,2),'-o');
xlabel('risk');
ylabel('J');

figure;
plot(risk_reward(:,1),risk_reward(:,2) + 500*risk_reward(:,1),'-o');
xlabel('risk');
ylabel('J + k\epsilon');

cost_diff = diff(risk_reward(:,2));
risk_diff = diff(risk_reward(:,1));

figure;
plot(risk_reward(2:end,1),cost_diff./risk_diff,'-o');
xlabel('risk');
ylabel('dJ/d\epsilon');

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
    
    if num_paths>1
        risk_vec = risk.low:risk.step:risk.low+(num_paths-1)*risk.step;
        offset = 1; total = 11;
        risk_vec_new = risk_vec(1,1+offset:end-(size(risk_vec,2)-total-offset));
        cmap = colormap(cool(size(risk_vec_new,2)));
        for i = 1:total % 1:num_paths
%             if i ~= 2 & i ~= 13 & i ~= 14
                disp(i+offset);
            plot(path(i+offset).X_star(:,1),path(i+offset).Y_star(:,1),'LineWidth',1,'Color',[cmap(i,:)]);
%             end
        end
        c = colorbar('location','eastoutside','TickLabels',num2str(risk_vec_new'));
        c.Label.String = 'Risk';
        c.Label.FontWeight = 'bold';
    else
    end
    legend([h1 h2],{'Initial Point', 'Final Point'},'location','northwest');
    title('Chance-constrainted Scenario');
else
    patch('faces',edges(:,1:2),'vertices',nodes, ...
    'FaceColor','w', ...
    'edgecolor',[0.8500 0.3250 0.0980],'edgealpha',0.3, ...
    'linewidth',1.5) ;

%     patch('faces',edgesD(:,1:2),'vertices',nodesD, ...
%     'FaceColor','w', ...
%     'edgecolor',[0.8500 0.3250 0.0980],'edgealpha',0.3, ...
%     'linewidth',1.5) ;
    [nodesD,edgesD,polySizeD] = polgonReSizing(nodes,edges,polySize,-bnd.upp);
    patch('faces',edgesD(:,1:2),'vertices',nodesD, ...
    'FaceColor','w', ...
    'edgecolor',[.1,.1,.1],'edgealpha',1, ...
    'linewidth',1) ;
    h3 = plot(path(1).X_star(:,1),path(1).Y_star(:,1),'LineWidth',1,'Color',[0.4660 0.6740 0.1880]);
    legend([h1 h2 h3],{'Initial Point', 'Final Point','Optimal Path'},'location','northwest');
    title('Robust Scenario');
end

% grid on
xlabel('X');
ylabel('Y');
xlim([xMin xMax]);
ylim([yMin yMax]);
daspect([1 1 1]);

% % print(gcf,'Chance','-dpng','-r1200')
