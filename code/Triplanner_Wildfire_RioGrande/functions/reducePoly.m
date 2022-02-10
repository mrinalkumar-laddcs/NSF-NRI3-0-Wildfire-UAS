function newObs = reducePoly(obs,domain)
global fig_draw
global transform

latlong_factor = 30;
%     latlong_factor = 1;
tol = 0.8*latlong_factor;
for i = 1:size(obs,2)
    [newObs(i).polygon(:,1),newObs(i).polygon(:,2)] = reducem(obs(i).polygon(:,1),obs(i).polygon(:,2),tol);
end

if fig_draw == 1
    figure;
    hold on
    grid on
    for i = 1:size(obs,2)
        plot(obs(i).polygon(:,1),obs(i).polygon(:,2),'-+');
        plot(newObs(i).polygon(:,1),newObs(i).polygon(:,2),'-o');
    end

    if transform == 1
        xlim([domain.xmin, domain.xmax]);
        ylim([domain.ymin, domain.ymax]);
    else
        xlim([domain.longmin, domain.longmax]);
        ylim([domain.latmin, domain.latmax]);
    end
    daspect([1 1 1]);
end
end