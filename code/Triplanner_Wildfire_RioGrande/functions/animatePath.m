%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualization of Final Path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function animatePath(approach,plannerMethod,stepResult,domain,test_data_file)
% obs = combineBroken(conv_obs,broken_poly);
global plot_transform

colorOpts = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980],[0.4940 0.1840 0.5560],[0.3010 0.7450 0.9330], [0.6350 0.0780 0.1840], [0.8500 0.3250 0.0980],[0.4940 0.1840 0.5560],[0.3010 0.7450 0.9330], [0.6350 0.0780 0.1840]};

figure;
set(gcf,'Position',[200 80 700 700]);
set(gcf,'color','w');
if approach.typeID == 1
    linemarker = '--';
    if plot_transform == 1
        for i = 1:size(stepResult,2)+1
            grid on;
            
            % show the start/end points
            pStart = plot(approach.rolling.startPoint(1,1)-domain.longmin,approach.rolling.startPoint(2)-domain.latmin,'*','LineWidth',3,'Color',[0.4660 0.6740 0.1880]);
            hold on;
            pFinal = plot(approach.rolling.finalPoint(end,1)-domain.longmin,approach.rolling.finalPoint(end,2)-domain.latmin,'*','LineWidth',3,'Color',[1 0 0]);
        
            % show the obstacles
            if i > size(stepResult,2)
                k = size(stepResult,2);
            else
                k = i;
            end
            for j = 1:size(stepResult(k).risk.obs,2)
                    % patch('Faces',1:1:size(stepResult(k).risk.obs(j).polygon,1),'Vertices',stepResult(k).risk.obs(j).polygon,'FaceColor',[0.9290 0.6940 0.1250],'FaceAlpha',0.5);
                    % patch('Faces',1:1:size(stepResult(k).risk.obs(j).polygon,1),'Vertices',stepResult(k).risk.obs(j).polygon,'FaceColor',[0.9290 0.3 0.08],'FaceAlpha',0.5);
                    % patch('Faces',1:1:size(stepResult(k).risk.obs(j).polygon,1),'Vertices',stepResult(k).risk.obs(j).polygon,'LineStyle',linemarker,'FaceColor','y','FaceAlpha',0.2);
                    patch('Faces',1:1:size(stepResult(k).risk.obs(j).polygon,1),'Vertices',stepResult(k).risk.obs(j).polygon,'LineStyle',linemarker,'FaceColor',[0.9290 0.6940 0.1250],'FaceAlpha',0.6);
            end
            
%             for j = 1:i%size(stepResult,2)
%                 % show the path
%                 pathHandle(j) = plot(stepResult(j).risk.x(:,1),stepResult(j).risk.x(:,2),linemarker,'LineWidth',1.5,'Color',colorOpts{j});
%                 pathText{j}   = ['Planned Traj @ t_' num2str(j) '=' num2str(stepResult(j).time)];
%                 plot(stepResult(j).risk.x(end,1),stepResult(j).risk.x(end,2),'ro','LineWidth',1);
%                 path = interp1(stepResult(j).risk.t,stepResult(j).risk.x,0:0.5:approach.rolling.tDelta);
%                 traversedPathHandle(j) = plot(path(:,1),path(:,2),'-','LineWidth',1.5,'Color',colorOpts{j});
%                 traversedPathText{j}   = ['Traversed Traj @ t_' num2str(j) ' - t_' num2str(j+1)];
%             end
            
            pathHandle(k) = plot(stepResult(k).risk.x(:,1),stepResult(k).risk.x(:,2),linemarker,'LineWidth',1.5,'Color',colorOpts{k});
            pathText{k}   = ['Planned Traj @ t_' num2str(k) '=' num2str(stepResult(k).time)];
%             plot(stepResult(k).risk.x(1,1),stepResult(k).risk.x(1,2),'*','LineWidth',3,'Color',[0 0.4470 0.7410]);
            
            for j = 1:(i-1)
                % show the traversed path
                path = interp1(stepResult(j).risk.t,stepResult(j).risk.x,0:0.5:approach.rolling.tDelta);
                traversedPathHandle(j) = plot(path(:,1),path(:,2),'-','LineWidth',1.5,'Color',colorOpts{j});
                traversedPathText{j}   = ['Traversed Traj @ t_' num2str(j) ' - t_' num2str(j+1)];
                if j == i-1
                    plot(path(end,1),path(end,2),'d','LineWidth',3,'Color',[0 0.4470 0.7410]);
                end
            end
            if i == 1
                plot(approach.rolling.startPoint(1,1)-domain.longmin,approach.rolling.startPoint(2)-domain.latmin,'d','LineWidth',3,'Color',[0 0.4470 0.7410]);
            end
            if i == size(stepResult,2)+1
                plot(approach.rolling.finalPoint(end,1)-domain.longmin,approach.rolling.finalPoint(end,2)-domain.latmin,'d','LineWidth',3,'Color',[0 0.4470 0.7410]);
            end
            
%             legend([pathHandle(1:end) pStart traversedPathHandle(1:end) pFinal],{pathText{:},'Start Point',traversedPathText{:},'Final Point'},'Location','north','NumColumns',2);
            legend([pStart pFinal],{'Start Point','Final Point'},'Location','north');
            xlim([domain.xmin, domain.xmax]);
            ylim([domain.ymin, domain.ymax]);
            xlabel('X (m)');
            ylabel('Y (m)');
            box on
            daspect([1 1 1]);
            
            hold off
            
            pause(0.5);
            print(gcf,[test_data_file,'-',num2str(i)],'-dpng','-r600');
        end
    else
        hold on;
        grid on;
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
        
        
        legend([pathHandle(1:end) pStart traversedPathHandle(1:end) pFinal],{pathText{:},'Start Point',traversedPathText{:},'Final Point'},'Location','north','NumColumns',2);
        xlim([domain.longmin, domain.longmax]);
        ylim([domain.latmin, domain.latmax]);
        xlabel('Easting (m)');
        ylabel('Northing (m)');
        box on
        daspect([1 1 1]);
        
        hold off;
    end
end

% switch plannerMethod.initial
%     case 1
%     title('Triplanner generated path');
%     title('GPOPS generated path');
%     case 2
%     case 3
% end
% 
% if plannerMethod.gpops_enable == 1
%     title('GPOPS generated path');
% end

% print(gcf,test_data_file,'-dpng','-r600');
end