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

% if constVel == 1
%     vehdata.V0   = 1;
%     vehdata.Vf   = 1;
%     vehdata.Vmin = 1;
%     vehdata.Vmax = 1;
%     vehdata.Amax = 0;
% else
%     vehdata.V0   = 0;
%     vehdata.Vf   = 0;
%     vehdata.Vmin = 0;
%     vehdata.Vmax = 1;
%     vehdata.Amax = 0.5;
% end
% vehdata.r_min = 2;
% delta = 1.2;
% heat_file = 'heatdata_toy.mat';
% heat_file = 'heatdata_toy2.mat';
% heat_file = 'heatdata_toy3.mat';
% heat_file = 'heatdata_toy4.mat';

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
% Ph    = 500; % W
% Pm    = 300/5; % W per 5m/s
Ph    = 0.6; % W
Pm    = 0.5/15; % W per 5m/s
heat_file = 'TaosFire.mat';


vehdata.T0    = 25;
vehdata.Tmin  = 25;
vehdata.Tmax  = vehdata.Tmin + 20;

if strcmp(heat_file,'TaosFire.mat')
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
else
    load(heat_file,'heatdata');
    xMin      =  0;   xMax      = 180;
    yMin      =  0;   yMax      = 170;
    
    bound = [xMin yMin; xMax yMin; xMax yMax; xMin yMax]; % coordinates of Bounding Box
    startPt = [90, 5];
    finalPt = [80, 145];
    %     finalPt = [50, 145];
    
    %     startPt = [80, 145];
    %     finalPt = [90, 5];
    if obsEnable == 1
        switch polyCase
            case 1
                polySize = [5 6]';
                %                 nodes = [40 30; 70 50; 80 100; 40 130; 20 120;
                %                     110 30; 140 50; 150 100; 110 130; 90 120; 75 60];
                nodes = [40 30; 70 50; 80 100; 40 130; 20 120;
                    110 30; 140 50; 150 100; 110 130; 95 120; 85 60];
                
            case 2
                polySize = [5 5]';
                nodes = [5 60; 35 60; 40 100; 20 130; 5 110;
                    140 70; 165 70; 170 100; 150 120; 135 100];
        end
        
        edges = [];
        offset = 0;
        for i = 1:size(polySize,1)
            edges_temp = offset+[(1:(polySize(i,1)-1))' (2:polySize(i,1))'; polySize(i,1) 1];
            edges = [edges; edges_temp];
            offset = sum(polySize(1:i,1));
        end
        
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

%---------------------------- End of Setup -------------------------------%

% Generate Raw environment Plot
% figNum = figure('color','w','position', [50, 50, 700, 550]);
figNum = figure('position', [50, 50, 700, 550]);
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
scatter(startPt(:,1),startPt(:,2),'filled','MarkerFaceColor',[0.4660    0.8740    0.3880],'MarkerEdgeColor','k');
scatter(finalPt(:,1),finalPt(:,2),'filled','MarkerFaceColor',[0.8500    0.3250    0.0980],'MarkerEdgeColor','k');
xlim([xMin xMax]);
ylim([yMin yMax]);
daspect([1 1 1]);
xlabel('UTM Easting [m]');
ylabel('UTM Northing [m]');
% ylabel(hbar_2, 'Mean Heat Flux [kWm^{-2}]','FontWeight','bold');
set(gca,'FontWeight','bold')
grid(gca,'on');
box(gca,'on');
hold off


