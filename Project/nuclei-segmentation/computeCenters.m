function [centers, radii] = computeCenters(points, radius)
% Refine centers and radius

% Initialization
max_centers = length(points);
radii = zeros(max_centers, 1);
centers = zeros(max_centers, 2);
num_centers = 1;

% Go through all points and get a unique centers based on Euclidean distance
for i = 1:length(points)
    if i == 1
        centers(1, :) = points(i,:);
        radii(1) = radius(i);
    else
        flag = 1;
        p = points(i,:);
        for j = 1:num_centers
            c = centers(j,:);
            m = [c;p];
            % Compare the Euclidean distance
            % if the distance is below 20
            % then we ignore the centers and keep only one center
            if sum(abs(m(1, :) - m(2, :))) < 20
                flag = 0;
                break
            end
        end    
        if flag
            num_centers = num_centers + 1;
            centers(num_centers, :) = p;
            radii(num_centers) = radius(num_centers);
        end
    end
end

