%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualize
global plot_transform

figure;
set(gcf,'Position',[200 80 700 700]);
set(gcf,'color','w');
hold on;
if plot_transform == 1
    % show the obstacles
    for i = 1:size(obs,2)
        fill(obs(i).polygon(:,1),obs(i).polygon(:,2), 'y','Linewidth',2);
    end
    
    if status ~=1
        % show the free edges
        %     for i = 1:size(edges,1)
        %         plot(edges(i,[1,3]),edges(i,[2,4]),'r-');
        %     end
        
        % show the triangulation funnel
        triplot(tri_mesh,'Color',[0.5 0.5 0.5],'LineStyle','-');
        
        % show the triangulation funnel
        triplot(tri_funnel,'b-');
        
        % show the path
        plot(path(:,1),path(:,2),'LineWidth',2,'Color',[0.8500 0.3250 0.0980]);
    end
    % show the start/end points
    ps = plot(startPoint(1),startPoint(2),'*','LineWidth',3,'Color',[0.4660 0.6740 0.1880]);
    pf = plot(finalPoint(1),finalPoint(2),'*','LineWidth',3,'Color',[1 0 0]);
    grid on
    xlim([domain.xmin, domain.xmax]);
    ylim([domain.ymin, domain.ymax]);
    xlabel('X (m)');
    ylabel('Y (m)');
else
    % show the obstacles
    for i = 1:size(obs,2)
        fill(obs(i).polygon(:,1)+domain.longmin,obs(i).polygon(:,2)+domain.latmin, 'y','Linewidth',2);
    end
    
    if status ~=1
        % show the free edges
        %     for i = 1:size(edges,1)
        %         plot(edges(i,[1,3]),edges(i,[2,4]),'r-');
        %     end
        
        % show the triangulation funnel
        tri_mesh_plot = tri_mesh;
        tri_mesh_plot.Points = tri_mesh_plot.Points + [domain.longmin, domain.latmin];
        triplot(tri_mesh_plot,'Color',[0.5 0.5 0.5],'LineStyle','-');
        
        % show the triangulation funnel
        path_plot = path + [domain.longmin, domain.latmin];
        tri_funnel_plot = funnel(tri_mesh_plot,path_plot);
        triplot(tri_funnel_plot,'b-');
        
        % show the path
        plot(path_plot(:,1),path_plot(:,2),'LineWidth',2,'Color',[0.8500 0.3250 0.0980]);
        
    end
    % show the start/end points
    ps = plot(startPoint(1)+domain.longmin,startPoint(2)+domain.latmin,'*','LineWidth',3,'Color',[0.4660 0.6740 0.1880]);
    pf = plot(finalPoint(1)+domain.longmin,finalPoint(2)+domain.latmin,'*','LineWidth',3,'Color',[1 0 0]);
    grid on
    xlim([domain.longmin, domain.longmax]);
    ylim([domain.latmin, domain.latmax]);
    xlabel('Easting (m)');
    ylabel('Northing (m)');
end
legend([ps pf],{'Start Point','Final Point'},'Location','north');
title('Triplanner generated path');
daspect([1 1 1]);