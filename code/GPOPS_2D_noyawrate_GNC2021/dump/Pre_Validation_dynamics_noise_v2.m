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

interpolation = 1;
delta = 0;
run('twoDoneParticleObstacleMain_for.m');
if interpolation == 1
%     t_vec = linspace(path(1).t_star(1,1),path(1).t_star(end,1),100)';
    t_vec = [path(1).t_star(1,1):0.4:path(1).t_star(end,1)]';
    X_interp = interp1(path(1).t_star,path(1).X_star(:,1),t_vec);
    Y_interp = interp1(path(1).t_star,path(1).Y_star(:,1),t_vec);
    thetar_interp = interp1(path(1).t_star,path(1).thetar_star(:,1),t_vec);
    u_interp = interp1(path(1).t_star,path(1).u_star(:,1),t_vec);
else
    t_vec = path(1).t_star(:,1);
    X_interp = path(1).X_star(:,1);
    Y_interp = path(1).Y_star(:,1);
    thetar_interp = path(1).thetar_star(:,1);
    u_interp = path(1).u_star(:,1);
end


% Addition of Noise (via Integration)
nSteps = size(t_vec,1);
sigma_u = 0.2;
u_sam = normrnd(0,sigma_u,[nSteps,1]);
delta_t = [0; t_vec(2:end,1) - t_vec(1:end-1,1)];

% Method 1 (Linearized)
X_rnd_lin = X_interp - V*sin(thetar_interp).*delta_t.*sin(u_sam.*sqrt(delta_t));
Y_rnd_lin = Y_interp + V*cos(thetar_interp).*delta_t.*sin(u_sam.*sqrt(delta_t));
thetar_rnd_lin = atan2(Y_rnd_lin(2:end,1)-Y_rnd_lin(1:end-1,1),X_rnd_lin(2:end,1)-X_rnd_lin(1:end-1,1));
thetar_rnd_lin(end+1,1) = thetar_rnd_lin(end,1);
u_rnd_lin = u_interp + u_sam;

% Method 2
X_rnd = zeros(size(t_vec,1),1);
Y_rnd = zeros(size(t_vec,1),1);
thetar_rnd = thetar_interp(:,1) + u_sam.*sqrt(delta_t);
u_rnd = u_interp + u_sam;

X_rnd(1,1) = X_interp(1,1);
Y_rnd(1,1) = Y_interp(1,1);
thetar_rnd(1,1) = thetar_interp(1,1);
for i = 2:size(t_vec,1)
    X_rnd(i,1) = X_interp(i-1,1) + V*cos(thetar_rnd(i,1)).*delta_t(i,1);
    Y_rnd(i,1) = Y_interp(i-1,1) + V*sin(thetar_rnd(i,1)).*delta_t(i,1);
end

nTrials = 10000;
t_ind = 10;
[mu,sigma] = error_analysis(t_vec,X_interp,Y_interp,thetar_interp,u_interp,V,sigma_u,nTrials,t_ind);

figure;
subplot(411);
plot(t_vec,u_interp(:,1));
hold on
plot(t_vec,u_rnd_lin(:,1));
plot(t_vec,u_rnd(:,1));
ylabel('X');

subplot(412);
plot(t_vec,X_interp(:,1));
hold on
plot(t_vec,X_rnd_lin(:,1));
plot(t_vec,X_rnd(:,1));
ylabel('X');

subplot(413);
plot(t_vec,Y_interp(:,1));
hold on
plot(t_vec,Y_rnd_lin(:,1));
plot(t_vec,Y_rnd(:,1));
ylabel('Y');

subplot(414);
plot(t_vec,thetar_interp(:,1));
hold on
plot(t_vec,thetar_rnd_lin(:,1));
plot(t_vec,thetar_rnd(:,1));
xlabel('time');
ylabel('\theta');

figure;
[nodesD,edgesD,polySizeD] = polgonReSizing(nodes,edges,polySize,bnd.upp);
    patch('faces',edgesD(:,1:2),'vertices',nodesD, ...
    'FaceColor','w', ...
    'edgecolor',[.1,.1,.1],'edgealpha',1, ...
    'linewidth',1) ;
hold on
h1 = plot(X_interp(:,1),Y_interp(:,1),'linewidth',1.5);
h2 = plot(X_rnd_lin(:,1),Y_rnd_lin(:,1),'linewidth',1.5);
h3 = plot(X_rnd(:,1),Y_rnd(:,1),'linewidth',1.5);
legend([h1,h2,h3], {'optimal','w/ noise lin','w/noise'},'location','northwest');
xlabel('X');
ylabel('Y');
xlim([xMin xMax]);
ylim([yMin yMax]);
daspect([1 1 1]);