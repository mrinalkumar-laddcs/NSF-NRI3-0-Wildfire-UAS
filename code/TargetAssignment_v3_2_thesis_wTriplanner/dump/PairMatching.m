% Matching Function for Wildfire Agent target allocation
% 
% Author: Rachit Aggarwal
% Last Update Date: April 30, 2020

% function matchedPairs = pairMatching(homeAgentLoc,currAgentLoc,confLoc,confVals,currRemainDist,alpha,returnHomeEn)
function matchedPairs = PairMatching(agent,conf,alpha,returnHomeEn)
nAgents = size(agent,1);
nConf   = size(conf,1);

homeAgentLoc = reshape([agent.homeLoc]',[size(agent(1).homeLoc,2), nAgents])';
currAgentLoc = reshape([agent.currLoc]',[size(agent(1).currLoc,2), nAgents])';
remainEnergy = reshape([agent.remainEnergy]',[size(agent(1).remainEnergy,1), nAgents])';
resEnergy    = reshape([agent.resEnergy],[size(agent(1).resEnergy,1), nAgents])';

confLoc = reshape([conf.Loc]',[size(conf(1).Loc,2), nConf])';
confVal = reshape([conf.Val]',[size(conf(1).Val,1), nConf])';

if nAgents<=nConf
    % Agent = i, Conf Point = j
    iLoc = currAgentLoc;
    jLoc = confLoc;
    nI = nAgents;
    nJ = nConf;
else
    % Conf Point = i, Agent = j
    iLoc = confLoc;
    jLoc = currAgentLoc;
    nI = nConf;
    nJ = nAgents;
end

distMat                 = pdist2(currAgentLoc,confLoc);
remainEnergyMat         = repmat(remainEnergy,1,nConf);
targetHomeDist          = pdist2(homeAgentLoc,confLoc);
remainEnergyForecastMat = remainEnergyMat - distMat - targetHomeDist;

normDistMat = distMat./max(distMat(:));

% DM = distMat; % distance
DM = distMat./max(distMat(:)); % normalized distance

% Cost Matrix:
% Min Distance only
% CM = DM;

% Max Conflict only
% CM = -ones(nAgents,nConf)*diag(confVal);
% CM = -ones(nAgents,nConf)*diag(1./(1-confVal));

% Distance and Conf Based:
CM = -alpha*ones(nAgents,nConf)*diag(confVal) + (1-alpha)*DM;
% CM = -alpha*ones(nAgents,nConf)*diag(1./(1-confVal)) + (1-alpha)*DM;
% CM = DM*diag(1./confVal);

if returnHomeEn == 1
    [r,c] = ind2sub([nAgents,nConf],find(remainEnergyForecastMat<0));
    for i = 1:size(r,1)
        CM(r(i),c(i)) = CM(r(i),c(i)) + 10;
    end
end

if nAgents<=nConf
    CM = CM';
end

% Objective Function
% min c'*x
c = CM(:);

%Constraints
numDim = nI * nJ;
onesvector = ones(1,nJ);

% A*x == b : each Agent is assigned exactly one target
% Aeq = blkdiag(onesvector,onesvector,onesvector,onesvector, ...
%     onesvector,onesvector);
Aeq = zeros(nI,numDim);
for i = 1:nI
    Aeq(i,(i-1)*nJ+(1:nJ)) = onesvector;
end
beq = ones(nI,1);

% A*x <= b : at most one Agent assigned to each target
A = repmat(eye(nJ),1,nI);
b = ones(nJ,1);

f = c;
lb = zeros(size(f));
ub = ones(size(f));
intvars = 1:length(f);
tic
options = optimoptions('intlinprog','Display','none');
[sol,fval,exitflag,output] = intlinprog(f,intvars,A,b,Aeq,beq,lb,ub,options);
toc

assign = reshape(sol,nJ,nI);

if nAgents<=nConf
    % Agent = i, Conf Point = j
    % nI = nAgents;
    % nJ = nConf;
    k = 1;
    for i=1:nAgents
        target = find(assign(:,i)');
        if ~isempty(target)
            matchedPairs(k,:) = [i, target(1,1)];
            k = k+1;
        end
    end
else
    % Conf Point = i, Agent = j
    % nI = nConf;
    % nJ = nAgents;
    k = 1;
    for i=1:nConf
        target = find(assign(:,i)');
        if ~isempty(target)
            matchedPairs(k,:) = [target(1,1) i];
            k = k+1;
        end
    end
end

% Check feasibility and reallocation targets
if returnHomeEn == 1
    for k = 1:size(matchedPairs,1)
        if remainEnergyForecastMat(matchedPairs(k,1),matchedPairs(k,2)) < 0
            matchedPairs(k,2) = -1*matchedPairs(k,1); % return home:
        end
    end
end

end