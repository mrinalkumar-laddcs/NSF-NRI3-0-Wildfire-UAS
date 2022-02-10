clear all; close all; clc;

%---------------------------- Problem Setup ------------------------------%
% Node and Edge List
% Edge should be counter-clockwise as the region right of the edge is allowed

obsEnable = 1;
constVel = 1;
polyCase = 2;
conservativeness = 0;

% heat_opt = 'no fire';    % 'no fire', 'naive', 'heat-aware'
% heat_opt = 'naive';      % 'no fire', 'naive', 'heat-aware'
heat_opt = 'heat-aware'; % 'no fire', 'naive', 'heat-aware'

if constVel == 1
    vehdata.V0   = 12;
    vehdata.Vf   = 12;
    vehdata.Vmin = 12;
    vehdata.Vmax = 12;
    vehdata.Amax = 12;
else
    vehdata.V0   = 0;
    vehdata.Vf   = 0;
    vehdata.Vmin = 0;
    vehdata.Vmax = 12;
    vehdata.Amax = 2;
end
vehdata.r_min = 5;
delta = 2;
Ph    = 0.6; % kW
Pm    = 0.5/15; % kW per 15m/s
heat_file = 'TaosFire.mat';


vehdata.T0    = 25;
vehdata.Tmin  = 25;
vehdata.Tmax  = vehdata.Tmin + 20;

load(heat_file);
heatdata.X  = env.heatflux.X;
heatdata.Y  = env.heatflux.Y;
heatdata.HF = env.heatflux.hfmean;

xMin      =  env.dom.xMin;   xMax      = env.dom.xMax;
yMin      =  env.dom.yMin;   yMax      = env.dom.xMax;
bound = [xMin yMin; xMax yMin; xMax yMax; xMin yMax]; % coordinates of Bounding Box
startPt = [150, 350];
finalPt = [1633, 1786];

if obsEnable == 1
    nodes = [];
    for i = 1:size(env.heatflux.hazardCell,1)
        nodes = [nodes; env.heatflux.hazardCell{i,3}.Vertices];
        k = convhull(nodes(:,1),nodes(:,2));
        nodes = nodes(k,:);
        polySize(i,1) = size(nodes,1);
    end
    
    edges = [];
    offset = 0;
    for i = 1:size(polySize,1)
        edges_temp = offset+[(1:(polySize(i,1)-1))' (2:polySize(i,1))'; polySize(i,1) 1];
        edges = [edges; edges_temp];
        offset = sum(polySize(1:i,1));
    end
end

    
if obsEnable == 1
    faces = [];
    offset = 0;
    for i = 1:size(polySize,1)
        faces_temp = offset+ [(1:polySize(i,1)), NaN*ones(1,max(polySize)-polySize(i,1))] ;
        faces = [faces; faces_temp];
        offset = sum(polySize(1:i,1));
    end
    if conservativeness == 1
        [nodes,edges,polySize] = polgonReSizing(nodes,edges,polySize,delta);
    end
else
    nodes    = [];
    edges    = [];
    polySize = [];
end

load('ComparisonResult_TempCon','result');
result_tempcon = result;
load('ComparisonResult_HeatAura','result');
result_heataura = result;

%---------------------------- End of Setup -------------------------------%

% Generate Raw environment Plot
figNum = figure('position', [50, 50, 600, 500]);
cmap = colormap('hot');
new_cmap = flipud(cmap(20:end,:));
hold on;
colormap(new_cmap);

colorbar;
hbar_2 = colorbar;

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

patch('faces',[1:4],'vertices',[env.dom.xMin env.dom.yMin; env.dom.xMin 2000; 2000, 2000; 2000 env.dom.yMin], ...
    'FaceColor','w', ...
    'FaceAlpha',0, ...
    'EdgeColor',[.1,.1,.1], ...
    'LineWidth',0.5) ;

h1 = scatter(startPt(:,1),startPt(:,2),'filled','MarkerFaceColor',[0.4660    0.8740    0.3880],'MarkerEdgeColor','k');
h2 = scatter(finalPt(:,1),finalPt(:,2),'filled','MarkerFaceColor',[0.8500    0.3250    0.0980],'MarkerEdgeColor','k');

h3 = plot(result_heataura.X_star,result_heataura.Y_star,':','LineWidth',1.5','Color',[0.4940 0.1840 0.5560]);
h4 = plot(result_tempcon.X_star,result_tempcon.Y_star,'--','LineWidth',1.5','Color',[0.4660 0.6740 0.1880]);

% xlim([xMin xMax]);
% ylim([yMin yMax]);

xlim([xMin 2000]);
ylim([yMin 2000]);
daspect([1 1 1]);
xlabel('UTM Easting [m]');
ylabel('UTM Northing [m]');
ylabel(hbar_2, 'Mean Heat Flux [kWm^{-2}]','FontSize',12,'FontWeight','bold');
legend([h1 h2 h3 h4],{'Start Point', 'Final Point',['HEZ (' num2str(result_heataura.dist,'%0.1f') 'm, '...
    num2str(result_heataura.E,'%0.1f') 'kJ)'],['TC (' num2str(result_tempcon.dist,'%0.1f') 'm, '...
    num2str(result_tempcon.E,'%0.1f') 'kJ)']},'location','northwest');
set(gca,'FontWeight','bold')
grid(gca,'on');
box(gca,'on');
hold off


figNum2 = figure('position', [50, 50, 600, 350]);
hold on;
plot(result_heataura.t_star,vehdata.Tmin*ones(size(result_heataura.t_star)),'Linewidth',1.5);
plot(result_heataura.t_star,vehdata.Tmax*ones(size(result_heataura.t_star)),'Linewidth',1.5);
plot(result_heataura.t_star,result_heataura.T_star,':','Linewidth',2,'Color',[0.4940 0.1840 0.5560]);
plot(result_tempcon.t_star,result_tempcon.T_star,'--','Linewidth',2,'Color',[0.4660 0.6740 0.1880]);
grid on
ylabel('Temperature, T [deg C]');
xlabel('Time, t [s]');
ylim([vehdata.Tmin-3 vehdata.Tmax+3]);
legend('T_{min}','T_{max}','HEZ','TC','location','east');
set(gca,'FontWeight','bold')
box on;
hold off;
