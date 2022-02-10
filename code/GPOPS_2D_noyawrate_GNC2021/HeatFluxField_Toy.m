clear all; close all; clc;

xMin      =  0;   xMax      = 180;
yMin      =  0;   yMax      = 170;

grid_size = 1;

% [X,Y] = meshgrid([xMin:grid_size:xMax],[yMin:grid_size:yMax]);
% Z = 6*exp(-0.002*(0.2*((X-80).^2) + (Y-90).^2 - 0.2*(X-80).*(Y-90)));

% [X,Y] = meshgrid([-xMax:grid_size:xMax],[-yMax:grid_size:yMax]);
% Z = 15*exp(-0.000003*(40*(X+25)-1*(Y).^2).^2).*exp(-0.0001*(Y.^2+(X+25).^2)); % moderate area
% Z(find(Z>3))=9;
% % Z(find(Z<1))=0;
% X0 = 70;
% Y0 = 80;
% X = X + X0;
% Y = Y + Y0;

[X,Y] = meshgrid([xMin:grid_size:xMax],[yMin:grid_size:yMax]);
Z = 10*ones(size(X));
Z(find((X<40 | X>140 | Y<40 | Y>120))) = 0;

figure;
surf(X,Y,Z);
view([0 90]);
% pcolor(X,Y,Z);
hold on
contour(X,Y,Z,[1e-1 1e-1]);
% contour(X,Y,Z,[1 1]);
plot(90,5,'o');
plot(80,145,'o');
xlabel('X');
ylabel('Y');
xlim([xMin xMax]);   
ylim([yMin yMax]);
box on

heatdata.X = X;
heatdata.Y = Y;
heatdata.HF = Z;

% save('heatdata_toy','heatdata');
% save('heatdata_toy2','heatdata');
% save('heatdata_toy3','heatdata');
save('heatdata_toy4','heatdata');