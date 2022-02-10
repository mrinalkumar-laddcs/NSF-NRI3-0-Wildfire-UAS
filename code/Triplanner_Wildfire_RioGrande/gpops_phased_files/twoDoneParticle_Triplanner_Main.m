%-------------------------------------------------------------------------%
%-------------- Reduced Switching Time Optimization Prob -----------------%
%-------------------------------------------------------------------------%

%---------------------%
%%% Given Constants %%%
%---------------------%
V     = 15;
r_min = 20;
% r_min = 0.1;
% V     = vehicle.V;
% r_min = vehicle.r_min;
umax  = 1;

%------------------------------%
%%% Given Initial Conditions %%%
%------------------------------%
% Phase 1 start point 
t0 = 0;
X0 = path(1,1);
Y0 = path(1,2);

%----------------------------%
%%% Given Final Conditions %%%
%----------------------------%
% tf is free
Xf = path(end,1);
Yf = path(end,2);

%---------------%
%%% Visualize %%%
%---------------%
figure;
hold on;
for i = 1:size(obs,2)
    fill(obs(i).polygon(:,1),obs(i).polygon(:,2), 'y','Linewidth',2);
end
triplot(tri_funnel);
plot(path(:,1),path(:,2),'k*','LineWidth',2);
xlabel('x');
ylabel('y');
daspect([1 1 1]);

