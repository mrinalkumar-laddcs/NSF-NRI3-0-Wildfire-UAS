%-------------------------------------------------------------------------%
%                             Extract Solution                            %
%-------------------------------------------------------------------------%
% t_star  = solution(1).phase.time;
% u_star = solution(1).phase.control(:,1);
% x_star_bary  = solution(1).phase.state(:,1:3);
% theta_star = solution(1).phase.state(:,4);

% Make the plots
figure;
set(gcf,'Position',[200 80 700 700]);
set(gcf,'color','w');
hold on
if plot_transform == 1
    for i = 1:size(obs,2)
        fill(obs(i).polygon(:,1),obs(i).polygon(:,2), 'y','Linewidth',2);
    end
    triplot(tri_funnel);
    for i = 1:size(solution.phase,2)
        triPoints = tri_funnel.Points(tri_funnel.ConnectivityList(i,:)',:);
        x_star_cart = zeros(size(solution.phase(i).state,1),2);
        for j = 1:size(solution.phase(i).state,1)
            x_star_cart(j,:) = bary2cart(triPoints,solution(1).phase(i).state(j,1:3)')';
        end
        plot(x_star_cart(:,1),x_star_cart(:,2),'-o');
    end
    ps = plot(X0,Y0,'*','LineWidth',3,'Color',[0.4660 0.6740 0.1880]);
    pf = plot(Xf,Yf,'*','LineWidth',3,'Color',[1 0 0]);
    xlim([domain.xmin, domain.xmax]);
    ylim([domain.ymin, domain.ymax]);
    xlabel('X (m)');
    ylabel('Y (m)');
else
    for i = 1:size(obs,2)
        fill(obs(i).polygon(:,1)+domain.longmin,obs(i).polygon(:,2)+domain.latmin, 'y','Linewidth',2);
    end
    triplot(tri_funnel_plot);
    for i = 1:size(solution.phase,2)
        triPoints = tri_funnel.Points(tri_funnel.ConnectivityList(i,:)',:);
        x_star_cart = zeros(size(solution.phase(i).state,1),2);
        for j = 1:size(solution.phase(i).state,1)
            x_star_cart(j,:) = bary2cart(triPoints,solution(1).phase(i).state(j,1:3)')';
        end
        plot(x_star_cart(:,1)+domain.longmin,x_star_cart(:,2)+domain.latmin,'-o');
    end
    ps = plot(X0+domain.longmin,Y0+domain.latmin,'*','LineWidth',3,'Color',[0.4660 0.6740 0.1880]);
    pf = plot(Xf+domain.longmin,Yf+domain.latmin,'*','LineWidth',3,'Color',[1 0 0]);
    xlim([domain.longmin, domain.longmax]);
    ylim([domain.latmin, domain.latmax]);
    xlabel('Easting (m)');
    ylabel('Northing (m)');
end
grid on
box on;
legend([ps pf],{'Start Point','Final Point'},'Location','north');
daspect([1 1 1]);
title('Phased Optimal Solution');

figure;
hold on
for i = 1:size(solution.phase,2)
    plot(solution(1).phase(i).time,solution(1).phase(i).control(:,1),'-o');
end
grid on
xlabel('Time,t');
legend('u');
% ylim([0 1.2]);