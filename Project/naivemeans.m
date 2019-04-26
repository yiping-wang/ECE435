% Naive implementation of a meanshift algorithm.  Recommend values are:
% r = 4
% v = 4
% iter = 50
%
% M is a greyscale image matrix of uint8.
% r is a radius. Pixels within r will be used to compute mean.
% v is a value difference. Only pixels with a value within v will be used
% to compute the mean.
% iter is number of iterations.
function O = naivemeans(M, r, v, iter)

    for i = 1:iter
        % O is output of each iteration.  Initialize to 0.
        O = zeros(size(M));
        
        % Pad the array
        M = padarray(M,[r r],0,'replicate');

        % Iterate over all pixels in padded image
        for x = 1 + r : size(M, 1) - r
            for y = 1 + r : size(M, 2) - r
        
                % n is number of pixels used to compute mean, sum is running
                % total
                n = 0;
                sum = 0;
            
                % For Pixel (x,y), find mean
                for xi = x - r : x + r
                    for yi = y - r : y + r
                        if sqrt((x - xi)^2 + (y - yi)^2) <= r && abs(M(x,y) - M(xi,yi)) <= v
                            n = n + 1;
                            sum = sum + double(M(xi,yi));
                        end
                    end
                end
            
                O(x - r, y - r) = sum/n;
        
            end
        end
        
        M = O; % Set M equal to output of previous iteration
        
    end
    
    O = uint8(O);

end