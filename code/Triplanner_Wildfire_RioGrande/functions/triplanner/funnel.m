% Function to generate ordered funnel triangulation mesh
function tri_funnel_ordered = funnel(tri,path)
edgeIntersectList = [];
triIDList = [];

triEdges = edges(tri);
triPoints = tri.Points;

path_sections = size(path,1)-1;

for i = 1:path_sections
    path_edge = [path(i,:); path(i+1,:)];
       
    for j = 1:size(triEdges,1)
        tri_edge_seg = [triPoints(triEdges(j,1),:); triPoints(triEdges(j,2),:)];
        if twoSegIntersect(path_edge,tri_edge_seg)
            edgeIntersectList = [edgeIntersectList; j];
            triID = edgeAttachments(tri,triEdges(j,1),triEdges(j,2));
            triIDList = [triIDList; triID{:}'];
        end
    end
end

triIDList_compressed = unique(triIDList);
tri_funnel = triangulation(tri.ConnectivityList(triIDList_compressed,:),tri.Points);

% Ordering of the triangulation
% 1: Get the incenters of the general triangulation of the funnel
dualVertices = incenter(tri_funnel);

% 1: Get the triangle ID for start point and final point
startTriID = pointLocation(tri_funnel,path(1,:));
finalTriID = pointLocation(tri_funnel,path(end,:));

% 3: Pairwise adjacent triangle ID list
edgeList = edges(tri_funnel);
edgeTable_cell = edgeAttachments(tri_funnel,edgeList(:,1),edgeList(:,2));
edgeTable_mat = cell2mat(edgeTable_cell(cellfun('size',edgeTable_cell,2)==2));
s = edgeTable_mat(:,1);
t = edgeTable_mat(:,2);

% 4: Generate Dual of Triangulation
dual_graph = graph(s,t,edgeWeights(dualVertices(s,:),dualVertices(t,:)));

% 5: Generate the shortestpath in the dual
triOrder = shortestpath(dual_graph,startTriID,finalTriID);

% 6: Ordered funnel
tri_funnel_ordered = triangulation(tri_funnel.ConnectivityList(triOrder,:),tri_funnel.Points);

% Plotting for Debugging
% figure;
% triplot(tri_funnel);
% for i = 1:size(tri_funnel.ConnectivityList,1)
%     inCenter = incenter(triangulation(tri_funnel(i,:),tri_funnel.Points));
%     text(inCenter(:,1),inCenter(:,2),num2str(i));
% end
% 
% 
% figure;
% triplot(tri_funnel_ordered);
% for i = 1:size(tri_funnel_ordered.ConnectivityList,1)
%     inCenter = incenter(triangulation(tri_funnel_ordered(i,:),tri_funnel.Points));
%     text(inCenter(:,1),inCenter(:,2),num2str(i));
% end
end

function output = edgeWeights(startList,endList)
output = sqrt((startList(:,1)-endList(:,1)).^2 + (startList(:,2)-endList(:,2)).^2);
end