function [h_1, h_2] = GetTaosRadiationFigures(fig_num_vec, dom, DroneFluxMean, DroneFluxVar, global_time)
    
    UTM_east  = linspace(dom.xMin,dom.xMax,50);
    UTM_north = linspace(dom.yMin,dom.yMax,50);

	timevec = 30:10:120;

	[~, time_index] = min(abs(timevec - global_time));
	
	h_1 = figure(fig_num_vec(1));
	clf(h_1);
	hold on;
	grid on;
	box on;
	xlabel('UTM Easting [m]');
	ylabel('UTM Northing [m]');
	axis([min(UTM_east) max(UTM_east) min(UTM_north) max(UTM_north)]);

	colormap(flipud(autumn));

	[EAST, NORTH] = meshgrid(UTM_east, UTM_north);
	p2 = pcolor(EAST, NORTH, DroneFluxMean(:,:,time_index)');
	set(p2, 'EdgeColor','none');
	colorbar;
	hbar_2 = colorbar;
	ylabel(hbar_2, 'Mean Heat Flux [kWm^{-2}]','FontWeight','bold');
	title(['Mean Heat Flux at Time: ',num2str(global_time), ' min.']);

	set(gca,'FontWeight','bold')

	hold off


	h_2 = figure(fig_num_vec(2));
	clf(h_2);
	hold on;
	grid on;
	box on;
	xlabel('UTM Easting [m]');
	ylabel('UTM Northing [m]');
	axis([min(UTM_east) max(UTM_east) min(UTM_north) max(UTM_north)]);

	colormap(flipud(cool));

	[EAST, NORTH] = meshgrid(UTM_east, UTM_north);
	p2 = pcolor(EAST, NORTH, DroneFluxVar(:,:,time_index)');
	set(p2, 'EdgeColor','none');
	colorbar;
	hbar_2 = colorbar;
	ylabel(hbar_2, 'Variance in Heat Flux [kWm^{-2}]^2','FontWeight','bold');
	title(['Variance of Heat Flux at Time: ',num2str(global_time), ' min.']);

	set(gca,'FontWeight','bold')

	hold off


end