% % [tri_mesh,guessGen] = polygonMesh(nodes,edges,polySize,startPt,finalPt,bound,vehdata,winddata);
% if strcmp(wind_opt,'no wind') || strcmp(wind_opt,'naive')
%     [grid_mesh,guessGen] = polygonGrid(nodes,edges,polySize,startPt,finalPt,bound,vehdata,winddata,'naive');
% else
%     [grid_mesh,guessGen] = polygonGrid(nodes,edges,polySize,startPt,finalPt,bound,vehdata,winddata,'wind-aware');
% end
% 
% % Generate Plots with Guess Path
% figure('color','w','Position', [200 80 500 350]);
% if mapEnable == 1
%     img = imread(imageFile);
%     imagesc([xMin xMax],[yMin yMax],flipud(img));
%     hold on;
%     if ~strcmp(wind_opt,'no wind')
%         quiver(winddata.X,winddata.Y,winddata.Wx,winddata.Wy);
%     end
%     patch('faces',faces,'vertices',nodes, ...
%         'FaceColor',[.1,.1,.1], 'FaceAlpha',0.1, ...
%         'edgecolor',[0.6350    0.0780    0.1840],'EdgeAlpha',0.6, ...
%         'linewidth',1.5) ;
%     %     'edgecolor',[.9,.3,.3],'EdgeAlpha',0.6, ...
%     patch('XData',[bound(:,1)'],'YData',[bound(:,2)'], ...
%         'FaceColor','none', ...
%         'edgecolor',[.1,.1,.1],'EdgeAlpha',0.6, ...
%         'linewidth',1.5) ;
%     plot(guessGen.x(:,1),guessGen.y(:,1),'r-','Linewidth',1.5);
%     xlabel('UTM Easting (m)');
%     ylabel('UTM Northing (m)');
%     set(gca,'ydir','normal');
% else
%     hold on; 
%     % ph = pcolor(winddata.X,winddata.Y,sqrt(winddata.Wx.^2 + winddata.Wy.^2));
%     % ph.EdgeColor = 'none';
%     % ph.FaceColor = 'interp';
%     % mesh(grid_mesh.xgrid,grid_mesh.ygrid,grid_mesh.inout-0.5,'EdgeColor','k','FaceAlpha',0);
%     if ~strcmp(wind_opt,'no wind')
%         quiver(winddata.X,winddata.Y,winddata.Wx,winddata.Wy);
%     end
%     patch('faces',faces,'vertices',nodes, ...
%         'FaceColor','w', ...
%         'EdgeColor',[.1,.1,.1], ...
%         'LineWidth',1.5);
%     plot(guessGen.x(:,1),guessGen.y(:,1),'r-','Linewidth',1.5);
%     xlabel('X');
%     ylabel('Y');
% end
% scatter(startPt(:,1),startPt(:,2),'filled','MarkerFaceColor',[0.4660    0.8740    0.3880]);
% scatter(finalPt(:,1),finalPt(:,2),'filled','MarkerFaceColor',[0.8500    0.3250    0.0980]);
% xlim([xMin xMax]);
% ylim([yMin yMax]);
% daspect([1 1 1]);
% box on

auxdata.V0    = vehdata.V0;
auxdata.Vmin  = vehdata.Vmin;
auxdata.Vmax  = vehdata.Vmax;
auxdata.r_min = vehdata.r_min;
auxdata.T0    = vehdata.T0;
auxdata.Tmin  = vehdata.Tmin;

auxdata.delta = delta;
auxdata.polySize = polySize;
auxdata.nodes = nodes;
auxdata.edges = edges;
auxdata.heatdata = heatdata;
auxdata.Ph    = Ph;
auxdata.Pm    = Pm;

% N = 1e3;
% samples = normrnd(-5,5/3,[1 N]);
% risk = 0.1;
% auxdata.samples = samples;
% auxdata.risk = risk;

%------------------------------%
%%% Given Initial Conditions %%%
%------------------------------%
t0  = 0;
theta0 = 'free';
% theta0 = 'fixed';
if strcmp(theta0,'free')
    thetar0 = [];
else
    % thetar0 = pi()/2;
    thetar0 = 9*pi()/8;
    % thetar0 = pi()/4;
end
X0 = startPt(1,1);
Y0 = startPt(1,2);
V0 = vehdata.V0;
T0 = vehdata.T0;

%-------------------------------%
%%% Given Final Conditions %%%
%-------------------------------%
% tf is free
thetaf = 'free';
% thetaf = 'fixed';
if strcmp(thetaf,'free')
    thetarf = [];
else
    thetarf = 3*pi()/4;
    % thetarf = pi()/45;
end
Xf = finalPt(1,1);
Yf = finalPt(1,2);
Vf = vehdata.Vf;

%-------------------------------------------------------------------------%
%---------------------- Provide Guess of Solution ------------------------%
%-------------------------------------------------------------------------%
% guessGen = guess_simplify(nodes,edges,guessGen);
guessGen.x = [X0,Xf]';
guessGen.y = [Y0,Yf]';
% guessGen.x = [X0,20, Xf]';
% guessGen.y = [Y0,(Y0+Yf)/2,Yf]';
% guessGen.x = [X0,10, 10, Xf]';
% guessGen.y = [Y0,(Y0+Yf)/5,4*(Y0+Yf)/5,Yf]';
% guessGen.x = linspace(X0,Xf,10)';
% guessGen.y = linspace(Y0,Yf,10)';

