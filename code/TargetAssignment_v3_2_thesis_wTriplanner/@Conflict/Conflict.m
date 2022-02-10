classdef Conflict < handle
    properties
        Loc
        Val
    end
    
    methods
        function obj = Conflict(loc,val)
            if nargin~=0
                if size(loc,1) == size(val,1)
                    if size(loc,2)
                        for i = 1:size(loc,1)
                            obj(i,1).Loc    = loc(i,:);
                            obj(i,1).Val    = val(i,1);
                        end
                    end
                end
            end
        end
    end
end