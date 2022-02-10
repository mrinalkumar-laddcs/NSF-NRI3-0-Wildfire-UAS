function [newObs] = polygonResize(obs,delta)
if size(obs,2) ~= 0
    tempObs = obs;
    newObs = obs;
    for i=1:size(obs,2)
        % Collinearity Check and Points Cleanup
        pgon_ip = polyshape(obs(i).polygon(:,1),obs(i).polygon(:,2));
        pgon_op = simplify(pgon_ip,'KeepCollinearPoints',false);
        tempObs(i).polygon = pgon_op.Vertices;
        
        tempObs(i).polySize = size(tempObs(i).polygon,1);        
        tempObs(i).edges = [(1:(tempObs(i).polySize-1))' (2:tempObs(i).polySize)'; tempObs(i).polySize 1];
        delta_edge = delta*ones(tempObs(i).polySize,1);
        
        % Re-arrange in to the form AX = b
        a = [(tempObs(i).polygon(tempObs(i).edges(:,2),2) - tempObs(i).polygon(tempObs(i).edges(:,1),2)),...
            -(tempObs(i).polygon(tempObs(i).edges(:,2),1) - tempObs(i).polygon(tempObs(i).edges(:,1),1))];
        b = [tempObs(i).polygon(tempObs(i).edges(:,1),1).*(tempObs(i).polygon(tempObs(i).edges(:,2),2) - tempObs(i).polygon(tempObs(i).edges(:,1),2))...
            - tempObs(i).polygon(tempObs(i).edges(:,1),2).*(tempObs(i).polygon(tempObs(i).edges(:,2),1) - tempObs(i).polygon(tempObs(i).edges(:,1),1))];

        % Parameters for new line
        bNew = b - delta_edge.*sqrt(a(:,1).^2+a(:,2).^2);
        a_temp = [a(end,:); a];
        b_temp = [bNew(end,:); bNew];
        newObs(i).polygon = zeros(tempObs(i).polySize,2);
        
        % Obtain intersection points by solving pair wise lines
        for j = 1:tempObs(i).polySize
            A = [a_temp(j,:); a_temp(j+1,:)];
            B = b_temp(j:(j+1),:);
            newObs(i).polygon(j,:) = linsolve(A,B)';
            newObs(i).polySize = size(newObs(i).polygon,1);
        end
    end
end
end