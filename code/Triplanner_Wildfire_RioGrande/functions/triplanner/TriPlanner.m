function [status,path,tri_funnel] = TriPlanner(triplannerFunc,inputMap,domain,startPoint,finalPoint,clearance)
% Call the C++ executable

% global transform
% 
% if transform == 1
%     bndBox = [domain.xmin domain.ymin domain.xmax domain.ymax];
%     startPoint = startPoint - [domain.longmin domain.latmin];
%     finalPoint = finalPoint - [domain.longmin domain.latmin];
% else
%     bndBox = [domain.longmin domain.latmin domain.longmax domain.latmax];
% end

status = 1;
tic
[status, cmdout] = system([triplannerFunc,' "',inputMap,'" ',num2str(startPoint(1,1)),' ',num2str(startPoint(1,2)),' ',num2str(finalPoint(1,1)),' ',num2str(finalPoint(1,2)),' ',num2str(clearance)]  ,'-echo');
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract Triangulation Edges and Path
if status ~=1
    % Extract the edges
    edges = str2num(cmdout(1,find(cmdout=='{')+2:find(cmdout=='}')-2));
    
    % Extract the path
    polyline = str2num(cmdout(1,find(cmdout=='['):find(cmdout==']')));
    path = [polyline(1,1:2:end)' polyline(1,2:2:end)'];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract the obstacle map file
fileID = fopen(inputMap,'r');
i = 1;
while ~feof(fileID)
    line = fgetl(fileID);
    
    if contains(line,'polygon','IgnoreCase',true)
        polygon_coords = str2num(extractAfter(line,'polygon'));
        obs(i).polygon = [polygon_coords(1,1:2:end)' polygon_coords(1,2:2:end)'];
        i = i+1;
    else if contains(line,'domain','IgnoreCase',true)
            bndBox = str2num(extractAfter(line,'domain'));
        end
    end
end
fclose(fileID);

tol = 1e-3;
tri_mesh = edge2tri(edges,bndBox,tol);
tri_funnel = funnel(tri_mesh,path);
run PathPlanner_Plot.m
end