function hf = GetHeatFluxData(DroneFluxMean,DroneFluxVar,dom,T)
timevec = 30:10:120;
[~, time_index] = min(abs(timevec - T));

UTM_east  = linspace(dom.xMin,dom.xMax,50);
UTM_north = linspace(dom.yMin,dom.yMax,50);
[EAST, NORTH] = meshgrid(UTM_east, UTM_north);

hf.X = EAST;
hf.Y = NORTH;
hf.hfmean = flipud(DroneFluxMean(:,:,time_index)');
hf.hfvar  = flipud(DroneFluxVar(:,:,time_index)');
end