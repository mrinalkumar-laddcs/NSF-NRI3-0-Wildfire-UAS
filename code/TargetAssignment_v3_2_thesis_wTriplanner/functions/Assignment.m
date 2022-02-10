function assign = Assignment(CM,nI,nJ)
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
end