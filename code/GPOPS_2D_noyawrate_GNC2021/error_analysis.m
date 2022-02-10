function [mu,sigma] = error_analysis(t_vec,X_interp,Y_interp,thetar_interp,u_interp,V,sigma_u,nTrials,t_ind)


nSteps = size(t_vec,1);
delta_t = [0; t_vec(2:end,1) - t_vec(1:end-1,1)];

delta_lin = zeros(nTrials,1);
delta = zeros(nTrials,1);

for j = 1:nTrials
    u_sam = normrnd(0,sigma_u,[nSteps,1]);
    
    % Addition of Noise (via Integration)
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
    
    delta_x_lin = X_rnd_lin - X_interp;
    delta_y_lin = Y_rnd_lin - Y_interp;
%     delta_l_lin = sqrt(delta_x_lin.^2 + delta_y_lin.^2);
%     delta_l_lin = delta_x_lin./sin(thetar_interp);
    delta_l_lin = V*sin(thetar_rnd(:,1)-thetar_interp(:,1)).*delta_t(:,1);
    
    delta_x = X_rnd - X_interp;
    delta_y = Y_rnd - Y_interp;
%     delta_l = sqrt(delta_x.^2 + delta_y.^2);
%     delta_l = delta_x./sin(thetar_interp);    
    delta_l(1,1) = 0;
    for i = 2:size(t_vec,1)
        a = (Y_interp(i-1,1) - Y_interp(i,1));
        b = (X_interp(i,1) - X_interp(i-1,1));
        delta_l(i,1) = (a*X_rnd(i,1) + b*Y_rnd(i,1) + (X_interp(i-1,1)*Y_interp(i,1) - X_interp(i,1)*Y_interp(i-1,1)))/sqrt(a.^2+b.^2);
    end
    
    
    delta_lin(j,1) = delta_l_lin(t_ind,1);
    delta(j,1) = delta_l(t_ind,1);
end

change_delta = delta_lin-delta;

[muHatl,sigmaHatl,muCIl,sigmaCIl] = normfit(delta_lin);
[muHat,sigmaHat,muCI,sigmaCI] = normfit(delta);

x_vec = (-2:0.05:2)';
pdf_est_lin = normpdf(x_vec',muHatl,sigmaHatl);
pdf_est = normpdf(x_vec',muHat,sigmaHat);
pdf_pred = normpdf(x_vec',0,sigma_u*V*delta_t(t_ind,1)^1.5);
pdf_pred = normpdf(x_vec',0,sin(sigma_u*sqrt(delta_t(t_ind,1)))*V*delta_t(t_ind,1));

figure;
histogram(delta_lin,'Normalization','pdf');
hold on;
histogram(delta,'Normalization','pdf');
plot(x_vec,pdf_est_lin,'linewidth',1.5);
plot(x_vec,pdf_est,'linewidth',1.5);
plot(x_vec,pdf_pred,'linewidth',1.5);
legend('hist lin','hist','est lin','est','pred');

figure;
set(gcf, 'Position', [700 80 400 300]);
set(gcf,'color','w');
hold on;
histogram(delta,'Normalization','pdf');
h2 = plot(x_vec,pdf_est,'linewidth',1.5);
box on
legend([h2],{'fitted dist'});
% title('\hat{\mu} = -0.01, \hat{\sigma} = 0.462')

figure;
plot(t_vec,delta_l_lin);
hold on;
plot(t_vec,delta_l);

end