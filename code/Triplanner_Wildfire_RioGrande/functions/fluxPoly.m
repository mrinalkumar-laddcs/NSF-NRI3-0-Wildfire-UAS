function [status, obs] = fluxPoly(FluxProbCube,xlong,ylat,domain,time,cutoff)
global transform

FluxCont = FluxProbCube(:,:,time);
ConMatrix = contourc(xlong, ylat, FluxCont, [cutoff cutoff]);

% works for single contour level only
if ~isempty(ConMatrix)
    curr_ind = 0;
    poly_ind = 0;
    while curr_ind ~= size(ConMatrix,2)
        curr_ind = curr_ind+1;
        poly_ind = poly_ind+1;
        ConPolySize = ConMatrix(2,curr_ind);
        bdry(poly_ind).polygon = [ConMatrix(1,curr_ind+(1:ConPolySize))' ConMatrix(2,curr_ind+(1:ConPolySize))'];
        curr_ind = curr_ind+ConPolySize;
    end
    obs = bdry;
    
    if transform == 1
        for i = 1:size(obs,2)
            obs(i).polygon(:,1) = obs(i).polygon(:,1)-domain.longmin;
            obs(i).polygon(:,2) = obs(i).polygon(:,2)-domain.latmin;
        end
    end
    
    status = 1;
else
    disp('Chosen contour level does not exist');
    status = 0;
end
end