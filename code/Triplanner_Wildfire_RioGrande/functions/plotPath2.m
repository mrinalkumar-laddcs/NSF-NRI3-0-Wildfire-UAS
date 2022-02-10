%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualization of Final Path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotPath2(approach,plannerMethod,stepResult,domain,test_data_file)
% obs = combineBroken(conv_obs,broken_poly);
global plot_transform

colorOpts = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980],[0.4940 0.1840 0.5560],[0.3010 0.7450 0.9330], [0.6350 0.0780 0.1840], [0.8500 0.3250 0.0980],[0.4940 0.1840 0.5560],[0.3010 0.7450 0.9330], [0.6350 0.0780 0.1840]};

figure;
set(gcf,'Position',[200 80 700 700]);
set(gcf,'color','w');
hold on;
grid on;
if approach.typeID == 1
    linemarker = '--';
    if plot_transform == 1
        for i = 1:size(stepResult,2)
            % show the obstacles
            for j = 1:size(stepResult(i).risk.obs,2)
                if i == size(stepResult,2)
                    patch('Faces',1:1:size(stepResult(i).risk.obs(j).polygon,1),'Vertices',stepResult(i).risk.obs(j).polygon,'FaceColor',[0.9290 0.6940 0.1250],'FaceAlpha',0.5);
                    % patch('Faces',1:1:size(stepResult(i).risk.obs(j).polygon,1),'Vertices',stepResult(i).risk.obs(j).polygon,'FaceColor',[0.9290 0.3 0.08],'FaceAlpha',0.5);
                else
                    patch('Faces',1:1:size(stepResult(i).risk.obs(j).polygon,1),'Vertices',stepResult(i).risk.obs(j).polygon,'LineStyle',linemarker,'FaceColor','y','FaceAlpha',0.2);
                end
            end
        end
        for i = 1:size(stepResult,2)
            % show the path
            pathHandle(i) = plot(stepResult(i).risk.x(:,1),stepResult(i).risk.x(:,2),linemarker,'LineWidth',1.5,'Color',colorOpts{i});
            pathText{i}   = ['Planned @ t_' num2str(i) '=' num2str(stepResult(i).time)];
            plot(stepResult(i).risk.x(end,1),stepResult(i).risk.x(end,2),'ro','LineWidth',1);
            path = interp1(stepResult(i).risk.t,stepResult(i).risk.x,0:0.5:approach.rolling.tDelta);
            traversedPathHandle(i) = plot(path(:,1),path(:,2),'-','LineWidth',1.5,'Color',colorOpts{i});
            traversedPathText{i}   = ['Traversed @ t_{',num2str(i),'-',num2str(i+1),'}'];
        end
        % show the start/end points
        pStart = plot(approach.rolling.startPoint(1,1)-domain.longmin,approach.rolling.startPoint(2)-domain.latmin,'*','LineWidth',3,'Color',[0.4660 0.6740 0.1880]);
        pFinal = plot(approach.rolling.finalPoint(end,1)-domain.longmin,approach.rolling.finalPoint(end,2)-domain.latmin,'*','LineWidth',3,'Color',[1 0 0]);
    else
        for i = 1:size(stepResult,2)
            % show the obstacles
            for j = 1:size(stepResult(i).risk.obs,2)
                if i == size(stepResult,2)
                    patch('Faces',1:1:size(stepResult(i).risk.obs(j).polygon,1),'Vertices',stepResult(i).risk.obs(j).polygon+[domain.longmin domain.latmin],'FaceColor',[0.9290 0.6940 0.1250],'FaceAlpha',0.5);
                    % patch('Faces',1:1:size(stepResult(i).risk.obs(j).polygon,1),'Vertices',stepResult(i).risk.obs(j).polygon+[domain.longmin domain.latmin],'FaceColor',[0.9290 0.3 0.08],'FaceAlpha',0.5);
                else
                    patch('Faces',1:1:size(stepResult(i).risk.obs(j).polygon,1),'Vertices',stepResult(i).risk.obs(j).polygon+[domain.longmin domain.latmin],'LineStyle',linemarker,'FaceColor','y','FaceAlpha',0.2);
                end
            end
        end
        for i = 1:size(stepResult,2)
            % show the path
            pathHandle(i) = plot(stepResult(i).risk.x(:,1)+domain.longmin,stepResult(i).risk.x(:,2)+domain.latmin,linemarker,'LineWidth',1.5,'Color',colorOpts{i});
            pathText{i}   = ['Planned Traj @ t_' num2str(i) '=' num2str(stepResult(i).time)];
            plot(stepResult(i).risk.x(end,1)+domain.longmin,stepResult(i).risk.x(end,2)+domain.latmin,'ro','LineWidth',1);
            path = interp1(stepResult(i).risk.t,stepResult(i).risk.x,0:0.5:approach.rolling.tDelta);
            traversedPathHandle(i) = plot(path(:,1)+domain.longmin,path(:,2)+domain.latmin,'-','LineWidth',1.5,'Color',colorOpts{i});
            traversedPathText{i}   = ['Traversed Traj @ t_' num2str(i) ' - t_' num2str(i+1)];
        end
        % show the start/end points
        pStart = plot(approach.rolling.startPoint(1,1),approach.rolling.startPoint(1,2),'*','LineWidth',3,'Color',[0.4660 0.6740 0.1880]);
        pFinal = plot(approach.rolling.finalPoint(end,1),approach.rolling.finalPoint(end,2),'*','LineWidth',3,'Color',[1 0 0]);
    end
    legend([pathHandle(1:end) pStart traversedPathHandle(1:end) pFinal],{pathText{:},'Start Point',traversedPathText{:},'Final Point'},'Location','north','NumColumns',2);
