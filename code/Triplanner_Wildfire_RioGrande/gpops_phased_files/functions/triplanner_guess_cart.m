function guess = triplanner_guess_cart(tri_funnel,path,auxdata,u0)
n = 5;

numPhases = size(tri_funnel,1);
guess.phase = struct('time',cell(1,numPhases),'state',cell(1,numPhases),'control',cell(1,numPhases));

V  = auxdata.V;

% edgeIntersectList = [];
% triEdges = edges(tri_funnel);
% triPoints = tri_funnel.Points;
% dualVertices = incenter(tri_funnel);
% 
% for i = 1:(size(dualVertices,1)-1)
%     dual_seg = [dualVertices(i,:); dualVertices(i+1,:)];
%        
%     for j = 1:size(triEdges,1)
%         tri_edge_seg = [triPoints(triEdges(j,1),:); triPoints(triEdges(j,2),:)];
%         if twoSegIntersect(dual_seg,tri_edge_seg)
%             edgeIntersectList = [edgeIntersectList; j];
%         end
%     end
% end

for i = 1:(size(path,1)-1)
    startTriID = pointLocation(tri_funnel,path(i,:));
    finalTriID = pointLocation(tri_funnel,path(i+1,:));
    
    path_seg = [path(i,:); path(i+1,:)];
    
    if finalTriID-startTriID == 0
        % Same Triangle Case
        x = linspace(path(i,1),path(i+1,1),n)';
        y = linspace(path(i,2),path(i+1,2),n)';
        theta = atan2(path(i+1,2)-path(i,2),path(i+1,1)-path(i,1))*ones(n,1);
        guess.phase(startTriID).state    = [guess.phase(startTriID).state; x y theta];
    else
        %------%
        edgeIntersectList = [];
        tri_funnel_subset = triangulation(tri_funnel(startTriID:finalTriID,:),tri_funnel.Points);
%         triEdges = edges(tri_funnel_subset);
        triPoints = tri_funnel_subset.Points;
        dualVertices = incenter(tri_funnel_subset);
        
%         for itr = 1:(size(dualVertices,1)-1)
%             dual_seg = [dualVertices(itr,:); dualVertices(itr+1,:)];
%             
%             for jtr = 1:size(triEdges,1)
%                 tri_edge_seg = [triPoints(triEdges(jtr,1),:); triPoints(triEdges(jtr,2),:)];
%                 if twoSegIntersect(dual_seg,tri_edge_seg)
%                     edgeIntersectList = [edgeIntersectList; jtr];
%                 end
%             end
%         end
        
        for itr = 1:(size(dualVertices,1)-1)
            dual_seg = [dualVertices(itr,:); dualVertices(itr+1,:)];
            triEdges = edges(triangulation(tri_funnel_subset.ConnectivityList(itr:itr+1,:),tri_funnel.Points));
            for jtr = 1:size(triEdges,1)
                tri_edge_seg = [triPoints(triEdges(jtr,1),:); triPoints(triEdges(jtr,2),:)];
                if twoSegIntersect(dual_seg,tri_edge_seg)
                    edgeIntersectList = [edgeIntersectList; triEdges(jtr,:)];
                end
            end
        end
        %------%
        
        for TriID = startTriID:(finalTriID-1)
            k = TriID-startTriID+1; % edgeIntersectList Index
            if TriID == startTriID
                % First Triangle of the long path segment
%                 tri_edge_seg = [triPoints(triEdges(edgeIntersectList(k,1),1),:);
%                                 triPoints(triEdges(edgeIntersectList(k,1),2),:)];
                tri_edge_seg = [triPoints(edgeIntersectList(k,1),:);
                                triPoints(edgeIntersectList(k,2),:)];
                [~,xI,yI] = twoSegIntersect(path_seg,tri_edge_seg);
                x = linspace(path(i,1),xI,n)';
                y = linspace(path(i,2),yI,n)';
                theta = atan2(yI-path(i,2),xI-path(i,1))*ones(n,1);
            else
                % Middle Triangle(s) of the long path segment
%                 tri_edge_seg_prev = [triPoints(triEdges(edgeIntersectList(k-1,1),1),:);
%                                      triPoints(triEdges(edgeIntersectList(k-1,1),2),:)];
                tri_edge_seg_prev = [triPoints(edgeIntersectList(k-1,1),:);
                                     triPoints(edgeIntersectList(k-1,2),:)];
                [~,xI_prev,yI_prev] = twoSegIntersect(path_seg,tri_edge_seg_prev);
                
%                 tri_edge_seg = [triPoints(triEdges(edgeIntersectList(k,1),1),:);
%                                 triPoints(triEdges(edgeIntersectList(k,1),2),:)];
                tri_edge_seg = [triPoints(edgeIntersectList(k,1),:);
                                triPoints(edgeIntersectList(k,2),:)];
                [~,xI,yI] = twoSegIntersect(path_seg,tri_edge_seg);
                
                x = linspace(xI_prev,xI,n)';
                y = linspace(yI_prev,yI,n)';
                theta = atan2(yI-yI_prev,xI-xI_prev)*ones(n,1);
            end
            guess.phase(TriID).state    = [guess.phase(TriID).state; x y theta];
        end
        % Last Triangle of the long path segment
%         tri_edge_seg_prev = [triPoints(triEdges(edgeIntersectList(k,1),1),:);
%                              triPoints(triEdges(edgeIntersectList(k,1),2),:)];
        tri_edge_seg_prev = [triPoints(edgeIntersectList(k,1),:);
                             triPoints(edgeIntersectList(k,2),:)];
        [tf,xI_prev,yI_prev] = twoSegIntersect(path_seg,tri_edge_seg_prev);
                
        x = linspace(xI_prev,path(i+1,1),n)';
        y = linspace(yI_prev,path(i+1,2),n)';
        theta = atan2(path(i+1,2)-yI_prev,path(i+1,1)-xI_prev)*ones(n,1);
        guess.phase(finalTriID).state    = [guess.phase(finalTriID).state; x y theta];
    end    
end

for i = 1:numPhases
    x = guess.phase(i).state(:,1);
    y = guess.phase(i).state(:,2);
    dist = sqrt((x(2:end,1)-x(1:end-1,1)).^2+(y(2:end,1)-y(1:end-1,1)).^2);
    cum_dist = cumsum(dist);
    if i == 1
        offset = 0;
    else
        offset = guess.phase(i-1).time(end,1);
    end
    guess.phase(i).time = offset + [0; cum_dist/V];
    guess.phase(i).control  = u0*ones(size(x,1),1);
end

for i = 1:numPhases
    [guess.phase(i).time, retain, ~] = unique(guess.phase(i).time,'rows');
    guess.phase(i).state  = guess.phase(i).state(retain,:);
    guess.phase(i).control  = guess.phase(i).control(retain,:);
end
end