function [change_flag,new_window] = updateStartFinalPointLocation(newObs,domain,window)
global transform

if transform == 1
    bndBox = [domain.xmin domain.ymin domain.xmax domain.ymax];
    window.startPoint = window.startPoint - [domain.longmin domain.latmin];
    window.finalPoint = window.finalPoint - [domain.longmin domain.latmin];
else
    bndBox = [domain.longmin domain.latmin domain.longmax domain.latmax];
end

delta_clearance = 1;
new_window = window;
change_flag = 0;

for i = 1:size(newObs,2)
    inflated_poly = polybuffer(polyshape(newObs(i).polygon(:,1),newObs(i).polygon(:,2)), window.clearance + delta_clearance, 'JointType','square');
%     inflated_poly.Vertices = newObs(i).polygon;
    [start_change_flag, newStartPt] = projectPoint(window.startPoint, inflated_poly.Vertices);
    if start_change_flag == 1
        change_flag = 1;
        new_window.startPoint = newStartPt;
    end
    [final_change_flag, newFinalPt] = projectPoint(window.finalPoint, inflated_poly.Vertices);
    if final_change_flag == 1
        change_flag = 1;
        new_window.finalPoint = newFinalPt;
    end
end
% figure
% plot(inflated_poly);
% hold on;
% plot(polyshape(newObs(3).polygon(:,1),newObs(3).polygon(:,2)));
% plot(window.finalPoint(1),window.finalPoint(2),'o');
% plot(new_window.finalPoint(1),new_window.finalPoint(2),'*');
% daspect([1 1 1]);
if transform == 1
    new_window.startPoint = new_window.startPoint + [domain.longmin domain.latmin];
    new_window.finalPoint = new_window.finalPoint + [domain.longmin domain.latmin];
end
end

function d = minDistToLine(pt, v1, v2)
      a = v1 - v2;
      b = pt - v2;
      d = zeros(size(a,1),1);
      for i = 1:size(a,1)
        d(i) = abs(a(i,1)*b(i,2)-a(i,2)*b(i,1)) / norm(a(i,:));
      end
end

function d = onTheLine(pt, v1, v2)
      a = v1 - v2;
      b = pt - v2;
      d = zeros(size(a,1),1);
      for i = 1:size(a,1)
        d(i) = dot(a(i,:),b(i,:)) / (norm(a(i,:)) * norm(b(i,:)));
      end
end

function [change_flag, newPt] = projectPoint(point, vertices)
change_flag = 0;
point_in_flag = inpolygon(point(1,1), point(1,2), vertices(:,1), vertices(:,2));
if point_in_flag == 1
    change_flag = 1;
    shiftedVertices = circshift(vertices,1,1);
    d = minDistToLine(point, vertices, shiftedVertices);
    online_flag = onTheLine(point, vertices, shiftedVertices)>0 & onTheLine(point, shiftedVertices, vertices)>0;
    min_value = Inf;
    for j = 1:size(d,1)
        if ~isnan(d(j)) && d(j) < min_value && online_flag(j) == true
            min_value = d(j);
            min_ind = j;
        end
    end
    v1 = vertices(min_ind,:);
    v2 = shiftedVertices(min_ind,:);
    coeff = polyfit([v1(1), v2(1)], [v1(2), v2(2)], 1);
    m = coeff(1);
    c = coeff(2);
    m2 = -1/m;
    c2 = point(2) - m2*point(1);
    A = [-m, 1; -m2, 1];
    B = [c; c2];
    X = linsolve(A,B);
    newPt(1,1) = X(1);
    newPt(1,2) = X(2);
    
%     figure
%     plot(polyshape(vertices(:,1), vertices(:,2)));
%     hold on;
%     plot(point(1),point(2),'o');
%     plot(newPt(1),newPt(2),'*');
%     daspect([1 1 1]);
%     box on;
else
    newPt = point;
end
end