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

if strcmp(unc_mode,'risk')
    t_vec = linspace(path(risk_ind).t_star(1,1),path(risk_ind).t_star(end,1),100)';
    X_interp = interp1(path(risk_ind).t_star,path(risk_ind).X_star(:,1),t_vec);
    Y_interp = interp1(path(risk_ind).t_star,path(risk_ind).Y_star(:,1),t_vec);
    nTrials = 1e2;
    delta = 0;
    run('twoDoneParticleObstacleMain_for.m');
    violation = post_analysis(X_interp,Y_interp,auxdata,risk,nTrials);

    save_file = ['validation_',num2str(risk_ind),'_',num2str(nTrials)];
    save(save_file);

    % nTrials_vec    = [100, 500, 1000, 5000, 1e4, 1e5, 5*1e5]';
    nTrials_vec    = [1e3, 5*1e3, 1e4, 5*1e4, 1e5, 5*1e5, 1e6]';
    violation_conv = zeros(size(t_vec,1),size(nTrials_vec,1));
    for i = 1:size(nTrials_vec,1)
        disp(['Num of Trials: ',num2str(nTrials_vec(i))]);
        violation_conv(:,i) = post_analysis(X_interp,Y_interp,auxdata,risk,nTrials_vec(i));
    end

    save_file = ['validation_',num2str(risk_ind),'_multi'];
    save(save_file);
else
    delta = 0;
    run('twoDoneParticleObstacleMain_for.m');
    t_vec = path(1).t_star(:,1);
%     t_vec = linspace(path(1).t_star(1,1),path(1).t_star(end,1),100)';
    X_interp = interp1(path(1).t_star,path(1).X_star(:,1),t_vec);
    Y_interp = interp1(path(1).t_star,path(1).Y_star(:,1),t_vec);
    
%     violation = post_analysis_robust(X_interp,Y_interp,auxdata,bnd);
    violation = post_analysis_robust(path(1).X_star(:,1),path(1).Y_star(:,1),auxdata,bnd);
    save_file = 'validation_bnd';
    save(save_file);
end


% [t_mesh,nTrials_mesh] = meshgrid(t_vec,nTrials_vec);
% 
% figure;
% set(gcf, 'Position', [700 80 500 350]);
% set(gcf,'color','w');
% plot(t_vec,risk_validate*ones(size(t_vec)),':','LineWidth',1.5);
% hold on
% for i = 1:size(nTrials_vec)
%     plot(t_vec,violation_conv(:,i),'-','LineWidth',1.5);
% end
% xlabel('Time');
% ylabel('Violation Rate');
% xlim([t_vec(1) t_vec(end)]);
% ylim([0 0.1]);
% legend(strcat(num2str(nTrials_vec),' Samples'));