if strcmp(heat_file,'TaosFire.mat')
    guessGen.x = guessGen10.x;
    guessGen.y = guessGen10.y;
else
    guessGen.x = [X0,10, 10, Xf]';
    guessGen.y = [Y0,(Y0+Yf)/5,4*(Y0+Yf)/5,Yf]';
end

guess = generateGuess_mesh(guessGen,auxdata,thetar0,thetarf);

guess.phase.state = guess.phase.state(:,[1,2,4]);
guess.phase.control = guess.phase.control(:,2);

X_guess  = guess(1).phase.state(:,1);
Y_guess  = guess(1).phase.state(:,2);
Theta_guess = guess(1).phase.state(:,3);
run('twoDoneParticleObstaclePlotInitial');

%---------------------%
%%% Variable Ranges %%%
%---------------------%
tfMin     = 0;                           tfMax     = 1.5*guess.phase.time(end,1);
VMin      = vehdata.Vmin;                VMax      = vehdata.Vmax;
AMin      = -vehdata.Amax;               AMax      = vehdata.Amax;
thetarMin = -10*pi();                    thetarMax = 10*pi();
uMin      = -vehdata.Vmax/vehdata.r_min; uMax      = vehdata.Vmax/vehdata.r_min;
TMin      = vehdata.Tmin;                TMax      = vehdata.Tmax;


%-------------------------------------------------------------------------%
%----------------------- Setup for Problem Bounds ------------------------%
%-------------------------------------------------------------------------%
bounds.phase.initialtime.lower = t0;
bounds.phase.initialtime.upper = t0;
bounds.phase.finaltime.lower = tfMin;
bounds.phase.finaltime.upper = tfMax;
if strcmp(theta0,'free')
    bounds.phase.initialstate.lower = [X0, Y0, thetarMin];
    bounds.phase.initialstate.upper = [X0, Y0, thetarMax];
else
    bounds.phase.initialstate.lower = [X0, Y0, thetar0];
    bounds.phase.initialstate.upper = [X0, Y0, thetar0];
end
bounds.phase.state.lower = [xMin, yMin, thetarMin];
bounds.phase.state.upper = [xMax, yMax, thetarMax];
if strcmp(thetaf,'free')
    bounds.phase.finalstate.lower = [Xf, Yf, thetarMin];
    bounds.phase.finalstate.upper = [Xf, Yf, thetarMax];
else
    bounds.phase.finalstate.lower = [Xf, Yf, thetarf];
    bounds.phase.finalstate.upper = [Xf, Yf, thetarf];
end
bounds.phase.control.lower = uMin;
bounds.phase.control.upper = uMax;
if obsEnable ~= 0
    bounds.phase.path.lower = -1e6*ones(1,size(polySize,1));
    bounds.phase.path.upper = zeros(1,size(polySize,1));
%     bounds.phase.path.lower = [-1e6*ones(1,size(polySize,1)) 0];
%     bounds.phase.path.upper = [zeros(1,size(polySize,1)) 15];
end
% bounds.phase.integral.lower = [0, 0];
% bounds.phase.integral.upper = [1e8, 10];
bounds.phase.integral.lower = 0;
bounds.phase.integral.upper = 1e8;

%-------------------------------------------------------------------------%
%----------Provide Mesh Refinement Method and Initial Mesh ---------------%
%-------------------------------------------------------------------------%
% mesh.method          = 'hp-LiuRao';
% mesh.method          = 'hp-LiuRao-Legendre';
% mesh.method          = 'hp-DarbyRao';
mesh.method          = 'hp-PattersonRao';
% mesh.tolerance       = 1e-4;
% mesh.maxiterations   = 1;
mesh.tolerance       = 0.5*1e-3;
mesh.maxiterations   = 5;
mesh.colpointsmin    = 2;
mesh.colpointsmax    = 2;
N = size(guessGen.x,1);
% N = 20;
N = 80;
mesh.phase.colpoints = mesh.colpointsmin*ones(1,N);
mesh.phase.fraction  = ones(1,N)./N;

