%-------------- Reduced Switching Time Optimization Prob -----------------%
%-------------------------------------------------------------------------%
clear all; close all; clc;

%-------------------------------------------------------------------------%
%----------------- Provide All Bounds for Problem ------------------------%
%-------------------------------------------------------------------------%

%---------------------%
%%% Given Constants %%%
%---------------------%
% Node and Edge List
% Edge should be counter-clockwise as the region right of the edge is
% allowed


mapEnable = 0;
polyCase = 1;


V     = 10;
umax  = 1;
r_min = 1;
% delta = -1;
delta = 5;

if mapEnable == 1
    V     = 10;
    umax  = 1;
%     r_min = 1800;
    r_min = 200;
    delta = -1;
end

if mapEnable == 1
    [nodes,edges,polySize,startPt,finalPt,bound,guessGen] = mapMesh;
else
    switch polyCase
        case 1
            polySize = [5 6]';
            nodes = [40 30; 70 50; 80 100; 40 130; 20 120;
                110 30; 140 50; 150 100; 110 130; 90 120; 75 60];
            
        case 2
            polySize = [7 6]';
            nodes = [40 30; 80 40; 70 70; 80 90; 80 100; 40 130; 20 120;
                110 30; 140 50; 150 100; 110 130; 90 120; 75 60];
            
        case 3
            polySize = [5]';
            nodes = [40 30; 70 50; 80 100; 40 130; 20 120];
    end
       
    edges = [];
    offset = 0;
    for i = 1:size(polySize,1)
        edges_temp = offset+[(1:(polySize(i,1)-1))' (2:polySize(i,1))'; polySize(i,1) 1];
        edges = [edges; edges_temp];
        offset = sum(polySize(1:i,1));
    end
    xMin      =  -5;   xMax      = 180;
    yMin      =  0;     yMax      = 170;
%     [nodes,edges,polySize] = polgonReSizing(nodes,edges,polySize,delta);
    [nodes,edges,polySize,startPt,finalPt,bound,guessGen] = polygonMesh(nodes,edges,polySize,xMin,xMax,yMin,yMax);
end

auxdata.V     = V;
auxdata.r_min = r_min;
auxdata.delta = delta;
auxdata.polySize = polySize;
auxdata.nodes = nodes;
auxdata.edges = edges;

% N = 1e3;
% samples = normrnd(-5,5/3,[1 N]);
% risk = 0.1;
% auxdata.samples = samples;
% auxdata.risk = risk;

%------------------------------%
%%% Given Initial Conditions %%%
%------------------------------%
t0  = 0;
thetar0 = pi()/2;
% thetar0 = pi()/4;
% X0  = 90;
% Y0  = 5;
% X0  = 60;
% Y0  = 50;
% X0  = 140;
% Y0  = 20;
% if mapEnable == 1
% X0 = startPt(1,1);
% Y0 = startPt(1,2);
% end

X0 = startPt(1,1);
Y0 = startPt(1,2);

%-------------------------------%
%%% Given Final Conditions %%%
%-------------------------------%
% tf is free
thetarf = pi()/45;
% Xf = 60;
% Yf = 150;
% Xf = 60;
% Yf = 100;
% Xf = 20;
% Yf = 140;
% if mapEnable == 1
% Xf = finalPt(1,1);
% Yf = finalPt(1,2);
% end

Xf = finalPt(1,1);
Yf = finalPt(1,2);

%---------------------%
%%% Variable Ranges %%%
%---------------------%
tfMin     =  0;     tfMax     = 100;
% xMin      =  -5;   xMax      = 180;
% yMin      =  0;     yMax      = 170;
% thetarMin = -pi();  thetarMax = pi();
% uMin      = -umax;  uMax      = umax;

if mapEnable == 1
tfMin     =  0;     tfMax     = 1000;
end

xMin      =  min(bound(:,1));   xMax      = max(bound(:,1));
yMin      =  min(bound(:,2));   yMax      = max(bound(:,2));
thetarMin = -pi();  thetarMax = pi();
uMin      = -umax;  uMax      = umax;

%-------------------------------------------------------------------------%
%---------------------- Provide Guess of Solution ------------------------%
%-------------------------------------------------------------------------%
tfGuess = 10;
% u0 = 1;
u0 = 0;
uf = 0;
% guess.phase.time     = [t0; tfGuess];
% guess.phase.state    = [X0, Y0, thetar0; Xf, Yf, thetarf];
% guess.phase.control  = [u0; uf];
% % guess.phase.integral  = 0;

% guess.phase.time     = [t0; tfGuess/2; tfGuess];
% guess.phase.state    = [X0, Y0, thetar0; 20, 80, 0; Xf, Yf, thetarf];
% guess.phase.control  = [u0; uf/2; uf];

