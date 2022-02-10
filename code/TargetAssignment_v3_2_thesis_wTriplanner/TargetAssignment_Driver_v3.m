% Assignment Problem for Wildfire Agent target allocation
%
% Toy Problem version
%
% Author: Rachit Aggarwal
% Last Update Date: June 16, 2020

close all; clear all; clc;
addpath('data');
addpath('functions');

%-------------------------------------------------------------------------%
% Simulation Features
%-------------------------------------------------------------------------%
% Simulation Features
returnHomeEn = 1;     % Enable Return Home Feature by constraining battery
restoreBatt  = 1;     % Enable Restore battery by recharging upon return

HeatFluxShow = 1;
HeatFluxEnable = 1;

FireEstModes = {1,'Current';
                2,'Forecast'
                };
FireEstType  = 2;

% Select Problem Scenarios:
% Domain
DomainScenarios = {1,'Taos';
                   2,'Toy'
                   };
DomainScenarioType = 1;

% Fire Data
FireScenarios = {1,'Taos';
                 2,'Toy'
                 };
FireScenarioType = 1;

% Conflict
ConfScenarios = {1,'Taos';
                 2,'Toy: Random Conflicts';
                 3,'Toy: Fixed # of Conflicts';
                 };
ConfScenarioType = 1;

% Select Planner Mode:
PlannerModes = {1,'No Obstacle Avoidance';                 % Uses Euclidean Distances
                2,'Obstacle Avoidance without Heat';       % OA for general; uses grid or Triplanner
                3,'Obstacle Avoidance with Heat Threshold';% OA for general & high heat flux zones; 
                                                           % uses grid or Triplanner
                4,'Obstacle Avoidance with Temp Limits';   % Uses grid for OA and Temp limits for heat
                };
PlannerType = 1;

% Select Agent Start Mode:
AgentStartModes = {1,'Home';
                   2,'Random';
                   };
AgentStartType = 1;

%-------------------------------------------------------------------------%
% Setup Problem Parameters
%-------------------------------------------------------------------------%
run TargetAssignment_ProblemPara.m

%-------------------------------------------------------------------------%
% Sanity Checks
%-------------------------------------------------------------------------%
% run TargetAssignment_SanityChecks.m

% checks on Scenarios
% checks on HeatFluxShow, HeatFluxEnable
% check on various Time Steps

%-------------------------------------------------------------------------%
% Problem Setup
%-------------------------------------------------------------------------%
run TargetAssignment_ProblemSetup.m

%-------------------------------------------------------------------------%
% Run Simulation
%-------------------------------------------------------------------------%
% run TargetAssignement_RunSim.m
% nStepsFireEst = floor((T_end-T_start)/deltaTfireEst);
% nStepsMission = floor(deltaTfireEst/deltaTmission);
% nStepsConf    = floor(deltaTmission/deltaTconf);
% nStepsDyna    = floor(deltaTconf/deltaTdyna);
nStepsFireEst = floor((T_end-T_start)/deltaTfireEst);
nStepsMission = floor(deltaTfireEst/deltaTmission);
nStepsDyna    = floor(deltaTmission/deltaTdyna);

nStepsFireEst = 3;
% nStepsMission = 1;
% nStepsConf = 1;
% nStepsDyna = 1;

figNum = figure('position', [50, 50, 700, 550]);
cmap = colormap('hot');
new_cmap = flipud(cmap(20:end,:));

for i = 1:nStepsFireEst
    if FireEstType == 1
        T = T_start + (i-1)*deltaTfireEst;
    elseif FireEstType == 2
        T = T_start + i*deltaTfireEst;
    end
    
    if FireScenarioType == 1
        % Get Heat Flux Data
        env.heatflux = GetHeatFluxData(DroneFluxMean,DroneFluxVar,env.dom,T);
        env.heatflux.thresh = 7;
        env.heatflux.hazardCell = GetHazardRegions(env,T);
    end
    
    for j = 1:nStepsMission
        % Assign Conflict Location and their Values (weights between 0 to 1)
        if ConfScenarioType == 1      % Taos Wildfire Simulation
            % [confLoc,confVal] = GetConflictData(ConflictCell,env.dom,T_start+(i-1)*deltaTfireEst+(j-1)*deltaTmission);
            [confLoc,confVal] = GetConflictDataCum(ConflictCell,env.dom,T_start+(i-1)*deltaTfireEst+(j-1)*deltaTmission,deltaTmission);
        elseif ConfScenarioType == 2  % Random Number of Conflict Points
            nConf = randi([nConf_min,nConf_max],1);
            confLoc = [env.roi.xMin+(env.roi.xMax-env.roi.xMin)*rand(nConf,1), env.roi.yMin+(env.roi.yMax-env.roi.yMin)*rand(nConf,1)];
            confVal = rand(nConf,1);
        elseif ConfScenarioType == 3  % Fixed Number of Conflict Points
            nConf = nConf_fix;
            confLoc = [env.roi.xMin+(env.roi.xMax-env.roi.xMin)*rand(nConf,1), env.roi.yMin+(env.roi.yMax-env.roi.yMin)*rand(nConf,1)];
            confVal = rand(nConf,1);
        else
            error('Invalid Scenario Type');
        end
        conf = Conflict(confLoc,confVal);
        
        % Restore Energy aka Recharge Battery (will check if enabled)
        agent.ResetEnergy(restoreBatt);
        
        % HeatFluxShow = 1;
        % HeatFluxEnable = 1;
        %
        % if PlannerType == 1 % No Obstacle Avoidance
        %     % Disable Heatflux
        %     % Showing Optional
        % elseif PlannerType == 2 % Obstacle Avoidance without Heat
        %     % Disable Heatflux
        %     % Showing Optional
        % elseif PlannerType == 3 % Obstacle Avoidance with Heat Threshold
        %     % Enable Heatflux
        %     % Showing Required (with Islands)
        % elseif PlannerType == 4 % Obstacle Avoidance with Temp Limits
        %     % Enable Heatflux
        %     % Showing Required (with gradient shaded regions)
        % else
        %     error('Invalid Planner Type Selection');
        % end
               
        %---------------------------%
        % Under Testing
        disp(['Mission # ',num2str(j)]);
        agent.MissionDesign(conf,alpha,returnHomeEn,PlannerType,env);     
%         save('agentData','agent');
%         load('agentData','agent');
        
        for p = 1:nStepsDyna
            timeStamp = T_start + (i-1)*deltaTfireEst + (j-1)*deltaTmission + (p-1)*deltaTdyna;
            UpdateFigure(figNum,new_cmap,agent,conf,env,timeStamp,AgentSpeed,AgentEnergyMax,txtOffset)
            
            disp(['Update Step: ',num2str(p)]);
            agent.UpdateCurrentStats(deltaTdyna,returnHomeEn);
            agent.ReturnToHome(returnHomeEn,PlannerType,env,deltaTmission-(p-1)*deltaTdyna);
            agent.ShowStats();
        end
    end
end