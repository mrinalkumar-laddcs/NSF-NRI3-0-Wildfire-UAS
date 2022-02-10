function [confLoc,confVals] = GetConflictData(ConflictCell,dom,T)

UTM_east  = linspace(dom.xMin,dom.xMax,50)';
UTM_north = flipud(linspace(dom.yMin,dom.yMax,50)');

conflict_timevec = 0:0.5:170; % minutes
[~, conflict_time_index] = min(abs(conflict_timevec - T));

kappa_vec = ConflictCell{conflict_time_index};
conf_indices = find(kappa_vec > 0);
[conf_rows, conf_cols] = ind2sub([sqrt(length(kappa_vec)) sqrt(length(kappa_vec))], conf_indices);

confVals = zeros(length(conf_rows),1);
for i = 1:length(conf_rows)
    confVals(i) = kappa_vec(conf_indices(i));
end

confLoc = zeros(length(conf_rows),2);
confLoc(:,1) = UTM_east(conf_cols,1); 
confLoc(:,2) = UTM_north(conf_rows,1); 
end