%-------------------------------%
%%% Conversion to BaryCentric %%%
%-------------------------------%
% Phase Start
StartTriID = pointLocation(tri_funnel,[X0 Y0]);
alpha0 = cart2bary(tri_funnel.Points(tri_funnel(StartTriID,:)',:),[X0 Y0]);
% Phase Final
FinalTriID = pointLocation(tri_funnel,[Xf Yf]);
alphaf = cart2bary(tri_funnel.Points(tri_funnel(FinalTriID,:)',:),[Xf Yf]);

%---------------------%
%%% Variable Ranges %%%
%---------------------%
tfMin     =  0;    tfMax     = 1000;
alphaMin  = 0;     alphaMax  = 1;
thetarMin = -pi(); thetarMax = pi();
uMin      = -umax; uMax      = umax;

%--------------------------%
%%% Wrap Info in auxdata %%%
%--------------------------%
auxdata.V     = V;
auxdata.r_min = r_min;
auxdata.Tri.Points = tri_funnel.Points;
auxdata.Tri.ConnectivityList = tri_funnel.ConnectivityList;

%-------------------------------------------------------------------------%
%---------------------- Provide Guess of Solution ------------------------%
%-------------------------------------------------------------------------%
u0 = 0;
guess_cart = triplanner_guess_cart(tri_funnel,path,auxdata,u0);
guess_bary = phased_cart2bary(guess_cart,tri_funnel);

%---------------%
%%% Visualize %%%
%---------------%
figure;
set(gcf,'Position',[200 80 700 700]);
set(gcf,'color','w');
hold on
if plot_transform == 1
    for i = 1:size(obs,2)
        fill(obs(i).polygon(:,1),obs(i).polygon(:,2), 'y','Linewidth',2);
    end
    triplot(tri_funnel);
    for i = 1:size(guess_cart.phase,2)
        plot(guess_cart.phase(i).state(:,1),guess_cart.phase(i).state(:,2),'o');
    end
    ps = plot(X0,Y0,'*','LineWidth',3,'Color',[0.4660 0.6740 0.1880]);
    pf = plot(Xf,Yf,'*','LineWidth',3,'Color',[1 0 0]);
else
    for i = 1:size(obs,2)
        fill(obs(i).polygon(:,1)+domain.longmin,obs(i).polygon(:,2)+domain.latmin, 'y','Linewidth',2);
    end
    tri_funnel_plot = triangulation(tri_funnel.ConnectivityList,tri_funnel.Points+[domain.longmin, domain.latmin]);
    triplot(tri_funnel_plot);
    for i = 1:size(guess_cart.phase,2)
        plot(guess_cart.phase(i).state(:,1)+domain.longmin,guess_cart.phase(i).state(:,2)+domain.latmin,'o');
    end
    ps = plot(X0+domain.longmin,Y0+domain.latmin,'*','LineWidth',3,'Color',[0.4660 0.6740 0.1880]);
    pf = plot(Xf+domain.longmin,Yf+domain.latmin,'*','LineWidth',3,'Color',[1 0 0]);
end
if plot_transform == 1
    xlim([domain.xmin, domain.xmax]);
    ylim([domain.ymin, domain.ymax]);
    xlabel('X (m)');
    ylabel('Y (m)');
else
    xlim([domain.longmin, domain.longmax]);
    ylim([domain.latmin, domain.latmax]);
    xlabel('Easting (m)');
    ylabel('Northing (m)');
end
grid on;
box on;
legend([ps pf],{'Start Point','Final Point'},'Location','north');
daspect([1 1 1]);
title('Phased Guess Solution');

%-------------------------------------------------------------------------%
%----------------------- Setup for Problem Bounds ------------------------%
%-------------------------------------------------------------------------%
numPhases = size(guess_bary.phase,2);
for phNum = 1:numPhases
    bounds.phase(phNum).initialtime.lower = tfMin;
    bounds.phase(phNum).initialtime.upper = tfMax;
    bounds.phase(phNum).finaltime.lower = tfMin;
    bounds.phase(phNum).finaltime.upper = tfMax;
    bounds.phase(phNum).initialstate.lower = [alphaMin, alphaMin, alphaMin, thetarMin];
    bounds.phase(phNum).initialstate.upper = [alphaMax, alphaMax, alphaMax, thetarMax];
    bounds.phase(phNum).state.lower = [alphaMin, alphaMin, alphaMin, thetarMin];
    bounds.phase(phNum).state.upper = [alphaMax, alphaMax, alphaMax, thetarMax];
    bounds.phase(phNum).finalstate.lower = [alphaMin, alphaMin, alphaMin, thetarMin];
    bounds.phase(phNum).finalstate.upper = [alphaMax, alphaMax, alphaMax, thetarMax];
    bounds.phase(phNum).control.lower = uMin;
    bounds.phase(phNum).control.upper = uMax;
    bounds.phase(phNum).path.lower = 1;
    bounds.phase(phNum).path.upper = 1;
    if phNum == 1
        bounds.phase(phNum).initialtime.lower = t0;
        bounds.phase(phNum).initialtime.upper = t0;
        bounds.phase(phNum).initialstate.lower = [alpha0(1,1), alpha0(2,1), alpha0(3,1), thetarMin];
        bounds.phase(phNum).initialstate.upper = [alpha0(1,1), alpha0(2,1), alpha0(3,1) thetarMax];
    end
    if phNum == numPhases
        bounds.phase(phNum).finalstate.lower = [alphaf(1,1), alphaf(2,1), alphaf(3,1), thetarMin];
        bounds.phase(phNum).finalstate.upper = [alphaf(1,1), alphaf(2,1), alphaf(3,1), thetarMax];
    end
end

%-------------------------------------------------------------------------%
%------------- Set up Event Constraints That Link Phases -----------------%
%-------------------------------------------------------------------------%
for phNum = 1:numPhases
    if phNum > 1
        bounds.eventgroup(phNum-1).lower = [zeros(1,3), 0];
        bounds.eventgroup(phNum-1).upper = [zeros(1,3), 0];
    end
end

%-------------------------------------------------------------------------%
%----------Provide Mesh Refinement Method and Initial Mesh ---------------%
%-------------------------------------------------------------------------%
mesh.method          = 'hp-PattersonRao';
mesh.tolerance       = 1e-3;
mesh.maxiterations   = 5;
mesh.colpointsmin    = 3;
mesh.colpointsmax    = 6;
% N = 200;
% mesh.phase.colpoints = 4*ones(1,N);
% mesh.phase.fraction  = ones(1,N)./N;

%-------------------------------------------------------------------------%
%------------- Assemble Information into Problem Structure ---------------%        
%-------------------------------------------------------------------------%
setup.name                           = 'oneDtwoParticleProblem';
setup.functions.continuous           = @twoDoneParticleObstacleContinuousFor;
setup.functions.endpoint             = @twoDoneParticleObstacleEndpointFor;
setup.displaylevel                   = 2;
setup.bounds                         = bounds;
setup.guess                          = guess_bary;
setup.mesh                           = mesh;
setup.auxdata                        = auxdata;
setup.nlp.solver                     = 'ipopt';
% setup.nlp.solver                     = 'snopt';
setup.nlp.ipoptoptions.linear_solver = 'ma57';
setup.nlp.ipoptoptions.tolerance     = 1e-3;
setup.nlp.ipoptoptions.maxiterations = 500;
% setup.derivatives.supplier           = 'adigator';
setup.derivatives.supplier           = 'sparseCD';
setup.derivatives.derivativelevel    = 'second';
setup.method                         = 'RPM-Differentiation';

%-------------------------------------------------------------------------%
%---------------------- Solve Problem Using GPOPS2 -----------------------%
%-------------------------------------------------------------------------%
tic
output = gpops2(setup);
solution = output.result.solution;
toc

tStar = [];
xStar = [];
for i = 1:size(solution.phase,2)
    triPoints = tri_funnel.Points(tri_funnel.ConnectivityList(i,:)',:);
    x_star_cart = zeros(size(solution.phase(i).state,1),2);
    for j = 1:size(solution.phase(i).state,1)
        x_star_cart(j,:) = bary2cart(triPoints,solution(1).phase(i).state(j,1:3)')';
    end
    tStar = [tStar; solution(1).phase(i).time];
    xStar = [xStar; x_star_cart];
end

run('twoDoneParticle_Triplanner_Plot')