else % approach.typeID == 2
    if plot_transform == 1
        % show the obstacles
        for j = 1:size(stepResult.risk.obs,2)
            fill(stepResult.risk.obs(j).polygon(:,1),stepResult.risk.obs(j).polygon(:,2), 'y');
            plot(stepResult.risk.obs(j).polygon(:,1),stepResult.risk.obs(j).polygon(:,2), 'k-','LineWidth',1);
        end
        % show the path
        pathHandle = plot(stepResult.risk.x(:,1),stepResult.risk.x(:,2),'b','LineWidth',2);
        % show the start/end points
        pStart = plot(approach.static.startPoint(1,1)-domain.longmin,approach.static.startPoint(1,2)-domain.latmin,'*','LineWidth',3,'Color',[0.4660 0.6740 0.1880]);
        pFinal = plot(approach.static.finalPoint(1,1)-domain.longmin,approach.static.finalPoint(1,2)-domain.latmin,'*','LineWidth',3,'Color',[1 0 0]);
    else
        % show the obstacles
        for j = 1:size(stepResult.risk.obs,2)
            fill(stepResult.risk.obs(j).polygon(:,1)+domain.longmin,stepResult.risk.obs(j).polygon(:,2)+domain.latmin, 'y');
            plot(stepResult.risk.obs(j).polygon(:,1)+domain.longmin,stepResult.risk.obs(j).polygon(:,2)+domain.latmin, 'k-','LineWidth',1);
        end
        % show the path
        pathHandle = plot(stepResult.risk.x(:,1)+domain.longmin,stepResult.risk.x(:,2)+domain.latmin,'b','LineWidth',2);
        % show the start/end points
        pStart = plot(approach.static.startPoint(1,1),approach.static.startPoint(1,2),'*','LineWidth',3,'Color',[0.4660 0.6740 0.1880]);
        pFinal = plot(approach.static.finalPoint(1,1),approach.static.finalPoint(1,2),'*','LineWidth',3,'Color',[1 0 0]);
    end
    legend([pStart pFinal pathHandle],{'Start Point','Final Point','Planned Traj'},'Location','north');
end

if plot_transform == 1
    xlim([domain.xmin, domain.xmax]);
    ylim([domain.ymin, domain.ymax]);
    xlabel('X (m)');
    ylabel('Y (m)');
else
    xlim([domain.longmin, domain.longmax]);
    ylim([domain.latmin, domain.latmax]);
    xlabel('Easting (m)');
    ylabel('Northing (m)');
end

switch plannerMethod.initial
    case 1
    title('Triplanner generated path');
    title('GPOPS generated path');
    case 2
    case 3
end

if plannerMethod.gpops_enable == 1
    title('GPOPS generated path');
end
box on
daspect([1 1 1]);

print(gcf,test_data_file,'-dpng','-r600');
end