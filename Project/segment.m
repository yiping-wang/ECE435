% --Options--

% If EVALUATE_SINGLE_IMAGE is set to true, the program will evaluate a
% single image from the isbi_test90 dataset. IMG_NO specifies the image
% number.  If EVALUATE_SINGLE_IMAGE is set to false, the program will
% evaluate all images in the isbi_test90 dataset.
EVALUATE_SINGLE_IMAGE = false;
IMG_NO = 1;

% If DRAW_SEGMENTATION is set to true, the final segmentation will be
% diplayed in a figure.
DRAW_SEGMENTATION = true;


% --Import Functions--
addpath('./draw/');
addpath('./nuclei-segmentation/');
addpath('./evaluation/');
addpath('./lsf-util/');

% --Constants--
MIN_CLUMP_SIZE = 100; % Cell clumps with fewer than this number of pixels are ignored
LSF_EVO_ITER = 150; % The number of Level Set Evolutions to perform per level set
SIGMA = 1.5; % Sigma value used in Gaussian filter step when creating the edge weight term G

% --Begin Tracking Execution Time--
startTime = cputime;

% --Load Image (from .PNG file)--
%path = 'dataset/real/EDF0_7/EDF002';
%Im = imread(path, 'png');

% --Load Image (from .mat file)--
Dataset = load('dataset/synth/isbi_test90.mat');
ISBIImages = Dataset.ISBI_Test90;

% --Load Ground Truth (from .mat file)--
GroundTruth = load('dataset/synth/isbi_test90_GT');
CytoplasmGT = GroundTruth.test_Cytoplasm;

% --Initialize Values for Evaluation Statistics--
NumZeroJI = 0;
JISum = 0;
FNRSum = 0;
PrecisionSum = 0;
RecallSum = 0;
if EVALUATE_SINGLE_IMAGE
    NumImages = 1;
else
    NumImages = size(ISBIImages, 1);
end

