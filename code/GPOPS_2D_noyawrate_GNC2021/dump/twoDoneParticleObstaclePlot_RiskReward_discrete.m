clear all; close all; clc;

mode = 'poly';
% mode = 'map'

% unc_mode = 'risk';
unc_mode = 'bound';

polyCase = 1;
% polyCase = 4;

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
set(gcf, 'Position', [700 80 500 350]);
set(gcf,'color','w');
h1 = plot(X0,Y0,'*','LineWidth',2');
hold on
h2 = plot(Xf,Yf,'*','LineWidth',2');

h5 = patch('faces',edges(:,1:2),'vertices',nodes, ...
    'FaceColor',[.1,.1,.1],'Facealpha',0.3,...
    'edgecolor',[.1,.1,.1],'edgealpha',0.9, ...
    'linewidth',1.5) ;

%     patch('faces',edgesD(:,1:2),'vertices',nodesD, ...
%     'FaceColor','w', ...
%     'edgecolor',[0.8500 0.3250 0.0980],'edgealpha',0.3, ...
%     'linewidth',1.5) ;
% [nodesD,edgesD,polySizeD] = polgonReSizing(nodes,edges,polySize,-bnd.upp);
% patch('faces',edgesD(:,1:2),'vertices',nodesD, ...
%     'FaceColor','w', ...
%     'edgecolor',[.1,.1,.1],'edgealpha',1, ...
%     'linewidth',1);

h3 = plot(path(1).X_star(:,1),path(1).Y_star(:,1),'*','LineWidth',1,'Color',[0.6350 0.0780 0.1840]);

t_vec = linspace(path(1).t_star(1,1),path(1).t_star(end,1),100)';
X_interp = interp1(path(1).t_star,path(1).X_star(:,1),t_vec);
Y_interp = interp1(path(1).t_star,path(1).Y_star(:,1),t_vec);
h4 = plot(X_interp,Y_interp,'+','LineWidth',1,'Color',[0 0.4470 0.7410]);
legend([h5 h3 h4],{'Equivalent Deterministic Boundary','Coarse Discretization','Fine Discretization'},'location','northwest');

grid on
xlabel('X');
ylabel('Y');
xlim([130 145]);
ylim([43 58]);
daspect([1 1 1]);

% % print(gcf,'Chance','-dpng','-r1200')
