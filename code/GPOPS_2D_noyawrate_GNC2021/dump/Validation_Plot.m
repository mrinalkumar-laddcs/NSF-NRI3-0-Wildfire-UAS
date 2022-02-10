clear all; close all; clc;

%%
risk_ind = 9;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nTrials = 1e2;
load_file = ['validation_',num2str(risk_ind),'_',num2str(nTrials)];
load(load_file);

figure;
set(gcf, 'Position', [700 80 500 350]);
set(gcf,'color','w');
plot(t_vec,risk.values(risk_ind)*ones(size(t_vec)),':','LineWidth',1.5);
hold on;
plot(t_vec,violation,'-','LineWidth',1.5);
xlabel('Time');
ylabel('Violation Rate');
xlim([t_vec(1) t_vec(end)]);
ylim([0 0.1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load_file = ['validation_',num2str(risk_ind),'_multi'];
load(load_file);

% figure;
% set(gcf, 'Position', [700 80 500 350]);
% set(gcf,'color','w');
% plot(t_vec,risk.values(risk_ind)*ones(size(t_vec)),':','LineWidth',1.5);
% hold on
% for i = 1:size(nTrials_vec)
%     plot(t_vec,violation_conv(:,i),'-','LineWidth',1.5);
% end
% xlabel('Time');
% ylabel('Violation Rate');
% xlim([t_vec(1) t_vec(end)]);
% ylim([0 0.1]);
% legend(['prescribed risk'; strcat(num2str(nTrials_vec),' Samples')],'Location','Northwest');

% nTrials_vec_new = [1e3, 1e4, 1e5, 1e6]';
nTrials_vec_new = [1e5]';
figure;
set(gcf, 'Position', [700 80 500 350]);
set(gcf,'color','w');
plot(t_vec,risk.values(risk_ind)*ones(size(t_vec)),':','LineWidth',1.5);
hold on
for i = 1:size(nTrials_vec)
    if any(nTrials_vec_new == nTrials_vec(i))
        plot(t_vec,violation_conv(:,i),'-','LineWidth',1.5);
    end
end
grid on
box on
xlabel('Time');
ylabel('Violation Rate');
xlim([t_vec(1) t_vec(end)]);
ylim([0 0.1]);
title(['Risk, \epsilon = ', num2str(risk.values(risk_ind))]);
% legend(['prescribed risk'; strcat(num2str(nTrials_vec_new),' Samples')],'Location','Northwest');
legend({'prescribed risk', 'computed violation rate'},'Location','Northwest');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load_file = 'validation_bnd';
load(load_file);
figure;
set(gcf, 'Position', [700 80 500 350]);
set(gcf,'color','w');
plot(t_vec,violation,'-','LineWidth',1.5);
grid on
box on
xlabel('Time');
ylabel('Violation');
xlim([t_vec(1) t_vec(end)]);
ylim([0 1.2]);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nTrials = 1e4;
load_file = ['validation_dyna_',num2str(nTrials)];
load(load_file);

figure;
set(gcf, 'Position', [700 80 500 350]);
set(gcf,'color','w');
plot(t_vec,risk.value*ones(size(t_vec)),':','LineWidth',1.5);
hold on;
plot(t_vec,violation,'-','LineWidth',1.5);
xlabel('Time');
ylabel('Violation Rate');
xlim([t_vec(1) t_vec(end)]);
ylim([0 0.15]);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load_file = ['validation_dyna_multi'];
load(load_file);

% nTrials_vec_new = [1e3, 1e4, 1e5, 1e6]';
% nTrials_vec_new = [1e3, 1e4, 1e5]';
nTrials_vec_new = [1e5]';
figure;
set(gcf, 'Position', [700 80 500 350]);
set(gcf,'color','w');
plot(t_vec,risk.value*ones(size(t_vec)),':','LineWidth',1.5);
hold on
for i = 1:size(nTrials_vec)
    if any(nTrials_vec_new == nTrials_vec(i))
        plot(t_vec,violation_conv(:,i),'-','LineWidth',1.5);
    end
end
grid on
box on
xlabel('Time');
ylabel('Violation Rate');
xlim([t_vec(1) t_vec(end)]);
ylim([0 0.40]);
title('Risk, \epsilon = 0.03');
% legend(['prescribed risk'; strcat(num2str(nTrials_vec_new),' Samples')],'Location','Northeast');
legend({'prescribed risk', 'computed violation rate'},'Location','Northwest');