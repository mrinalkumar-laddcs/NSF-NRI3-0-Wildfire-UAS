function [tri_mesh,guessGen] = polygonMesh(node,edge,polygonSize,sXY,tXY,boundRectXY,vehdata,winddata)
% [mesh,guessGen] = polygonMesh(nodes,edges,polySize,startPt,finalPt,bound);

% boundRectXY = [xMin yMin; xMax yMin; xMax yMax; xMin yMax]; % coordinates of Bounding Box
boundEdges = [(1:3)' (2:4)'; 4 1];

% Start and End Points
%sXY = [X0 Y0];
%tXY = [Xf Yf];

tic
% Trigulation Process
if isempty(node) || isempty(edge) || isempty(polygonSize)
    boundEdges(:,3) = 1;
    nodeList = boundRectXY;
    edgeList = boundEdges;
else
    boundEdges(:,3) = 1;
    edge(:,3) = 2;
    nodeList = [boundRectXY; node];
    edgeList = [boundEdges; size(boundRectXY,1)+edge];
end

part{1} = [ ...
    find(edgeList(:,3) == 0) 
    find(edgeList(:,3) == 1)
    ] ;
part{2} = [ ...
    find(edgeList(:,3) == 1)
    ] ;

edgeList = edgeList(:,1:2);


%---------------------------------------------- do size-fun.
[vlfs,tlfs, ...
hlfs] = lfshfn2(nodeList,edgeList) ;

[slfs] = idxtri2(vlfs,tlfs) ;

pmax = max(nodeList,[],1);
pmin = min(nodeList,[],1);

hmax = mean(pmax-pmin)/+17 ;
hlfs = min(hmax,hlfs);   
   
%---------------------------------------------- do mesh-gen.
% hfun = @trihfn2;
% hfun = 3;
% hfun = @hfun_custom;
hfun = hfun_custom(vlfs);

opts.kind = 'delaunay';
opts.rho2 = +1.0;

[vert,etri, ...
    tria,tnum] = refine2(nodeList,edgeList,[],[],hfun , ...
    vlfs,tlfs,slfs,hlfs);

% hfun = 3;
% [vert,etri,tria,tnum] = refine2(nodeList,edgeList,[],opts,hfun); % triangulation mesh
[vert,etri,tria,tnum] = smooth2(vert,etri,tria,tnum);       % optimization of mesh for smoothness
% [vnew,enew,tnew,tnum] = tridiv2(vert,etri,tria,tnum);       % mesh division
% [vert,etri,tria,tnum] = smooth2(vnew,enew,tnew,tnum);       % optimization of mesh for smoothness
% [vnew,enew,tnew,tnum] = tridiv2(vert,etri,tria,tnum);       % mesh division
% [vert,etri,tria,tnum] = smooth2(vnew,enew,tnew,tnum);       % optimization of mesh for smoothness

[~,S_idx] = min(pdist2(vert,sXY,'euclidean'));
[~,T_idx] = min(pdist2(vert,tXY,'euclidean'));
vert = vert;
vert(S_idx,:) = sXY;
vert(T_idx,:) = tXY;
triKO = triangulation(tria,vert);                           % triangulation object
edgeList = edges(triKO);
toc

tic
s = edgeList(:,1);
t = edgeList(:,2);
mesh_graph = graph(s,t,edgeWeights(vert(s,:),vert(t,:),vehdata,winddata));
TR = shortestpath(mesh_graph,S_idx,T_idx);
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Plots
gen_plots = 1;

if gen_plots==1
% Mesh Plot
figure('color','w','Position', [200 80 500 350]);
patch('faces',tria(:,1:3),'vertices',vert, ...
    'FaceColor','w', ...
    'EdgeAlpha',0.3, ...
    'EdgeColor',[.2,.2,.2]) ;
hold on;
% patch('faces',edge(:,1:2),'vertices',node, ...
%     'FaceColor','w', ...
%     'EdgeColor',[.1,.1,.1], ...
%     'LineWidth',1.5) ;
xlabel('X');
ylabel('Y');
xlim([boundRectXY(1,1) boundRectXY(2,1)]);
ylim([boundRectXY(1,2) boundRectXY(3,2)]);
daspect([1 1 1]);
box on

% Generate Plots
figure('color','w','Position', [200 80 500 350]);
patch('faces',tria(:,1:3),'vertices',vert, ...
    'FaceColor','w', ...
    'EdgeAlpha',0.3, ...
    'EdgeColor',[.2,.2,.2]) ;
hold on; 
h1 = plot(vert(TR,1),vert(TR,2),'-r','LineWidth',1);
% patch('faces',edge(:,1:2),'vertices',node, ...
%     'FaceColor','w', ...
%     'EdgeColor',[.1,.1,.1], ...
%     'LineWidth',1.5) ;
xlabel('X');
ylabel('Y');
xlim([boundRectXY(1,1) boundRectXY(2,1)]);
ylim([boundRectXY(1,2) boundRectXY(3,2)]);
daspect([1 1 1]);
legend([h1],{'Shortest Path'},'Location','NorthWest');
box on

end

% Return Outputs
tri_mesh = 0;
guessGen.x = vert(TR,1);
guessGen.y = vert(TR,2);
end

%% %%%% Local Functions %%%%
function output = edgeWeights(startList,endList,vehdata,winddata)
output = sqrt((startList(:,1)-endList(:,1)).^2 + (startList(:,2)-endList(:,2)).^2);
end

function [hfun] = hfun_custom(test)
    fac = 50;
    domain_xmin = min(test(:,1));
    domain_xmax = max(test(:,1));
    domain_ymin = min(test(:,2));
    domain_ymax = max(test(:,2));
    hfun = min([(domain_xmax-domain_xmin)/fac,(domain_ymax-domain_ymin)/fac]);
end