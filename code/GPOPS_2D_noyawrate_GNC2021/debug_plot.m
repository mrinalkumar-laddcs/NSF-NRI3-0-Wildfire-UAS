%-------------------------------------------------------------------------%
%                             Extract Solution                            %
%-------------------------------------------------------------------------%
% t_star  = solution(1).phase.time;
% u_star = solution(1).phase.control(:,1);
% X_star  = solution(1).phase.state(:,1);
% Y_star  = solution(1).phase.state(:,2);
% thetar_star = solution(1).phase.state(:,3);
% X_guess  = guess(1).phase.state(:,1);
% Y_guess  = guess(1).phase.state(:,2);

% Make the plots
figure;
set(gcf, 'Position', [700 80 500 350]);
set(gcf,'color','w');
hold on

patch('faces',edges(:,1:2),'vertices',nodes, ...
    'FaceColor','w', ...
    'edgecolor',[.1,.1,.1],'edgealpha',1, ...
    'linewidth',1.5) ;

h4 = plot(x(:,1),x(:,2),'-.','LineWidth',1.5','Color',[0.4660 0.6740 0.1880]);

grid on
xlabel('x');
ylabel('y');
% xlim([xMin xMax]);
% ylim([yMin yMax]);
daspect([1 1 1]);
