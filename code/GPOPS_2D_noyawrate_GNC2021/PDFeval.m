function output = PDFeval(X,Y)
% output = exp(-0.0000005*(40*(Y+25)-1*(X).^2).^2).*exp(-0.0003*(X.^2+Y.^2))- 2*exp(-0.001*(X.^2+(Y-2).^2))/3;
% output = exp(-0.0000005*(40*(Y+25)-1*(X).^2).^2).*exp(-0.0005*(X.^2+Y.^2))- 2*exp(-0.001*(X.^2+(Y-2).^2))/3; % smaller area
% output = exp(-0.000000002*(200*(Y+25)-1*(X).^2).^2).*exp(-0.00002*(X.^2+(Y+25).^2))- 2*exp(-0.0001*(X.^2+(Y-80).^2))/3; % bigger area
output = 8*exp(-0.0000008*(60*(X+25)-1*(Y).^2).^2).*exp(-0.0001*(Y.^2+(X+25).^2)); % moderate area

output(find(output>3))=3;
end