%-------------------------------------------------------------------------%
%------------- Assemble Information into Problem Structure ---------------%        
%-------------------------------------------------------------------------%
setup.name                           = 'oneDtwoParticleProblem';
setup.functions.continuous           = @twoDoneParticleObstacleContinuous_NoFly;
setup.functions.endpoint             = @twoDoneParticleObstacleEndpoint;
setup.displaylevel                   = 2;
setup.bounds                         = bounds;
setup.guess                          = guess;
setup.mesh                           = mesh;
setup.auxdata                        = auxdata;
setup.nlp.solver                     = 'ipopt';
% setup.nlp.solver                     = 'snopt';
setup.nlp.ipoptoptions.linear_solver = 'ma57';
setup.nlp.ipoptoptions.tolerance     = 1e-3;
setup.nlp.ipoptoptions.maxiterations = 200;
% setup.nlp.ipoptoptions.warmstart     = 1;
% setup.derivatives.supplier           = 'adigator';
setup.derivatives.supplier           = 'sparseCD';
% setup.derivatives.supplier           = 'sparseFD';
% setup.derivatives.derivativelevel    = 'second';
setup.derivatives.derivativelevel    = 'first';
setup.method                         = 'RPM-Differentiation';
% setup.method                         = 'RPM-Integration';

%-------------------------------------------------------------------------%
%---------------------- Solve Problem Using GPOPS2 -----------------------%
%-------------------------------------------------------------------------%
tic
output = gpops2(setup);
solution = output.result.solution;
toc

run('twoDoneParticleObstaclePlot_NoFly');

delta_t = [diff(t_star)];
dist = sum(V0*delta_t);

dTdt = interp2(heatdata.X,heatdata.Y,heatdata.HF,(X_star(1:end-1,1)+X_star(2:end,1))/2,(Y_star(1:end-1,1)+Y_star(2:end,1))/2)*0.024;
dT = dTdt.*delta_t;
T_star = [T0; (T0+cumsum(dT))];
cool_ind = dTdt <= 1e-3;
dTdt(cool_ind,1) = -0.00093.*(T_star(cool_ind,1)-TMin);
dT = dTdt.*delta_t;
T_star = [T0; (T0+cumsum(dT))];

E_hover  = Ph*delta_t;
E_motion = Pm*V0.*delta_t;
E = sum(E_hover + E_motion);

result.X_guess = X_guess;
result.Y_guess = Y_guess;
result.t_star = t_star;
result.X_star = X_star;
result.Y_star = Y_star;
result.T_star = T_star;
result.dist = dist;
result.E = E;
save('ComparisonResult_HeatAura','result');