% --Iterate over all images in dataset, and aggregate the quantitative
% evlauation metrics--
for image_i = 1:NumImages
    
    % --Process one image if specified--
    if EVALUATE_SINGLE_IMAGE
        Im = ISBIImages{IMG_NO};
        ImGT = CytoplasmGT{IMG_NO};
    else
        % --Get image and associated ground truth--
        Im = ISBIImages{image_i};
        ImGT = CytoplasmGT{image_i};
    end
   

    % --Trim the Gray Boarder--
    % Synthetic images have a gray border that creates false edges. The are
    % removed.
    [H, W] = size(Im);
    Im(H, :) = [];
    Im(1, :) = [];
    Im(:, W) = [];
    Im(:, 1) = [];
    
    % --Save size values that are frequently used--
    ImSize = size(Im);
    ImNumPixels = numel(Im);
    
    % --Get Super-pixel map using Mean Shift (naivemeans)--
    r = 4; % Maximum distance between pixels considered
    v = 4; % Maximum intensity difference between pixels considered
    iter = 50; % Number of iterations of filtering iterations to perform
    S = naivemeans(Im, r, v, iter); % S = Superpixel map

    % --Get Edge Map--
    E = edge(S, 'Canny');  
    
    % --Loosly Segment Cell Clumps Using Convex Hulls--
    H = bwconvhull(E, 'objects'); % First iteration misses a lot of the internal parts of cells.
    CellClumpMask = bwconvhull(H, 'objects'); % Doing a second iteration produces much better hulls. This might backfire on images with lots of connected cells.
    
    % --Classify Pixels as Cell Clumps or Background--
    % The CellClumpMask provides the initial assignment for training the
    % classifier. C is the output of the classifier's predictions.
    C = classifypixels(Im, CellClumpMask);
    
    % --New Nuclei Segmentation--
    % nucleiSegmentation returns a cell array of bitmasks, each representing one nucleus
    [NucleiMasks, AllNucleiMask] = nucleiSegmentation(Im);
    
    % --Calculate edge weight term G--
    % G is used by evolveLSF(). G has values between 0-1.  1 is non-edge,
    % stronger edges are closer to 0
    GaussIm = double(imgaussfilt(Im, SIGMA));
    [Ix,Iy]=gradient(GaussIm);
    G = 1./(1 + Ix.^2+Iy.^2);
    
    % --Separate cell clumps mask--
    % into separate masks, each containing one connected region (1 cell clump)
    ClumpsStruct = bwconncomp(C);
    ClumpsPxlIndex = ClumpsStruct.PixelIdxList; % Cell Array, with each cell containing lists of pixels belonging to the same clump
    NumClumps = ClumpsStruct.NumObjects; % Number of clumps
    
    % --Filter out small cell clumps--
    % Small cell clumps are usually misclassifications.  Cell clumps
    % smaller than MIN_CLUMP_SIZE are discarded
    ClumpSizes = zeros(NumClumps, 1); 
    for i = 1:NumClumps
        ClumpSizes(i) = size(ClumpsPxlIndex{i}, 1);
    end
    LargeClumps = ClumpSizes > MIN_CLUMP_SIZE;
    ClumpsPxlIndex = ClumpsPxlIndex(LargeClumps); % Cell Array, containing lists of pixels belonging to the same clump.
    
    % --Build Container for Final Segmentations--
    CellSegmentations = cell(numel(NucleiMasks), 1);
    CellSegIndex = 1;
    
    % --Main Loop--
    % For each cell clump, identify all nuclei overlapping it, perform LSF
    % evolution for those nuclei, and save the final segmentations.
    for i = 1:numel(ClumpsPxlIndex)
        
        % --Construct 2D Clump Mask From Clump Pixel List--
        SingleClumpMask = false(ImNumPixels,1);
        SingleClumpMask(ClumpsPxlIndex{i}) = true;
        SingleClumpMask = reshape(SingleClumpMask, ImSize);
    
        % --Determine Overlapping Nuclei--
        OverlappingNuclei = cell(1); % Container for bitmasks of overlapping nuclei
        NumOverlapping = 0; % The number of nuclei that overlap. Used in initializing OverlappingNuclei and to control some loops.
        for j = 1:numel(NucleiMasks)
            Overlap = SingleClumpMask & NucleiMasks{j}; % Overlap is a binary image, the intersect of the Cell Clump Mask and the Nuclei Mask.
            if sum(Overlap, 'all') > 0 % If there is any overlap...
                NumOverlapping = NumOverlapping + 1;
                OverlappingNuclei{NumOverlapping} = NucleiMasks{j}; % Save this nucleus, it will be used to initialize an LSF inside this cell clump.
                NucleiMasks{j} = false(ImSize); % Cross this nucleus off the list so it isn't used in multiple segmentations.  This should never occur, but why take chances?
            end
        end
        
        % --Skip If Cell Clump Empty--
        % If there are no overlapping nuclei, this cell clump is a dud,
        % move on to the next one.
        if NumOverlapping == 0
           continue 
        end
    
        % --Convert the Nuclei Bitmasks to Level Set Functions--
        % A LSF represents one cell.
        LevelSets = OverlappingNuclei;
        for j = 1:NumOverlapping
            LevelSets{j} = ConvertBitMapToLSF(LevelSets{j});
        end
    
        % --Iteratively Perform Level Set Evolution--
        % The LSF growth should stabalize by the end of this loop.
        for j = 1:LSF_EVO_ITER
    
            % --Evolve Each LSF Once--
            % Evolve 1 nucleus while holding the others constant. k is the
            % index of the LSF of interest.
            for k = 1:NumOverlapping
    
                % --Create Bitmask of Other LSFs--
                % OtherCellsMask represents the area occupied by all other
                % LSFs in this cell clump.  Growth of LevelSets{k} will be
                % resisted in these regions.
                OtherCellsMask = false(ImSize);
                for m = 1:NumOverlapping
                    if k ~= m
                        OtherCellsMask = LevelSets{m} < 0 | OtherCellsMask; % Convert LevelSets m to a bitmask and join it with the others
                    end
                end
    
                % --Perform Level Set Evolution--
                LevelSets{k} = EvolveLSF(LevelSets{k}, OtherCellsMask, SingleClumpMask, G, Im);
            end
        end % Done evolving the LSFs.
    
        % --Save Final Level Set Functions--
        % The final segmentations are stored as binary images.
        for j = 1:numel(LevelSets)
            LevelSet = LevelSets{j} < 0; % Select region within the contour
            LevelSet = padarray(LevelSet, [1, 1]); % Replace the border pixel we removed from the original image so that image dimensions match.
            CellSegmentations{CellSegIndex} = logical(LevelSet); % Save the segmentation
            CellSegIndex = CellSegIndex + 1;
        end
    
    end % Done segmenting all cells in this cell clump.
    
    % --Display Results of Segmentation--
    if DRAW_SEGMENTATION
        Im = padarray(Im, [1, 1]); % Replace the border pixel we removed at the beginning.
        figure(image_i);
        result = drawCytoplasmContour(Im, CellSegmentations); % Draw cell segmentation borders.
        drawNucleiContour(result, AllNucleiMask); % Draw nuclei.
        drawnow;
    end
    
    % --Compute Evaluation Statistics--
    Im = padarray(Im, [1, 1]);
    [avgJI, FNR, precision, recall] = evaluate(CellSegmentations, ImGT, 0.5); % Use Thresholds 0.5, 0.6, 0.7, 0.8 as the paper did
    if avgJI == 0
        NumZeroJI = NumZeroJI + 1;
    end
    JISum = JISum + avgJI;
    FNRSum = FNRSum + FNR;
    PrecisionSum = PrecisionSum + precision;
    RecallSum = RecallSum + recall;
    
    disp(strcat('Completed Image:', num2str(image_i), '/', num2str(NumImages)));
    disp(avgJI)
end

FinalJI = JISum/(NumImages - NumZeroJI);
if isnan(FinalJI)
    FinalJI = 0;
end
FinalFNR = FNRSum/NumImages;
FinalPrecision = PrecisionSum/NumImages;
FinalRecall = RecallSum/NumImages;
FinalDC = 2 * FinalJI / (1 + FinalJI);

disp(strcat('Average Jaccard Index over all images:', ' ', num2str(FinalJI)));
disp(strcat('Average FN Rate over all images:', ' ', num2str(FinalFNR)));
disp(strcat('Average Precision over all images:', ' ', num2str(FinalPrecision)));
disp(strcat('Average Recall over all images:', ' ', num2str(FinalRecall)));
disp(strcat('Average Dice Coefficient over all images:', ' ', num2str(FinalDC)));