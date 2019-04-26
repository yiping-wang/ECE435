function [averageJI, FNR, precision, recall] = evaluate(ImSegs, ImGTs, JIthreshold)
totalCells = numel(ImGTs);
[H, W] = size(ImGTs{1});

averageJI = 0;
TP = 0;
FP = 0;
FN = 0;

% 1 - FNR = TPR

% Zero-padding images
% Some segmented image have shape 2 * 2 and cause the problem in JaccardIndex
% function, which assume the input images have the same shape.
% So if we encounter such image, zero-padding to the Ground Truth size
for i = 1:numel(ImSegs)
    [H1, W1] = size(ImSegs{i});
    if H1 ~= H && W1 ~= W
        ImSegs{i} = padarray(ImSegs{i}, [(H-H1)/2, (W-W1)/2]);
    end
end

for i = 1:numel(ImGTs)
    maxOverlap = 0;
    segIndex = 1;
    % Find the maximum overlapping segmented result
    for j = 1:numel(ImSegs)
        overlap = sum(ImGTs{i} & ImSegs{j}, 'all');
        if overlap > maxOverlap
            maxOverlap = overlap;
            segIndex = j;
        end
    end
    % If the GT image has no overlap with any of the segmented results
    % this should be a False Positive
    % Since we predict there is a cell, but ground truth says no
    if maxOverlap == 0
        FP = FP + 1;
        continue;
    end
    
    % Debug Code
    %figure, subplot(1,2,1), imshow(ImSegs{segIndex});
    %subplot(1,2,2), imshow(ImGTs{i});
    
    fillHoles = imfill(ImSegs{segIndex}, 'holes');
    JI = JaccardIndex(ImGTs{i}, fillHoles);
    % If JI is below a threshold, we count that result as False Negative
    if JI < JIthreshold
        FN = FN + 1;
        continue;
    end
    averageJI = averageJI + JI;
    % We detect one and its JI is greater than threshold, so True Positive increments
    TP = TP + 1;
end

if totalCells > FN
    averageJI = averageJI/(totalCells - FN);
else
    averageJI = 0;
end

FNR = FN / (totalCells);
precision = (TP/(TP + FP));
if isnan(precision)
    precision = 0;
end
recall = (TP/(TP + FN));
if isnan(recall)
    recall = 0;
end