% guess.phase.time     = [t0; tfGuess];
% guess.phase.state    = [X0, Y0, thetar0; Xf, Yf, thetarf];
% guess.phase.control  = [u0; uf];

% if mapEnable == 1
%     tfGuess = 100;
%     guess.phase.time     = linspace(t0,tfGuess,size(guessGen.x,1))';
%     guess.phase.state    = [guessGen.x, guessGen.y, linspace(thetar0,thetarf,size(guessGen.x,1))'];
%     guess.phase.control  = u0*ones(size(guessGen.x,1),1);
% end

tfGuess = 100;
guess.phase.time     = linspace(t0,tfGuess,size(guessGen.x,1))';
guess.phase.state    = [guessGen.x, guessGen.y, linspace(thetar0,thetarf,size(guessGen.x,1))'];
guess.phase.control  = u0*ones(size(guessGen.x,1),1);

% initial.t0 = t0;
% initial.X0 = X0;
% initial.Y0 = Y0;
% initial.thetar0 = thetar0;
% 
% final.Xf = Xf;
% final.Yf = Yf;
% final.thetarf = thetarf;
% 
% guess = generateGuess(initial,final,auxdata,u0,tfMax);

run('twoDoneParticleObstaclePlotInitial')

% [nodes,edges,polySize] = polgonReSizing(nodes,edges,polySize,delta);
% 
% poly1 = polyshape(nodes(1:5,1),nodes(1:5,2));
% poly2 = polyshape(nodes(6:11,1),nodes(6:11,2));
% polyout = union(poly1,poly2)
% 
% run('twoDoneParticleObstaclePlotInitial')

%-------------------------------------------------------------------------%
%----------------------- Setup for Problem Bounds ------------------------%
%-------------------------------------------------------------------------%
bounds.phase.initialtime.lower = t0;
bounds.phase.initialtime.upper = t0;
bounds.phase.finaltime.lower = tfMin;
bounds.phase.finaltime.upper = tfMax;
% bounds.phase.initialstate.lower = [X0, Y0, thetar0];
% bounds.phase.initialstate.upper = [X0, Y0, thetar0];
bounds.phase.initialstate.lower = [X0, Y0, thetarMin];
bounds.phase.initialstate.upper = [X0, Y0, thetarMax];
bounds.phase.state.lower = [xMin, yMin, thetarMin];
bounds.phase.state.upper = [xMax, yMax, thetarMax];
% bounds.phase.finalstate.lower = [Xf, Yf, thetarf];
% bounds.phase.finalstate.upper = [Xf, Yf, thetarf];
bounds.phase.finalstate.lower = [Xf, Yf, thetarMin];
bounds.phase.finalstate.upper = [Xf, Yf, thetarMax];
bounds.phase.control.lower = uMin;
bounds.phase.control.upper = uMax;
% bounds.phase.integral.lower = 0;
% bounds.phase.integral.upper = 1e8;
% bounds.phase.path.lower = [0, 0, 0];
% bounds.phase.path.upper = [0, umax^2, 1e6];
% bounds.phase.path.lower = [0, 0];
% bounds.phase.path.upper = [0, umax^2];
% bounds.phase.path.lower = 0;
% bounds.phase.path.upper = 0;
% bounds.phase.path.lower = [0, 0];
% bounds.phase.path.upper = [1e6, 1e6];

bounds.phase.path.lower = -1e6*ones(1,size(polySize,1));
bounds.phase.path.upper = zeros(1,size(polySize,1));

% bounds.phase.path.lower = [0, 0];
% bounds.phase.path.upper = [risk, 1e6];

%-------------------------------------------------------------------------%
%----------Provide Mesh Refinement Method and Initial Mesh ---------------%
%-------------------------------------------------------------------------%
% mesh.method          = 'hp-LiuRao';
% mesh.method          = 'hp-LiuRao-Legendre';
% mesh.method          = 'hp-DarbyRao';
mesh.method          = 'hp-PattersonRao';
mesh.tolerance       = 1e-4;
mesh.maxiterations   = 5;
mesh.colpointsmin    = 2;
mesh.colpointsmax    = 15;
% N = 200;
% mesh.phase.colpoints = 4*ones(1,N);
% mesh.phase.fraction  = ones(1,N)./N;

% mesh.method          = 'hp-PattersonRao';
% mesh.tolerance       = 1e-6;
% mesh.maxiterations   = 20;
% mesh.colpointsmin    = 4;
% mesh.colpointsmax    = 10;
% mesh.phase.colpoints = 4;

%-------------------------------------------------------------------------%
%------------- Assemble Information into Problem Structure ---------------%        
%-------------------------------------------------------------------------%
setup.name                           = 'oneDtwoParticleProblem';
setup.functions.continuous           = @twoDoneParticleObstacleContinuous;
setup.functions.endpoint             = @twoDoneParticleObstacleEndpoint;
setup.displaylevel                   = 2;
setup.bounds                         = bounds;
setup.guess                          = guess;
setup.mesh                           = mesh;
setup.auxdata                        = auxdata;
setup.nlp.solver                     = 'ipopt';
% setup.nlp.solver                     = 'snopt';
setup.nlp.ipoptoptions.linear_solver = 'ma57';
setup.nlp.ipoptoptions.tolerance     = 1e-6;
setup.nlp.ipoptoptions.maxiterations = 2000;
% setup.derivatives.supplier           = 'adigator';
setup.derivatives.supplier           = 'sparseFD';
% setup.derivatives.derivativelevel    = 'second';
setup.derivatives.derivativelevel    = 'first';
% setup.adigatorgrd.continuous         = @twoDoneParticleObstacleContinuousADiGatorGrd
% setup.adigatorgrd.endpoint           = @twoDoneParticleObstacleEndpointADiGatorGrd
% setup.adigatorhes.continuous         = @twoDoneParticleObstacleContinuousADiGatorHes
% setup.adigatorhes.endpoint           = @twoDoneParticleObstacleEndpointADiGatorHes
% setup.derivatives.supplier           = 'sparseCD';
% setup.derivatives.derivativelevel    = 'second';
setup.method                         = 'RPM-Differentiation';
% setup.method                         = 'RPM-Integration';

%-------------------------------------------------------------------------%
%---------------------- Solve Problem Using GPOPS2 -----------------------%
%-------------------------------------------------------------------------%
tic
output = gpops2(setup);
solution = output.result.solution;
toc

run('twoDoneParticleObstaclePlot');

%-------------------------------------------------------------------------%
%--------------------------- Local Functions -----------------------------%
%-------------------------------------------------------------------------%
function guess = generateGuess(initial,final,auxdata,u0,tfGuess)
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

tspan = linspace(t0,tf,100)';
x(:,1) = linspace(X0,Xf,length(tspan))';
x(:,2) = linspace(Y0,Yf,length(tspan))';
x(:,3) = atan2(x(:,2),x(:,1))';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Xi = (X0+Xf)/2 - 40;
% Yi = (Y0+Yf)/2;
% tf1 = sqrt((Xi-X0)^2+(Yi-Y0)^2)/V;
% tf2 = sqrt((Xf-Xi)^2+(Yf-Yi)^2)/V;
% tspan1 = linspace(t0,tf1,51)';
% tspan2 = linspace(tf1,tf1+tf2,51)';
% tspan  = [tspan1; tspan2(2:end)];
% x1 = linspace(X0,Xi,length(tspan1))'; 
% x2 = linspace(Xi,Xf,length(tspan2))';
% y1 = linspace(Y0,Yi,length(tspan1))';
% y2 = linspace(Yi,Yf,length(tspan2))';
% x(:,1) = [x1; x2(2:end)];
% x(:,2) = [y1; y2(2:end)];
% x(:,3) = atan2(x(:,2),x(:,1))';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

guess.phase.time     = tspan;
guess.phase.state    = x;
guess.phase.control  = u0*ones(size(tspan));
end

% function guess = generateGuess(initial,final,auxdata,u0,tfGuess)
% t0  = initial.t0;
% thetar0 = initial.thetar0;
% X0  = initial.X0;
% Y0  = initial.Y0;
% 
% thetarf = final.thetarf;
% Xf = final.Xf;
% Yf = final.Yf;
% 
% V  = auxdata.V;
% r_min = auxdata.r_min;
% 
% odefunc = @(t,y) final_detect(t,y,final);
% ode_options = odeset('RelTol', 1e-5, 'AbsTol', 1e-6,'Events',odefunc);
% % ode_options = odeset('Events',odefunc);
% [tspan, x] = ode45(@(t,x) [V*cos(x(3,:)); V*sin(x(3,:)); u0.*V./r_min], [t0 tfGuess],[X0, Y0, thetar0]', ode_options);
% 
% guess.phase.time     = tspan;
% guess.phase.state    = x;
% guess.phase.control  = u0*ones(size(tspan));
% end
% 
% function [value,isterminal,direction] = final_detect(t,y,final)
% thetarf = final.thetarf;
% Xf = final.Xf;
% Yf = final.Yf;
% 
% value = y(3,1)-thetarf;
% isterminal = 1;
% direction = 0;
% end