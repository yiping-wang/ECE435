function [average] = averageJaccardIndex(ImSegs, ImGTs)
result = 0;
gtColor = [255,215,0]; % yellow
segColor = [0,255,0]; % green
interColor = [255,0,0]; % red

[H, W] = size(ImGTs{1});

for i = 1:numel(ImGTs)
    maxOverlap = -Inf;
    displaySegIndex = 1;
    for j = 1:numel(ImSegs)
        [H1, W1] = size(ImSegs{j});
        if H1 ~= H || W1 ~= W
            continue
        end
        % Since the ground truth and the segmentation result is different
        % we check the max overlapping region as the corresponding results
        overlap = sum(ImGTs{i} & ImSegs{j}, 'all');
        if overlap > maxOverlap
            maxOverlap = overlap;
            displaySegIndex = j;
        end
    end
    fillHoles = imfill(ImSegs{displaySegIndex}, 'holes');
    % accumulate the JI
    result = result + JaccardIndex(ImGTs{i}, fillHoles);
    subplot(1, 3, 1);
    imshow(ImGTs{i});
    title('Ground Truth');
    subplot(1, 3, 2);
    imshow(fillHoles);
    title('Our Segmentation');
    visJaccard = imoverlay(ImGTs{i}, ImGTs{i}, gtColor/norm(gtColor));
    visJaccard = imoverlay(visJaccard, fillHoles, segColor/norm(segColor));
    visJaccard = imoverlay(visJaccard, fillHoles & ImGTs{i}, interColor/norm(interColor));
    subplot(1, 3, 3);
    imshow(visJaccard);
    title('Visualize Jaccard Index');
    pause(1);
end
disp('Avarge Jaccard Index');
average = result/numel(ImGTs);
disp(average);