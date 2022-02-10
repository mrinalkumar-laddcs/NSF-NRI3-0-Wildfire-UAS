%-------------------------------------------------------------------------%
%                             Extract Solution                            %
%-------------------------------------------------------------------------%
% t_star  = solution(1).phase.time;
% u_star = solution(1).phase.control(:,1);
% X_star  = solution(1).phase.state(:,1);
% Y_star  = solution(1).phase.state(:,2);
% thetad_star = solution(1).phase.state(:,3);
% X_guess  = guess(1).phase.state(:,1);
% Y_guess  = guess(1).phase.state(:,2);
% Theta_guess = guess(1).phase.state(:,4);

% Make the plots
figure;
set(gcf, 'Position', [50, 50, 700, 550]);
set(gcf,'color','w');
hold on
cmap = colormap('hot');
new_cmap = flipud(cmap(20:end,:));
hold on;
colormap(new_cmap);
if ~strcmp(heat_opt,'no fire')
    % contour(heatdata.X,heatdata.Y,heatdata.HF);
    p2 = pcolor(heatdata.X, heatdata.Y, heatdata.HF);
    set(p2, 'EdgeColor','none');
    
end
if obsEnable ~= 0
    patch('faces',faces,'vertices',nodes, ...
        'FaceColor','w', ...
        'FaceAlpha',0, ...
        'EdgeColor',[.1,.1,.1], ...
        'LineWidth',1.5) ;
end
h1 = plot(X0,Y0,'*','LineWidth',2');
h2 = plot(Xf,Yf,'*','LineWidth',2');
h3 = plot(X_guess,Y_guess,'-','LineWidth',1.5);
arrow_scale = 0.2;
quiver(X_guess,Y_guess,cos(Theta_guess),sin(Theta_guess),arrow_scale);

% grid on
xlabel('X');
ylabel('Y');
xlim([xMin xMax]);
ylim([yMin yMax]);
daspect([1 1 1]);
% legend([h1 h2 h3 h4],{'Initial Point', 'Final Point','Deterministic Constraint' ,'Optimal Path'});
% legend([h1 h2 h3 h4],{'Initial Point', 'Final Point','Guess Path','Optimal Path'});
% title('Deterministic Constraints');
% title('Chance Constraints');

% figure;
% plot(t_star,u_star,'-o');
% hold on
% grid on
% xlabel('Time,t');
% legend('u');
% xlim([0 max(t_star)]);
% ylim([min(u_star) max(u_star)]);
