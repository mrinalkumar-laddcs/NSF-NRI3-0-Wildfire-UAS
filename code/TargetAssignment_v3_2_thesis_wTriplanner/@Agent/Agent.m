classdef Agent < handle
    %AGENT Summary of this class goes here
    %   Detailed explanation goes here
    
    % Future goals of the class:
    % - keep record of the time history of trajectory
    % - geo-fencing
    
    properties
        agentID
        
        % Fixed Properties:
        homeLoc
        speed
        maxEnergy
        resEnergy
        hoverPower
        motionPowerFac
        
        % Current Properties:
        agentStatus            % 'avail' or 'mission'
        missionNum
        
        currLoc
        remainPath
        remainEnergy
        
        % Logging Properties (indexed by Mission Number):
        missionTime            % Simulation Time Stamp when the mission is assigned
        targType               % 'home','mission','none'
        targLoc
        confVal                % Can be used later to see if a more imp conf point appears
        fullPath
    end
    
    methods
        function obj = Agent(agID)
            % Assign agent ID when the object is instantiated
            if nargin ~=0
                if size(agID,1)==1 || size(agID,2)==1
                    for i = 1:size(agID,1)
                        for j = 1:size(agID,2)
                            obj(i,j).agentID = agID(i,j);
                        end
                    end
                else
                    error('Provide a either a col-vector (prefered) or row-vector of agent IDs ');
                end
            end
        end
        
        obj = SetHome(obj,homeLoc)
        obj = SetSpeed(obj,speed)
        obj = SetEnergyParameters(obj,maxEnergy,resEnergy,hoverPower,motionPowerFac)
        
        obj = Reset(obj)
        obj = ResetEnergy(obj,restoreBatt)
        
        obj = MissionDesign(obj,conf,alpha,returnHomeEn,PlannerType,env)
        obj = ShowStats(obj)
        obj = UpdateCurrentStats(obj,deltaTdyna,returnHomeEn)
        obj = ReturnToHome(obj,returnHomeEn,PlannerType,env,time2nextMission)
    end
end

