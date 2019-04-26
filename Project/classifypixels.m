% Classifier for segmenting image
%
% M is a greyscale image matrix of uint8.
% C is a bitmask of same dimensions as M. Values of 1 correspond to pixels
% in M which are believed to be part of cell clumps.
% B is a bitmask of same dimensions as M. Values of 1 correspond to pixels
% in M which are believed to be part of the background.
%
% 
%
function O = classifypixels(M, C)
    assert(size(M, 1) == size(C, 1), 'M and C must be of equal size');
    assert(size(M, 2) == size(C, 2), 'M and C must be of equal size');
    %assert(size(M) == size(B), "M and B must be of equal size");
    
    Msize = size(M, 1)*size(M, 2);

    % Reshape image and bitmasks into 1D vectors
    MV = double(reshape(M, Msize, 1)); % convert to double too; SVM expects floating point input
    CV = reshape(C, Msize, 1);
    %BV = reshape(B, Msize);
    
    % Create/Train Model
    model = fitglm(MV, CV); % Linear Regression
    
    % Make Prediction
    YPred = predict(model,MV);
    
    O = zeros(size(YPred));
    for x = 1:size(YPred)
        if YPred(x) > 0.4 % 0.5 decision point for linear regression, use this number to weight the classification.
            O(x) = 1;
        end
    end
    
    % Reshape back into an image.  Hopefully this this reshapes it using
    % the reverse process that was used to turn M into a vector, but it
    % might not.
    O = reshape(O, size(M));
end