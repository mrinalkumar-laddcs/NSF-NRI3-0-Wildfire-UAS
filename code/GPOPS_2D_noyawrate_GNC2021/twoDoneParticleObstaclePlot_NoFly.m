%-------------------------------------------------------------------------%
%                             Extract Solution                            %
%-------------------------------------------------------------------------%
t_star  = solution(1).phase.time;
u_star = solution(1).phase.control(:,1);
X_star = solution(1).phase.state(:,1);
Y_star = solution(1).phase.state(:,2);
thetar_star = solution(1).phase.state(:,3);
X_guess  = guess(1).phase.state(:,1);
Y_guess  = guess(1).phase.state(:,2);

% Make the plots
figure;
set(gcf, 'Position', [50, 50, 700, 550]);
set(gcf,'color','w');
% h3 = plot(X_guess,Y_guess,':','LineWidth',1.2');
% h4 = plot(X_star,Y_star,'-x','LineWidth',1.5','Color',[0.4660 0.6740 0.1880]);


% [nodes,edges,polySize] = polgonReSizing(nodes,edges,polySize,-delta);
% nodesD = nodes;
% edgesD = edges;
% polySizeD = polySize;
% 
% n = 10;
% rDelta = linspace(5,0,n);
% alpha = 0.01;
% for i = 1:n
%     [nodesD,edgesD,polySizeD] = polgonReSizing(nodes,edges,polySize,rDelta(i));
%     patch('faces',edgesD(:,1:2),'vertices',nodesD, ...
%     'FaceColor','w', ...
%     'edgecolor',[0.9290 0.6940 0.1250],'edgealpha',alpha, ...
%     'linewidth',0.8) ;   
%     [nodesD,edgesD,polySizeD] = polgonReSizing(nodes,edges,polySize,-rDelta(i));
%     patch('faces',edgesD(:,1:2),'vertices',nodesD, ...
%     'FaceColor','w', ...
%     'edgecolor',[0.9290 0.6940 0.1250],'edgealpha',alpha, ...
%     'linewidth',0.8);
%     alpha = alpha + 0.025;
% end
% [nodes,edges,polySize] = polgonReSizing(nodes,edges,polySize,delta);
hold on
cmap = colormap('hot');
new_cmap = flipud(cmap(20:end,:));
hold on;
colormap(new_cmap);
if ~strcmp(heat_opt,'no fire')
    % contour(heatdata.X,heatdata.Y,heatdata.HF);
    p2 = pcolor(heatdata.X, heatdata.Y, heatdata.HF);
    set(p2, 'EdgeColor','none');
    
end
if obsEnable ~= 0
    patch('faces',faces,'vertices',nodes, ...
        'FaceColor','w', ...
        'FaceAlpha',0, ...
        'EdgeColor',[.1,.1,.1], ...
        'LineWidth',1.5) ;
end
h1 = plot(X0,Y0,'*','LineWidth',2');
h2 = plot(Xf,Yf,'*','LineWidth',2');
h3 = plot(X_guess,Y_guess,':','LineWidth',1.2');
h4 = plot(X_star,Y_star,'-.','LineWidth',1.5','Color',[0.4660 0.6740 0.1880]);

% legend([h1 h2 h3 h4],{'Initial Point', 'Final Point','Deterministic Constraint' ,'Optimal Path'});
legend([h1 h2 h3 h4],{'Initial Point', 'Final Point','Guess Path','Optimal Path'},'location','northwest');
xlabel('UTM Easting (m)');
ylabel('UTM Northing (m)');
xlim([xMin xMax]);
ylim([yMin yMax]);
daspect([1 1 1]);
grid on
box on

% if conservativeness == 1
% title('Robust Constraints');
% else
% title('Chance Constraints');
% end

% figure;
% plot(t_star,u_star,'-o');
% hold on
% grid on
% xlabel('Time,t');
% legend('u');
% xlim([0 max(t_star)]);
% ylim([min(u_star) max(u_star)]);
