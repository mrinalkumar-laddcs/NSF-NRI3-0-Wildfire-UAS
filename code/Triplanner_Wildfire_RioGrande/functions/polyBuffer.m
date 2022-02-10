function newObs = polyBuffer(obs,domain,delta)
global fig_draw

for i = 1:size(obs,2)
    obsarrayX{i} = obs(i).polygon(:,1);
    obsarrayY{i} = obs(i).polygon(:,2);
end

polyin = polyshape(obsarrayX,obsarrayY);
% polyout = polybuffer(polyin,conservativeDelta);
polyout = polybuffer(polyin,delta,'JointType','miter','MiterLimit',2);
% polyout = polybuffer(polyin,conservativeDelta,'JointType','square');
polyshapes = regions(polyout);

% figure;
% plot(polyin)
% hold on
% plot(polyout)

for i = 1:size(polyshapes,1)
    newObs(i).polygon = polyshapes(i).Vertices;
end

% Plot obstacle and its boundaries
if fig_draw == 1
    plotObstacles(obs,newObs,domain,1,delta);
end

end