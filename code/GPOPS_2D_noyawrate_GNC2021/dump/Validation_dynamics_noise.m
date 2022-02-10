clear all; close all; clc;

risk_validate = 0.03;

mode = 'poly';
% mode = 'map'

unc_mode = 'risk';
% unc_mode = 'bound';

polyCase = 1;
% polyCase = 4;

% conservativeness = 0;
conservativeness = 1;

load_file = ['Result_dyna_',mode];
if strcmp(mode,'map')
else
    load_file = [load_file,num2str(polyCase)];
end
load_file = [load_file,'_',unc_mode];
load(load_file);

% risk_ind = 6; % calculate using lookup


% t_vec = linspace(path(1).t_star(1,1),path(1).t_star(end,1),100)';
t_vec = [path(1).t_star(1,1):path_noise.delta_t:path(1).t_star(end,1)]';
X_interp = interp1(path(1).t_star,path(1).X_star(:,1),t_vec);
Y_interp = interp1(path(1).t_star,path(1).Y_star(:,1),t_vec);
thetar_interp = interp1(path(1).t_star,path(1).thetar_star(:,1),t_vec);

nTrials = 1e4;
delta = 0;
run('twoDoneParticleObstacleMain_for.m');
violation = post_analysis_path_noise(t_vec,X_interp,Y_interp,thetar_interp,auxdata,risk,path_noise,nTrials);

save_file = ['validation_dyna_',num2str(nTrials)];
save(save_file);

% nTrials_vec    = [100, 500, 1000, 5000, 1e4, 1e5, 5*1e5]';
% nTrials_vec    = [1e3, 5*1e3, 1e4, 5*1e4, 1e5, 5*1e5, 1e6]';
nTrials_vec    = [1e3, 5*1e3, 1e4, 5*1e4, 1e5]';
violation_conv = zeros(size(t_vec,1),size(nTrials_vec,1));
for i = 1:size(nTrials_vec,1)
    disp(['Num of Trials: ',num2str(nTrials_vec(i))]);
    violation_conv(:,i) = post_analysis_path_noise(t_vec,X_interp,Y_interp,thetar_interp,auxdata,risk,path_noise,nTrials_vec(i));
end

save_file = ['validation_dyna_multi'];
save(save_file);