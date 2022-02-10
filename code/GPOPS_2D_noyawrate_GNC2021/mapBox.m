function [minLat, maxLat, minLon, maxLon] = mapBox(mapIn,padLat,padLon)
% Outputs a the coordinates of the bounding box of the given data set
% in the map structure
% 
% [minLat, maxLat, minLon, maxLon] = mapBox(mapIn,padLat,padLon)
% 
% mapIn - map structure with 'Lat' and 'Lon' fields
% padLat - padding for Latitude
% padLon - padding for Longtitude


% Extract a bounding box for the given building polygons
numBldg = size(mapIn,1);
minLatBox = zeros(numBldg,1);
maxLatBox = zeros(numBldg,1);
minLonBox = zeros(numBldg,1);
maxLonBox = zeros(numBldg,1);

for i = 1:numBldg
    minLatBox(i,1) = min(mapIn(i).Lat);
    maxLatBox(i,1) = max(mapIn(i).Lat);
    minLonBox(i,1) = min(mapIn(i).Lon);
    maxLonBox(i,1) = max(mapIn(i).Lon);
end

% Pad the Bounding Box
minLat = min(minLatBox)-padLat;
maxLat = max(maxLatBox)+padLat;
minLon = min(minLonBox)-padLon;
maxLon = max(maxLonBox)+padLon;

end