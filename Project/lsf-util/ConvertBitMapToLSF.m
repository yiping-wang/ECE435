function LSF = ConvertBitMapToLSF(BM)
    InnerPixels = BM;
    OutterPixels = ~BM;
    InnerLSF = bwdist(OutterPixels);
    OutterLSF = bwdist(InnerPixels);
    LSF = OutterLSF - InnerLSF;
end