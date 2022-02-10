clear all; close all; clc;

rng default; % For reproducibility
% load('seed_value3')
% rng(s); % For reproducibility
% s = rng; 
% samples = normrnd(0,0.5,100,1);

samples = [-1 + 2*rand(30,1); [-2.1 -1.5 0 1.5 2.1]'; -2 + 4*rand(5,1); -0.5 + rand(10,1)];

nSam = 1e3;
bnd_sam = normrnd(0,0.79,[nSam, 1]);
del_sam = normrnd(0,0.447,[nSam, 1]);

[muHat,sigmaHat,muCI,sigmaCI] = normfit(bnd_sam+del_sam);

x_vec = (-3:0.01:3)';
% pdf_est = normpdf(x_vec',muHat,sigmaHat);
pdf_est = normpdf(x_vec',0,sigmaHat);

a = norminv(1-0.03,0,sqrt(0.79^2+0.447^2))

mu = 0;
sigma = 0.5;
pdf_pred = normpdf(x_vec',mu,sigma);

set(gcf, 'Position', [700 80 500 350]);
set(gcf,'color','w');
hold on
histogram(bnd_sam,'Normalization','pdf')
histogram(del_sam,'Normalization','pdf')
histogram(bnd_sam+del_sam,'Normalization','pdf')
plot(x_vec,pdf_est,'linewidth',1.5);
stem(a,0.5)
xlim([-3 3]);
ylim([0 0.55]);
xlabel('\xi');
ylabel('pdf');