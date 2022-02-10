function [DroneFluxMean, DroneFluxVar] =  DroneFluxStats(DroneFluxCube)


	[rows, cols, times, ~] = size(DroneFluxCube);

	DroneFluxMean = zeros(rows, cols, times);
		DroneFluxVar = zeros(rows, cols, times);

		for i = 1:rows
			for j = 1:cols
				for k = 1:times
					DroneFluxMean(i,j,k) = mean(DroneFluxCube(i, j, k, :));

					if (DroneFluxMean(i,j,k) < 0)
						DroneFluxMean(i,j,k) = eps; % Just give it some residual, positive heating.
					end

					DroneFluxVar(i,j,k) = var(DroneFluxCube(i, j, k, :));
				end
			end 
		end

	end