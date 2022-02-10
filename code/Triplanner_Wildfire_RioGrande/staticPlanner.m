function [stepResult] = staticPlanner(window,boundary,data_file,plannerMethod,domain,sys,vehicle)
% stepResult.risk.t,stepResult.risk.x,stepResult.risk.u,
% stepResult.risk.riskValue


% LOGIC: probab boundary aproach requires probab flux data only. nominal 
% boundary approach uses probab flux data to get nominal contour or use
% clustered data.
if boundary.typeID == 1 % Use Probabilitistic Boundary
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %----------- Data File Loading ------------%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load the Probabilistic Heat Flux Data file
    try
        load(data_file.flux);
    catch
        error(['Flux File ''', data_file.flux, '''does not exist.']);
    end
    
    if boundary.probab.risk.Mode == 1
        % Range of Risk Values:
        % WORK_IN_PROGRESS - Currently, it can be obtained manually for
        % specified risk values and then ploted together.
        
    else % boundary.probab.risk.Mode == 0
        % Single Value
        riskValue = boundary.probab.risk.Value;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %-------- Load/Generate Boundaries --------%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [status,obs]         = fluxPoly(FluxProbCube,xlong,ylat,domain,window.tFire,riskValue);
        newObs               = reducePoly(obs,domain);
        
        [change_flag,new_window] = updateStartFinalPointLocation(newObs,domain,window);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Path Planning for chosen risk and resulting obstacle Map %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if change_flag == 1
            [stepResult]         = deterministicPlanner(newObs,plannerMethod,domain,sys,new_window.startPoint,new_window.finalPoint,window.clearance,vehicle);
        else
            [stepResult]         = deterministicPlanner(newObs,plannerMethod,domain,sys,window.startPoint,window.finalPoint,window.clearance,vehicle);
        end
        stepResult.risk.riskValue = riskValue;
        stepResult.risk.obs       = newObs;
        stepResult.time           = window.tFire;
    end
    
else % boundary.typeID == 2 % Use Nominal Boundary
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %----------- Data File Loading ------------%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if data_file.typeID == 1
        % Load the Probabilistic Heat Flux Data file
        try
            load(data_file.flux);
        catch
            error(['Flux File ''', data_file.flux, '''does not exist.']);
        end
    else % data_file.typeID == 2
        % Load the Clustered Data file
        full_clusterfile = [data_file.clus '_' num2str(window.tFire) '.mat'];
        try
            load(full_clusterfile);
        catch
            error(['Cluster File ''', full_clusterfile, '''does not exist. Provide the file or use direct data approach']);
        end
    end
    
    if boundary.nominal.risk.Mode == 1
        % Range of Risk Values:
        % WORK_IN_PROGRESS - Currently, it can be obtained manually for
        % specified risk values and then ploted together.
        
    else % boundary.nominal.risk.Mode == 0
        % Single Value
        riskValue = boundary.nominal.risk.Value;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %-------- Load/Generate Boundaries --------%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        switch boundary.nominal.conservatism
            case 0
            disp('Nominal Boundary'); disp('');
            if data_file.typeID == 1
                NomRiskValue = boundary.nominal.flux.nominalRisk;
                [status,obs] = fluxPoly(FluxProbCube,xlong,ylat,domain,window.tFire,NomRiskValue); % pick nominal == 0.5
            else
                [status, obs] = clusPoly(bdry,domain); % pick nominal clustered as is
            end

            case 1
            disp('Conservative Case'); disp('');
            if data_file.typeID == 1
                ActRiskValue = boundary.nominal.flux.conservativeRisk;
                [status,obs] = fluxPoly(FluxProbCube,xlong,ylat,domain,window.tFire,ActRiskValue); % pick conservative == 0
            else
                [status, obs] = clusPoly(bdry,domain); % pick nominal clustered and then apply delta
            end

            case 2
            disp('Probabilistic Case'); disp('');
            if data_file.typeID == 1
                NomRiskValue = boundary.nominal.flux.nominalRisk;
                [status,obs] = fluxPoly(FluxProbCube,xlong,ylat,domain,window.tFire,NomRiskValue); % pick nominal == 0.5 and then apply computed delta
            else
                [status, obs] = clusPoly(bdry,domain); % pick nominal clustered and then apply computed delta
            end
            
            otherwise
            disp('Invalid type of approach under boundary.nominal.conservatism');
            return
        end

        newObs = reducePoly(obs,domain);
        
        switch boundary.nominal.conservatism
            case 0 % Nominal Boundary
            % No inflation, so no change in map

            case 1 % Conservative Case
            if data_file.typeID == 1 % comes with conservative case, so no change in map
            else % Inflate using conservative Delta
                newObs = polyBuffer(newObs,domain,boundary.nominal.clus.conservativeDelta);
            end

            case 2 % Probabilistic Case
            % Compute Delta and then Inflate using Delta
            p = 1-boundary.nominal.risk.Value;
            cauchy = boundary.nominal.cauchy;
            delta = cauchy.x0 + cauchy.gamma*tan(pi*(p-0.5));
            newObs = polyBuffer(newObs,domain,delta);
        end
        [change_flag,new_window] = updateStartFinalPointLocation(newObs,domain,window);
        % Path Planning for chosen risk and resulting obstacle Map
        if change_flag == 1
            [stepResult]         = deterministicPlanner(newObs,plannerMethod,domain,sys,new_window.startPoint,new_window.finalPoint,window.clearance,vehicle);
        else
            [stepResult]         = deterministicPlanner(newObs,plannerMethod,domain,sys,window.startPoint,window.finalPoint,window.clearance,vehicle);
        end
        stepResult.risk.riskValue = riskValue;
        stepResult.risk.obs       = newObs;
        stepResult.time           = window.tFire;
    end
end
end