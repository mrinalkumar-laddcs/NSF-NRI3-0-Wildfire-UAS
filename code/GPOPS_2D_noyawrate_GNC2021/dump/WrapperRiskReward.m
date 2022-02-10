%-------------------------------------------------------------------------%
%                      Wrapper for Risk vs Path Length
%-------------------------------------------------------------------------%
clear all; close all; clc;

mode = 'poly';
% mode = 'map'

unc_mode = 'risk';
% unc_mode = 'bound'

polyCase = 1;
polyCase = 4;

% conservativeness = 0;
conservativeness = 1;

save_file = ['Result','_',mode];

if strcmp(mode,'map')
    mapEnable = 1;
    V     = 10;
    r_min = 2;
    
    risk.upp  = 0.15;
    risk.low  = 0.01;
    risk.step = 0.01;
    risk.values = linspace(risk.low,risk.upp,((risk.upp-risk.low)/risk.step)+2)';
    risk.mu      = 0;
    risk.sigma   = 0.7;
    risk.eqdelta = norminv(1-risk.values,risk.mu, risk.sigma);

    bnd.upp  = 1.5;
    bnd.low  = 0.5;
    bnd.step = 0.01;
    bnd.values = linspace(bnd.low,bnd.upp,((bnd.upp-bnd.low)/bnd.step)+2)';
else
    mapEnable = 0;
    V     = 10;
    r_min = 1;
    
    risk.upp  = 0.075;
    risk.low  = 0.005;
    risk.step = 0.005;
    risk.values = linspace(risk.low,risk.upp,((risk.upp-risk.low)/risk.step)+2)';
%     risk.values = [risk.low, risk.step:risk.step:risk.upp]';
    risk.mu      = 0;
    risk.sigma   = 0.79;
    risk.eqdelta = round(norminv(1-risk.values,risk.mu, risk.sigma),3);

    bnd.upp  = 2.1;
    bnd.low  = -2.1;
    bnd.step = 0.1;
    bnd.values = linspace(bnd.low,bnd.upp,((bnd.upp-bnd.low)/bnd.step)+2)';
    
    save_file = [save_file,num2str(polyCase)]
end

if strcmp(unc_mode,'risk')
    delta_vec = risk.eqdelta;
else
%     delta_vec = bnd.values;
    delta_vec = bnd.upp;
end

save_file = [save_file,'_',unc_mode];

% run('twoDoneParticleObstaclePlot_Initial');

for k = 1:size(delta_vec,1)
    delta = delta_vec(k);
    run('twoDoneParticleObstacleMain_for.m');
    
    %Solve Problem Using GPOPS2
    output = gpops2(setup);
    solution = output.result.solution;
    
    path(k).t_star = solution(1).phase.time;
    path(k).u_star = solution(1).phase.control(:,1);
    path(k).X_star = solution(1).phase.state(:,1);
    path(k).Y_star = solution(1).phase.state(:,2);
    path(k).thetar_star = solution(1).phase.state(:,3);
    path(k).X_guess = guess(1).phase.state(:,1);
    path(k).Y_guess = guess(1).phase.state(:,2);
    path(k).thetar_guess = guess(1).phase.state(:,3);
end

save(save_file);

run('twoDoneParticleObstaclePlot_RiskReward');