% Triplanner is provides a list of triangulation edges only.
% This function converts the edge list to triangulation object, so that
% MATLAB's triangulation operations can be performed.

% Works log:
% Add tolerance

function tri = edge2tri(input_edges,domain,tol)
if size(input_edges,2) == 4 && size(input_edges,1)>=3
    nE = size(input_edges,1);
    
%     vert1 = unique([input_edges(:,1:2); input_edges(:,3:4)],'rows');
    vert = [input_edges(1,1:2)];
    edgeList = zeros(nE,2);
    for i = 1:nE
        for j = 1:2
            result = isvertex(vert,input_edges(i,(j-1)*2+(1:2)),tol);
            if any(result)
                edgeList(i,j) = find(result);
            else
                vert = [vert; input_edges(i,(j-1)*2+(1:2))];
                result = isvertex(vert,input_edges(i,(j-1)*2+(1:2)),tol);
                edgeList(i,j) = find(result);
            end
        end
    end
    
%     edge = cell(nE,2);
%     edgeList = unique(edgeList,'rows');
%     for i = 1:nE
%         edge{i,1} = i;               % Edge ID
%         edge{i,2} = edgeList(i,1:2); % Copy the edges
%         edge{i,3} = 0;               % Set edgeAttachment count to 0;
%     end
%     
%     tri_ctr = 0;
%     for i = 1:nE
%         edgeID1 = i;
%         
%         v1 = edge{i,2}(1,1);
%         v2 = edge{i,2}(1,2);
%         
%         edge2 = edge;
%         edge2(edgeID1,:)=[];
%         [v3,edgeID2] = nextVert(edge2,v2);
%         for j = 1:size(v3,1)
%             edge3 = edge2;
%             edge3(edgeID2(j),:) = [];
%             [v4,edgeID3] = nextVert(edge3,v3(j));
%             for k = 1:size(v4,1)
%                 if v4(k) == v1
%                     if edge{edgeID1,3} <= 2 & edge{edgeID2(j),3} <= 2 & edge{edgeID3(k),3} <= 2
%                     tri_ctr = tri_ctr + 1;
%                     TriConn(tri_ctr,:) = [v1 v2 v3(j)];
%                     end
%                     edge{edgeID1,3} = edge{edgeID1,3} + 1;
%                     edge{edgeID2(j),3} = edge{edgeID2(j),3} + 1;
%                     edge{edgeID3(k),3} = edge{edgeID3(k),3} + 1;
%                 end
%             end
%         end    
%     end
    
%     nV = size(vert,1);
%     for p = 1:nV
%         v1 = p;
%         edge1 = edge;
%         [v2,edgeID1] = nextVert(edge1,v1);
%         edge1_flag = 0;
%         for i = 1:size(v2,1)
%             if edge{find(cell2mat(edge(:,1))==edgeID1(i)),3} < 2
% %                 edge2 = edge1;
%                 edge2 = edge;
%                 edge2(find(cell2mat(edge2(:,1))==edgeID1(i)),:)=[];
%                 [v3,edgeID2] = nextVert(edge2,v2(i));
%                 edge2_flag = 0;
%                 for j = 1:size(v3,1)
%                     if edge{find(cell2mat(edge(:,1))==edgeID2(j)),3} < 2
% %                         edge3 = edge2;
%                         edge3 = edge;
%                         edge3(find(cell2mat(edge3(:,1))==edgeID2(j)),:) = [];
%                         [v4,edgeID3] = nextVert(edge3,v3(j));
%                         edge3_flag = 0;
%                         for k = 1:size(v4,1)
%                             if edge{find(cell2mat(edge(:,1))==edgeID3(k)),3} < 2
%                                 if v4(k) == v1
%                                     tri_ctr = tri_ctr + 1;
%                                     TriConn(tri_ctr,:) = [v2(i) v3(j) v4(k)];
%                                     
%                                     
%                                     edge{edgeID3(k),3} = edge{edgeID3(k),3} + 1;
%                                     edge3_flag = 1;
%                                 end
%                             end
%                         end
%                         if edge3_flag == 1
%                             edge{edgeID2(j),3} = edge{edgeID2(j),3} + 1;
%                             edge2_flag = 1;
%                         end
%                     end
%                 end
%                 if edge2_flag == 1
%                     edge{edgeID1(i),3} = edge{edgeID1(i),3} + 1;
%                     edge1_flag = 1;
%                 end
%             end
%         end
%     end
%     TriConn2 = sort(TriConn,2);
%     TriConn3 = unique(TriConn2,'rows');
%     tri = triangulation(TriConn3,vert);
    
    tri = delaunayTriangulation(vert,edgeList);
    
%     figure;
%     triplot(TriConn,vert(:,1),vert(:,2));
%     figure;
%     triplot(tri.ConnectivityList,tri.Points(:,1),tri.Points(:,2));
    
    % Filter out the edges outside the domain
    domain_boundary = [domain(1,1) domain(1,2);
                       domain(1,3) domain(1,1);
                       domain(1,3) domain(1,4);
                       domain(1,1) domain(1,4)];
    points_in = inpolygon(tri.Points(:,1),tri.Points(:,2),domain_boundary(:,1),domain_boundary(:,2));
    points_indx_out = find(~points_in);
    tri.Points(points_indx_out,:) = [];
    
%     figure;
%     triplot(tri.ConnectivityList,tri.Points(:,1),tri.Points(:,2));
    
else
    disp('Wrong input to function ''edge2tri()''. Input must be n-by-4 matrix and n >=3.');
end

end

function output = isvertex(A,B,tol)
dis = sqrt((A(:,1)-B(1,1)).^2+(A(:,2)-B(1,2)).^2);
output = dis < tol;
end

% function [next_vert,edgeID] = nextVert(edge,prev_vert)
% next_vert = [];
% edgeID = [];
% nE = size(edge,1);
% for j = 1:nE
%     if edge{j,3} < 2
%     if edge{j,2}(1,1) == prev_vert
%         next_vert = [next_vert; edge{j,2}(1,2)];
%         edgeID = [edgeID; edge{j,1}];
%     end
%     if edge{j,2}(1,2) == prev_vert
%         next_vert = [next_vert; edge{j,2}(1,1)];
%         edgeID = [edgeID; edge{j,1}];
%     end
%     end
% end
% end