function [ singleNuclei ] = extractSingleNuclei(binaryImg, centers, radii, showAnimation)
if nargin < 4
    showAnimation = 0;
end
[row, col] = size(binaryImg);
% Hyparameter
multiplier = 10;
minPixelThreshold = 10;

singleNuclei = {};

maxNuclei = length(centers);
numNuclei = 0;
for i = 1:maxNuclei
    centerX = centers(i, 1);
    centerY = centers(i, 2);
    radius = radii(i) * multiplier;
    % Sometimes the returned result from centers can be zero - which is
    % false negative then we will ignore it
    if centerX ~= 0 && centerY ~= 0
        mask = zeros(row, col); 
        [x, y] = meshgrid(1:col, 1:row);
        % Use a binary mask to form each nuclei based on center and radius
        mask((x - centerX).^2 + (y - centerY).^2 <= radius.^2) = true;
        maskedImage = times(binaryImg, mask);
        % Noise reduction. if the number of pixel is below a threshold
        % count it as noise or other debris since it is too low to be a
        % nuclei
        if sum(maskedImage, 'all') > minPixelThreshold
            numNuclei = numNuclei + 1;
            singleNuclei{numNuclei, 1} = logical(maskedImage);
            if showAnimation
                imshow(maskedImage);
                tic;pause(0.5);toc;
            end
        end
    end
end

