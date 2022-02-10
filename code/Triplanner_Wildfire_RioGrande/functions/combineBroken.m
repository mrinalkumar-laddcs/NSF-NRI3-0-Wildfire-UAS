function obs = combineBroken(conv_obs,broken_poly)
if broken_poly == 1
    % Manually Extract Convx Polygon Data and Combine
    obs(1).polygon = [conv_obs(1).polygon; conv_obs(2).polygon; conv_obs(3).polygon];
    k = boundary(obs(1).polygon);
    obs(1).polygon = obs(1).polygon(k(1:end-1),:);
    obs(2).polygon = conv_obs(4).polygon;
    obs(3).polygon = [conv_obs(5).polygon; conv_obs(6).polygon; conv_obs(7).polygon];
    k = boundary(obs(3).polygon);
    obs(3).polygon = obs(3).polygon(k(1:end-1),:);
    for i = 1:size(obs,2)
        obs(i).polySize = size(obs(i).polygon,1);
    end
else
    obs = conv_obs;
end
end