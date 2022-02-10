clear all; close all; clc;

search_nodes = [];
nRmin = - 2;
nCmin = - 2;
nRmax = + 2;
nCmax = + 2;
for j = nRmin:nRmax
    for k = nCmin:nCmax
        if (abs(j)==abs(k) && abs(j)+abs(k)==2) || (abs(j)+abs(k)==1) || (abs(j)+abs(k)==3)          
            search_nodes = [search_nodes; j,k];
        end
    end
end