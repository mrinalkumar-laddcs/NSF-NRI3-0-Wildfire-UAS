clear all; close all; clc;

risk_validate = 0.03;

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

risk_ind = 6; % calculate using lookup


% if strcmp(unc_mode,'risk')
% 
% else
    delta = 0;
    run('twoDoneParticleObstacleMain_for.m');
    t_vec = linspace(path(1).t_star(1,1),path(1).t_star(end,1),100)';
    X_interp = interp1(path(1).t_star,path(1).X_star(:,1),t_vec);
    Y_interp = interp1(path(1).t_star,path(1).Y_star(:,1),t_vec);
    
%     violation = post_analysis_robust(X_interp,Y_interp,auxdata,bnd);
% end

% Integration
X_his = zeros(size(path(1).t_star,1),1);
Y_his = zeros(size(path(1).t_star,1),1);
thetar_his = zeros(size(path(1).t_star,1),1);

X_his(1,1) = path(1).X_star(1,1);
Y_his(1,1) = path(1).Y_star(1,1);
thetar_his(1,1) = path(1).thetar_star(1,1);
for i = 2:size(path(1).t_star,1)
    delta_t = path(1).t_star(i,1)-path(1).t_star(i-1,1);
    X_his(i,1) = X_his(i-1,1) + V*cos(thetar_his(i-1,1))*delta_t;
    Y_his(i,1) = Y_his(i-1,1) + V*sin(thetar_his(i-1,1))*delta_t;
    thetar_his(i,1) = thetar_his(i-1,1) + path(1).u_star(i-1,1)*delta_t;
end

y0 = [path(1).X_star(1,1); path(1).Y_star(1,1); path(1).thetar_star(1,1)];
[t,y] = ode45(@(t,y) dubins_dyna(t,y,V,path(1).t_star,path(1).u_star), path(1).t_star, y0);

theta_rnd = normrnd(0,0.05,[50,1]);
X_rnd = path(1).X_star - V*sin(path(1).thetar_star).*sin(theta_rnd).*[0; path(1).t_star(2:end,1) - path(1).t_star(1:end-1,1)];
Y_rnd = path(1).Y_star + V*cos(path(1).thetar_star).*sin(theta_rnd).*[0; path(1).t_star(2:end,1) - path(1).t_star(1:end-1,1)];

figure;
subplot(311);
plot(path(1).t_star,path(1).X_star(:,1));
hold on
plot(path(1).t_star,X_his(:,1));
xlim([path(1).t_star(1) path(1).t_star(end)]);
ylabel('X');

subplot(312);
plot(path(1).t_star,path(1).Y_star(:,1));
hold on
plot(path(1).t_star,Y_his(:,1));
xlim([path(1).t_star(1) path(1).t_star(end)]);
ylabel('Y');

subplot(313);
plot(path(1).t_star,path(1).thetar_star(:,1));
hold on
plot(path(1).t_star,thetar_his(:,1));
xlim([path(1).t_star(1) path(1).t_star(end)]);
xlabel('time');
ylabel('\theta');

figure;
[nodesD,edgesD,polySizeD] = polgonReSizing(nodes,edges,polySize,bnd.upp);
    patch('faces',edgesD(:,1:2),'vertices',nodesD, ...
    'FaceColor','w', ...
    'edgecolor',[.1,.1,.1],'edgealpha',1, ...
    'linewidth',1) ;
hold on
h1 = plot(path(1).X_star(:,1),path(1).Y_star(:,1),'linewidth',1.5);
h2 = plot(X_his(:,1),Y_his(:,1),'linewidth',1.5);
h3 = plot(y(:,1),y(:,2),'linewidth',1.5);
h4 = plot(X_rnd(:,1),Y_rnd(:,1),'linewidth',1.5);
legend([h1,h2,h3,h4], {'optimal','Euler Int','ODE45','w/ noise'},'location','northwest');
xlabel('X');
ylabel('Y');
xlim([xMin xMax]);
ylim([yMin yMax]);
daspect([1 1 1]);


function dydt = dubins_dyna(t,y,V,tspan,ut)
u = interp1(tspan,ut,t);
dydt = [V*cos(y(3)); V*sin(y(3)); u];
end