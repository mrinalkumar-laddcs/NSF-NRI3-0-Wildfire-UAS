clear all; close all; clc;

xMin      =  0;   xMax      = 556;
yMin      =  0;   yMax      = 265;

grid_size = 5;

[X,Y] = meshgrid([xMin:grid_size:xMax],[yMin:grid_size:yMax]);

% Z = 7*exp(-0.001*(0.2*((X-220).^2) + 2*((Y-120).^2) - 0*(X-220).*(Y-120))); % Filename: winddata_map
Z = 12*exp(-0.001*(0.1*((X-220).^2) + 1*((Y-120).^2) - 0*(X-220).*(Y-120))); % Filename: winddata_map
% Z = 8*exp(-0.001*(0.2*((X-220).^2) + 2*((Y-140).^2) - 0*(X-220).*(Y-140))); % Filename: winddata_map2
% Z = 10*exp(-0.001*(0.2*((X-220).^2) + 2*((Y-120).^2) - 0*(X-220).*(Y-120))); % Filename: winddata_map2
[Vwx,Vwy] = gradient(Z);
Vwx = Z;
Vwy = zeros(size(Z));

figure;
% surf(X,Y,Z);
% pcolor(X,Y,Z);
hold on
quiver(X,Y,Vwx,Vwy);
xlabel('X');
ylabel('Y');
xlim([xMin xMax]);
ylim([yMin yMax]);
box on

winddata.X = X;
winddata.Y = Y;
winddata.Wx = Vwx;
winddata.Wy = Vwy;

save('winddata_map','winddata');