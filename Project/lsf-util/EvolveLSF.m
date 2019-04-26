function LSFOut = EvolveLSF(LSF, OtherCellsMask, ClumpMask, G, Img)

    % --Constants--
    LARGE_NUM = 8192; % Arbitrarily large number, used to prevent the LSF from expanding beyond the cell clump
    MIN_AREA = 3000; % Area Term adds energy when below this threshold
    MAX_AREA = 6000; % Area Term subtracts energy when above this threshold
    OVERLAP_THRESHOLD = 0.2; % When overlap is above this ratio, energy is subtracted from pixels that would extend into the overlap.
    GRAY_DIFF_THRESHOLD = 30; % When the intensity difference is above this value, energy is subtracted from pixels that would extend into the overlap.
    
    % --Term Weight Constants--
    ALPHA = 0.2; % Area Term Weight
    LAMBDA = 0; % Length Term Weight
    GAMMA = 0.6; % Shape Prior Term Weight
    ZITA = 6; % Overlapping Area Term Weight
    OMEGA = 4.1; % Overlapping Intensity Term Weight

    % --Pre-emptive calculations--
    % Calculate EdgeMask (purpose is just to get a binary mask of the pixels along the edge of the 0 Level Set)
    % This a simplification of the Dirac Delta function used by the paper.
    EdgeMask = LSF > -1.5 & LSF < 1.5;
    
    % Calculate Gradient of LSF
    [LSF_Dx, LSF_Dy] = gradient(LSF);
    LSF_Gradient = sqrt(LSF_Dx.^2 + LSF_Dy.^2);
    
    % --Unary Energy Terms--
    % Clump Boundary Term
    % Prevents LSF from expanding beyond cell clum boundary by adding an
    % arbitrarily large value LSF pixels outside the clump.
    C = ~ClumpMask*LARGE_NUM;
    
    % Area Term
    % Adds energy when the area is smaller than the minimum.
    % Removes energy when the area is larger than the maximum.
    area = sum((LSF < 0).*G, 'all'); % TODO decide if multiply this by G is a good idea. IF CHANGED, MUST UPDATE OVERLAPPING AREA TERM, ASSUMES THIS IS MULTIPLIED BY G
    if area < MIN_AREA
        A = -1*(MIN_AREA - area)*G.*EdgeMask;
    elseif area > MAX_AREA
        A = (area - MAX_AREA)*G.*EdgeMask;
    else
        A = 0;
    end
    
    % Length Term
    % Still not 100% sure what the point of this term is, but it seems to
    % be a consistent source of positive energy.
    L = G.*LSF_Gradient.*EdgeMask;
    
    % Shape Prior Term
    % Adds energy to those pixels that would create a more circular shape.
    Circ = CircleApproximation(LSF);
    P  = G.*Circ.*EdgeMask;
    
    % --Binary Energy Terms--
    OverlapMask = (LSF < 0) & OtherCellsMask;
    
    % Overlapping Area Term
    % Subtracts energy from overlapping pixels if the overlap gets too big.
    areaOfOverlap = sum(OverlapMask.*G, 'all');
    areaRatio = areaOfOverlap/area;
    if areaRatio > OVERLAP_THRESHOLD
        OA = areaRatio*(G.*(EdgeMask & OtherCellsMask));
    else
        OA = 0;
    end
    
    % Overlapping Gray Level Intensity Term
    % Subtracts energy from overlapping pixels if the intensity difference
    % is too high.
    % NOTE: Expects image intensity represented as uint8.
    AvgGrayInCell = sum(Img.*uint8(LSF < 0), 'all')/max(sum(LSF < 0, 'all'), 1); % max prevents division by 0
    AvgGrayInOverlap = sum(Img.*uint8(OverlapMask), 'all')/max(sum(OverlapMask, 'all'), 1); % max prevents division by 0
    GrayDiff = AvgGrayInCell - AvgGrayInOverlap;
    if GrayDiff > GRAY_DIFF_THRESHOLD
        OI = GrayDiff*(G.*(EdgeMask & OtherCellsMask));
    else
        OI = 0;
    end
    
    % Sum up terms
    LSFOut = LSF + C + A*ALPHA + L*LAMBDA + P*GAMMA + OA*ZITA + OI*OMEGA;
    
    % Regularize the LSF
    LSFOut = RestoreLSFShape(LSFOut);
    
end