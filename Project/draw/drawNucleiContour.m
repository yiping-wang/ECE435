function drawNucleiContour(originalIm, segIm)
imshow(originalIm);
hold on;
visboundaries(segIm,'Color','g', 'LineWidth', 0.1);
end

