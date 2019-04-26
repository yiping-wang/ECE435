function [ singleNuclei, allNuclei] = nucleiSegmentation(im, showBoundaries, showInput)
if nargin < 2
    % Display green boundaries contour on the segmented nuclei
    showBoundaries = 0;
end

if nargin < 3
    % Display green boundaries contour on the segmented nuclei
    showBoundaries = 0;
    % Display input image for comparsion
    showInput = 0;
end

% MSER refinement
[regions, mserCC] = detectMSERFeatures(im, 'RegionAreaRange', [100,600]);
% Region properties analysis
stats = regionprops('table',mserCC,'Eccentricity', 'Centroid', 'MajorAxisLength','MinorAxisLength');
% Filter out the objects which is not very circle, i.e., keep the most
% circular object
eccentricityIdx = stats.Eccentricity < 0.85;
circularRegions = regions(eccentricityIdx);
% Nuclei Canadiates initialization
rawNucleiCandidate = zeros(size(im));
% Obtain the centers from the regionprops
centers = stats.Centroid;
% Obtain the diameters from the regionprops
diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
radii = diameters/2;
% MSER refinement and obtain the unique centers
[refinedCenters, refinedRadii] = computeCenters(centers, radii);

% Assign the binary value to rawNucleiCandidate
% from the pixel list of the circular regions
for i = 1:length(circularRegions)  
    pixelsInRegion = circularRegions(i,1).PixelList;
    for j = 1:size(circularRegions(i,1).PixelList,1)
        x = pixelsInRegion(j,1);
        y = pixelsInRegion(j,2);
        rawNucleiCandidate(y,x) = 1;
    end
end

% All nuclei in binary image
% It is raw since we do not apply any noise reduction
rawNucleiCandidateLogical = logical(rawNucleiCandidate);
% figure, imshow(rawNucleiCandidate);
% Display input image along with nuclei segmentation
% Visualization
if showInput && showBoundaries
    subplot(1,2,1);
    imshow(im);
    hold on;
    title('Real Image');
    visboundaries(rawNucleiCandidateLogical, 'LineWidth', 0.1, 'Color','r');
    subplot(1,2,2);
    imshow(rawNucleiCandidate); hold on;
    title('Nuclei Segmentation');
    visboundaries(rawNucleiCandidateLogical,'Color','g', 'LineWidth', 0.1);
% Display input image only
elseif showInput
    imshow(im);
    hold on;
    % viscircles(refinedCenters,refinedRadii, 'LineWidth', 0.1, 'Color','r');
% Display boundaries on binary nuclei
elseif showBoundaries
    imshow(rawNucleiCandidate); hold on;
    visboundaries(rawNucleiCandidateLogical,'Color','g', 'LineWidth', 0.1);
end

% Extract single nuclei
singleNuclei = extractSingleNuclei(rawNucleiCandidateLogical, refinedCenters, refinedRadii);
allNuclei = rawNucleiCandidateLogical;
end

