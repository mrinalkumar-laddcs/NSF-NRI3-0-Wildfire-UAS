%-------------------------------------------------------------------------%
%                             Extract Solution                            %
%-------------------------------------------------------------------------%
t_star  = solution(1).phase.time;
u_star = solution(1).phase.control(:,1);
X_star  = solution(1).phase.state(:,1);
Y_star  = solution(1).phase.state(:,2);
thetad_star = solution(1).phase.state(:,3);
X_guess  = guess(1).phase.state(:,1);
Y_guess  = guess(1).phase.state(:,2);

% Make the plots
figure;
set(gcf, 'Position', [700 80 500 350]);
set(gcf,'color','w');
h1 = plot(X0,Y0,'*','LineWidth',2');
hold on
h2 = plot(Xf,Yf,'*','LineWidth',2');
patch('faces',edges(:,1:2),'vertices',nodes, ...
    'FaceColor','w', ...
    'edgecolor',[.1,.1,.1], ...
    'linewidth',1.5) ;
h3 = plot(X_guess,Y_guess,':','LineWidth',1.2');
h4 = plot(X_star,Y_star,'-.','LineWidth',1.5','Color',[0.4660 0.6740 0.1880]);

grid on
xlabel('x');
ylabel('y');
xlim([xMin xMax]);
ylim([yMin yMax]);
daspect([1 1 1]);
% legend([h1 h2 h3 h4],{'Initial Point', 'Final Point','Deterministic Constraint' ,'Optimal Path'});
legend([h1 h2 h3 h4],{'Initial Point', 'Final Point','Guess Path','Optimal Path'});
title('Deterministic Constraints');
% title('Chance Constraints');

% figure;
% plot(t_star,u_star,'-o');
% hold on
% grid on
% xlabel('Time,t');
% legend('u');
% xlim([0 max(t_star)]);
% ylim([min(u_star) max(u_star)]);
