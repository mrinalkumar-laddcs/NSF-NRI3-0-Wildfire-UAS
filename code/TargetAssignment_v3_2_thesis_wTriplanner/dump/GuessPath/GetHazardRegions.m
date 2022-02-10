function HazardCell =  GetHazardRegions(env,T)
	timevec = 30:10:120;

	[~, time_index] = min(abs(timevec - T));
	
	% Demonstrate that you can get "heat islands" at this timestep
    [rows, cols] = size(env.heatflux.hfmean);
	IslandMat = zeros(rows, cols);

	hot_indices = find(env.heatflux.hfmean >= env.heatflux.thresh); 

	IslandMat(hot_indices) = 1;
    UTM_east  = linspace(env.dom.xMin,env.dom.xMax,50);
    UTM_north = linspace(env.dom.yMin,env.dom.yMax,50);
	M = contourc(UTM_east, UTM_north, IslandMat, [1 1]);

	% There are 2 levels here: 0 and 1. You need to get the contours that are 1
	num_thresh = 10; % The number of points that we require to make a contour

	% The first column lists the time and then the number of points
	first_row = M(1,:);
	second_row = M(2,:);

	% Now find every index that has the time level as an entry
	contour_indices = find(first_row == 1);
	contour_points = second_row(contour_indices);
	satisfy_indices = find(contour_points >= num_thresh);
    
	% Only retain contours above a certain size
	contour_indices = contour_indices(satisfy_indices);
% 	fprintf('The number of estimated contours is: %g\n',length(contour_indices));

	HazardCell = cell(length(contour_indices),1);
	for i = 1:length(contour_indices)
		contour_index = contour_indices(i);

		num_points = M(2,contour_index);
				
		easting_segment = M(1,(contour_index+1):(contour_index+num_points-1))';
		northing_segment = M(2,(contour_index+1):(contour_index+num_points-1))';

		HazardCell{i,1} = easting_segment;
		HazardCell{i,2} = northing_segment;
		HazardCell{i,3} = polyshape(easting_segment, northing_segment);
				
	end



end