% figure
% plot(guess.phase.time,guess.phase.state(:,3),'Linewidth',2);
% hold on
% plot(t_star,V_star,'Linewidth',2);
% grid on
% title('''Speed'' comparison');
% ylabel('Speed, V [m/s]');
% xlabel('Time, t [s]');

% figure
% plot(t_star,V_star,'Linewidth',2);
% grid on
% ylabel('Speed, V [m/s]');
% xlabel('Time, t [s]');

figure
plot(t_star,T_star,'Linewidth',2);
grid on
ylabel('Temp, T [deg C]');
xlabel('Time, t [s]');

figure
plot(guess.phase.time,guess.phase.control(:,1));
hold on
plot(t_star,u_star);
title('''Control'' comparison');
ylabel('Yaw rate, \omega [rad/s]');
xlabel('Time, t [s]');

figure
plot(guess.phase.time,guess.phase.state(1,3)+[0; cumsum((guess.phase.time(2:end,1)-guess.phase.time(1:end-1,1)).*guess.phase.control(2:end,1))]);
hold on
plot(t_star,thetar_star(1,1)+cumtrapz(t_star,u_star));
title('''Integrated Control = Heading'' Comparison');

% figure
% plot(guess.phase.time,guess.phase.state(:,3));
% hold on
% plot(t_star,thetar_star);
% title('''Heading'' comparison');

%-------------------------------------------------------------------------%
%--------------------------- Local Functions -----------------------------%
%-------------------------------------------------------------------------%
function guess = generateGuess(initial,final,auxdata,u0)
t0  = initial.t0;
thetar0 = initial.thetar0;
X0  = initial.X0;
Y0  = initial.Y0;

thetarf = final.thetarf;
Xf = final.Xf;
Yf = final.Yf;

V  = auxdata.V;
r_min = auxdata.r_min;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tf = sqrt((Xf-X0)^2+(Yf-Y0)^2)/V;

tspan = linspace(t0,tf,10)';
x(:,1) = linspace(X0,Xf,length(tspan))';
x(:,2) = linspace(Y0,Yf,length(tspan))';
x(:,3) = atan2(x(:,2),x(:,1))';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

guess.phase.time     = tspan;
guess.phase.state    = x;
guess.phase.control  = u0*ones(size(tspan));
end

function guess = generateGuess_mesh(guessGen,auxdata,thetar0,thetarf)
T0 = auxdata.T0;
V  = (auxdata.Vmin+auxdata.Vmax)/2;
r_min = auxdata.r_min;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% thetar_cmp = [atan2(guessGen.y(2:end,1)-guessGen.y(1:end-1,1),guessGen.x(2:end,1)-guessGen.x(1:end-1,1)); atan2(guessGen.y(end,1)-guessGen.y(end-1,1),guessGen.x(end,1)-guessGen.x(end-1,1))];
bias = 0.7;
if isempty(thetar0)
    thetar = zeros(size(guessGen.x,1),1);
    thetar(1,1) = atan2(guessGen.y(2,1)-guessGen.y(1,1),guessGen.x(2,1)-guessGen.x(1,1));
    if size(guessGen.x,1)>2
        for i = 2:size(guessGen.x,1)-1
            vec1 = [(guessGen.x(i,1)-guessGen.x(i-1,1)) (guessGen.y(i,1)-guessGen.y(i-1,1)) 0];
            vec2 = [(guessGen.x(i+1,1)-guessGen.x(i,1)) (guessGen.y(i+1,1)-guessGen.y(i,1)) 0];
            cross_prod = cross(vec1,vec2);
            thetar(i,1) = atan2(cross_prod(1,3),dot(vec1,vec2)) + thetar(i-1,1);
        end
    end
else
    guessGen.x = [guessGen.x(1,1); (bias*guessGen.x(1,1)+(1-bias)*guessGen.x(2,1)); guessGen.x(2:end,1)];
    guessGen.y = [guessGen.y(1,1); (bias*guessGen.y(1,1)+(1-bias)*guessGen.y(2,1)); guessGen.y(2:end,1)];
    thetar = zeros(size(guessGen.x,1),1);
    thetar(1,1) = thetar0;
    for i = 2:size(guessGen.x,1)-1
        if i <=2
            vec1 = [cos(thetar(1,1)) sin(thetar(1,1)) 0];
        else
            vec1 = [(guessGen.x(i,1)-guessGen.x(i-1,1)) (guessGen.y(i,1)-guessGen.y(i-1,1)) 0];
        end
            vec2 = [(guessGen.x(i+1,1)-guessGen.x(i,1)) (guessGen.y(i+1,1)-guessGen.y(i,1)) 0];
        cross_prod = cross(vec1,vec2);
        thetar(i,1) = atan2(cross_prod(1,3),dot(vec1,vec2)) + thetar(i-1,1);
    end
end

if isempty(thetarf)
    thetar(end,1) = thetar(end-1,1);
else
    if abs(rem(thetar(end-1,1),2*pi())-thetarf)>pi
        thetar(end,1) = ceil(thetar(end-1,1)/(2*pi()))*2*pi + thetarf;
    else
        thetar(end,1) = (ceil(thetar(end-1,1)/(2*pi()))-1)*2*pi + thetarf;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t_delta_steps = sqrt((guessGen.x(2:end,1)-guessGen.x(1:end-1,1)).^2+(guessGen.y(2:end,1)-guessGen.y(1:end-1,1)).^2)/V;
t_steps = [0;cumsum(t_delta_steps)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% thetar = [atan2(guessGen.y(2:end,1)-guessGen.y(1:end-1,1),guessGen.x(2:end,1)-guessGen.x(1:end-1,1)); atan2(guessGen.y(end,1)-guessGen.y(end-1,1),guessGen.x(end,1)-guessGen.x(end-1,1))];
% 
% thetar(thetar>2*pi) = thetar(thetar>2*pi) - 2*pi;
% thetar(thetar<0) = thetar(thetar<0) + 2*pi;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
guess.phase.time         = t_steps;
guess.phase.state        = [guessGen.x, guessGen.y, V*ones(size(guessGen.x)), thetar, T0*ones(size(guessGen.x))];
guess.phase.control      = [0, 0; diff(guess.phase.state(:,3)), (thetar(2:end,1)-thetar(1:end-1,1))./t_delta_steps];
guess.phase.control(1,2) = guess.phase.control(2,2);
% guess.phase.integral     = [0 0];
guess.phase.integral     = 0;
end