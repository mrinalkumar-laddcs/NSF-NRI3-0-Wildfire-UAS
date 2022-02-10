function [confLoc,confVals] = GetConflictDataCum(ConflictCell,dom,T,deltaTmission)

UTM_east  = linspace(dom.xMin,dom.xMax,50)';
UTM_north = flipud(linspace(dom.yMin,dom.yMax,50)');

timevec = ((T-deltaTmission):0.5:T)';

conflict_timevec = 0:0.5:170; % minutes
confLoc  = [];
confVals = [];
for i = 1:size(timevec,1)
    [~, conflict_time_index] = min(abs(conflict_timevec - timevec(i,1)));
    
    kappa_vec = ConflictCell{conflict_time_index};
    conf_indices = find(kappa_vec > 0);
    [conf_rows, conf_cols] = ind2sub([sqrt(length(kappa_vec)) sqrt(length(kappa_vec))], conf_indices);
    
    confValsTemp = zeros(length(conf_rows),1);
    for i = 1:length(conf_rows)
        confValsTemp(i) = kappa_vec(conf_indices(i));
    end
    
    confLocTemp = zeros(length(conf_rows),2);
    confLocTemp(:,1) = UTM_east(conf_cols,1);
    confLocTemp(:,2) = UTM_north(conf_rows,1);
    
    confLoc  = [confLoc;  confLocTemp];
    confVals = [confVals; confValsTemp];
end
confLoc  = flipud(confLoc);
confVals = flipud(confVals);

[confLoc,ia,~] = unique(confLoc,'rows');
confVals = confVals(ia,1);
end