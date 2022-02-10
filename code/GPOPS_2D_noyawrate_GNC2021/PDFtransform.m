function output = PDFtransform(X,Y,Z)
% output = 0.001*(X.^2+(Y+25).^2)-30*Z; % smaller area
output = 0.001*(X.^2+(Y+25).^2)-200*Z; % bigger area
% output = Z;
end