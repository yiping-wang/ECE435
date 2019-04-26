function [result] = drawCytoplasmContour(originalIm, segIms)
colors = [128,0,0;128,0,128;255,255,0;255,20,147;30,144,255;255,105,180;210,105,30;255,165,0;0,255,255];
numColors = length(colors);
[H, W] = size(originalIm);

for i = 1:numel(segIms)
    [H1, W1] = size(segIms{i});
    % Check whether the dimension match or not
    % if not match then imoverlay would fail
    if H1 ~= H || W1 ~= W
        result = originalIm;
        continue
    end
    fillHoles = imfill(segIms{i}, 'holes');
    % Use edge detector to find the contour
    contour = edge(fillHoles, 'Canny');
    % Select a color randomly
    color = colors(randi(numColors), :);
    if i == 1
        result = imoverlay(originalIm, contour, color/norm(color));
    else
        result = imoverlay(result, contour, color/norm(color));
    end
end
end