delta = 0;
run('twoDoneParticleObstacleMain_for.m');

figure;
set(gcf, 'Position', [700 80 500 350]);
set(gcf,'color','w');
h1 = plot(X0,Y0,'*','LineWidth',2');
hold on
h2 = plot(Xf,Yf,'*','LineWidth',2');
patch('faces',edges(:,1:2),'vertices',nodes, ...
    'FaceColor','w', ...
    'edgecolor',[.1,.1,.1],'edgealpha',1, ...
    'linewidth',1.5) ;
legend([h1 h2],{'Initial Point', 'Final Point'},'location','northwest');
xlabel('X');
ylabel('Y');
xlim([xMin xMax]);
ylim([yMin yMax]);
daspect([1 1 1]);
title('Mean Boundaries');


% Probab Case
nodesD = nodes;
edgesD = edges;
polySizeD = polySize;

figure;
set(gcf, 'Position', [700 80 500 350]);
set(gcf,'color','w');
h1 = plot(X0,Y0,'*','LineWidth',2');
hold on
h2 = plot(Xf,Yf,'*','LineWidth',2');
n = 10;
rDelta = linspace(5,0,n);
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
xlabel('X');
ylabel('Y');
xlim([xMin xMax]);
ylim([yMin yMax]);
daspect([1 1 1]);
title('Chance-constrainted Scenario');

% Robust Case
[nodesD,edgesD,polySizeD] = polgonReSizing(nodes,edges,polySize,bnd.upp);
figure;
set(gcf, 'Position', [700 80 500 350]);
set(gcf,'color','w');
h1 = plot(X0,Y0,'*','LineWidth',2');
hold on
h2 = plot(Xf,Yf,'*','LineWidth',2');
% patch('faces',edgesD(:,1:2),'vertices',nodesD, ...
%     'FaceColor','w', ...
%     'edgecolor',[.1,.1,.1],'edgealpha',1, ...
%     'linewidth',1.5) ;

patch('faces',edgesD(:,1:2),'vertices',nodesD, ...
    'FaceColor','w', ...
    'edgecolor',[0.8500 0.3250 0.0980],'edgealpha',0.3, ...
    'linewidth',1.5) ;

patch('faces',edges(:,1:2),'vertices',nodes, ...
    'FaceColor','w', ...
    'edgecolor',[.1,.1,.1],'edgealpha',1, ...
    'linewidth',1) ;
legend([h1 h2],{'Initial Point', 'Final Point'},'location','northwest');
xlabel('X');
ylabel('Y');
xlim([xMin xMax]);
ylim([yMin yMax]);
daspect([1 1 1]);
title('Robust Scenario');

a = 1
% % print(gcf,'Chance','-dpng','-r1200')