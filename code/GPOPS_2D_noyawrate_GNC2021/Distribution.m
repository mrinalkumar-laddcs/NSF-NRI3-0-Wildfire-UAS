clear all; close all; clc;

% rng default; % For reproducibility
load('seed_value3')
rng(s); % For reproducibility
% s = rng; 
% samples = normrnd(0,0.5,100,1);

samples = [-1 + 2*rand(30,1); [-2.1 -1.5 0 1.5 2.1]'; -2 + 4*rand(5,1); -0.5 + rand(10,1)];

[muHat,sigmaHat,muCI,sigmaCI] = normfit(samples);

x_vec = (-3:0.01:3)';
% pdf_est = normpdf(x_vec',muHat,sigmaHat);
pdf_est = normpdf(x_vec',0,sigmaHat);

% a = norminv(0.5,muHat,sigmaHat)
% a = norminv(1-0.04,0,sigmaHat)
a = norminv(1-0.04,0,0.785)

mu = 0;
sigma = 0.5;
pdf_pred = normpdf(x_vec',mu,sigma);

set(gcf, 'Position', [700 80 500 350]);
set(gcf,'color','w');
histogram(samples,'Normalization','pdf')
hold on
plot(x_vec,pdf_est,'linewidth',1.5);
% plot(x_vec,pdf_pred);
% stem(a,0.5)
xlim([-3 3]);
ylim([0 0.55]);
xlabel('\xi');
ylabel('pdf');