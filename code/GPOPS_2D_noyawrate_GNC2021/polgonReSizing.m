function [newNodes,newEdges,newPolySize] = polgonReSizing(nodes,edges,polySize,delta)
newNodes = zeros(sum(polySize),2);

for i=1:length(polySize)
    if i == 1
        edgePoly = edges(1:sum(polySize(1,1)),:);
    else
        edgePoly = edges(sum(polySize(1:i-1,1))+1:sum(polySize(1:i,1)),:);
    end
    delta_edge = delta*ones(polySize(i),1);
    for j = 1:polySize(i)
        a = [(nodes(edgePoly(:,2),2) - nodes(edgePoly(:,1),2)), -(nodes(edgePoly(:,2),1) - nodes(edgePoly(:,1),1))];
        b = [nodes(edgePoly(:,1),1).*(nodes(edgePoly(:,2),2) - nodes(edgePoly(:,1),2)) - nodes(edgePoly(:,1),2).*(nodes(edgePoly(:,2),1) - nodes(edgePoly(:,1),1))];
        bNew = b + delta_edge.*sqrt(a(:,1).^2+a(:,2).^2);
    end
    a_temp = [a(end,:); a];
    b_temp = [bNew(end,:); bNew];
    newNodePoly = zeros(polySize(i),2);
    for j = 1:polySize(i)
        A = [a_temp(j,:); a_temp(j+1,:)];
        B = b_temp(j:(j+1),:);
        newNodePoly(j,:) = linsolve(A,B)';
    end
    if i == 1
        newNodes(1:sum(polySize(1,1)),:) = newNodePoly;
    else
        newNodes(sum(polySize(1:i-1,1))+1:sum(polySize(1:i,1)),:) = newNodePoly;
    end
end

newEdges = edges;
newPolySize = polySize;

polyInd = (1:length(newPolySize))';
polyComb = nchoosek(polyInd,2);
numRegion = zeros(size(polyComb,1),1);
for i = 1:size(polyComb,1)
    if polyComb(i,1) == 1
        poly1 = polyshape(newNodes(1:polySize(polyComb(i,1)),1),newNodes(1:polySize(polyComb(i,1)),2));
    else
        poly1 = polyshape(newNodes(sum(polySize(1:polyComb(i,1)-1,1))+1:sum(polySize(1:polyComb(i,1),1)),1),newNodes(sum(polySize(1:polyComb(i,1)-1,1))+1:sum(polySize(1:polyComb(i,1),1)),2));
    end
    
    if polyComb(i,2) == 1
        poly2 = polyshape(newNodes(1:polySize(polyComb(i,2)),1),newNodes(1:polySize(polyComb(i,2)),2));
    else
        poly2 = polyshape(newNodes(sum(polySize(1:polyComb(i,2)-1,1))+1:sum(polySize(1:polyComb(i,2),1)),1),newNodes(sum(polySize(1:polyComb(i,2)-1,1))+1:sum(polySize(1:polyComb(i,2),1)),2));
    end
    polyout = union(poly1,poly2);
    numRegion(i) = polyout.NumRegions;
end

% figure
% plot(polyout)

% while sum(numRegion == 1) > 0
%     polyInd = (1:length(newPolySize))';
%     polyComb = nchoosek(polyInd,2);
%     numRegion = zeros(size(polyComb,1),1);
%     for i = 1:size(polyComb,1)
%         if polyComb(i,1) == 1
%             poly1 = polyshape(newNodes(1:polySize(polyComb(i,1)),1),newNodes(1:polySize(polyComb(i,1)),2));
%         else
%             poly1 = polyshape(newNodes(sum(polySize(1:polyComb(i,1)-1,1))+1:sum(polySize(1:polyComb(i,1),1)),1),newNodes(sum(polySize(1:polyComb(i,1)-1,1))+1:sum(polySize(1:polyComb(i,1),1)),2));
%         end
%         
%         if polyComb(i,2) == 1
%             poly2 = polyshape(newNodes(1:polySize(polyComb(i,2)),1),newNodes(1:polySize(polyComb(i,2)),2));
%         else
%             poly2 = polyshape(newNodes(sum(polySize(1:polyComb(i,2)-1,1))+1:sum(polySize(1:polyComb(i,2),1)),1),newNodes(sum(polySize(1:polyComb(i,2)-1,1))+1:sum(polySize(1:polyComb(i,2),1)),2));
%         end
%         polyout = union(poly1,poly2);
%         numRegion(i) = polyout.NumRegions;
%         
%         if numRegion(i) == 1
%             newNodes = polyout.Vertices;
%             newPolySize =
%         end
%     end
% 
% end

end