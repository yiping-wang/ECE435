function R = RestoreLSFShape(LSF)
    InnerPixels = (LSF < 0);
    OutterPixels = (LSF > 0);
    InnerLSF = bwdist(OutterPixels);
    OutterLSF = bwdist(InnerPixels);
    R = OutterLSF - InnerLSF;
end