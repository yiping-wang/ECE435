function C = CircleApproximation(LSF)

    LSFsize = size(LSF);
    area = sum(LSF < 0, 'all');
    radius = sqrt(area/pi);
    
    % Mask of area within 0 level set
    Mask = LSF < 0;
    
    % Calculate center of circle
    [Y, X] = find(Mask);
    x = round(mean(X, 'all'));
    y = round(mean(Y, 'all'));
    
    % Get window to check (avoid calculating Euclidean distance for pixels definitively outside of the range)
    x_min = floor(x - radius);
    x_max = ceil(x + radius);
    y_min = floor(y - radius);
    y_max = ceil(y + radius);
    
    
    % Create Binary Circle
    B = zeros(size(LSF));
    for j = y_min:y_max
        for i = x_min:x_max
            % Check that index is within image bounds
            if i > 0 && i < LSFsize(2) && j > 0 && j < LSFsize(1)
                % Check that index is within radius of center
                if sqrt((x-i)^2 + (y-j)^2) < radius
                    B(j,i) = 1;
                end
            end
        end
    end
    
    % Convert to LSF
    C = ConvertBitMapToLSF(B);
end