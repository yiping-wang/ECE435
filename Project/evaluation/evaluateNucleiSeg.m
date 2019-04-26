function [JI, DC] = evaluateNucleiSeg(Im, ImGT, display)
[~, all] = nucleiSegmentation(Im);
ImGT = imbinarize(ImGT, 0);
ImGT = imfill(ImGT, 'holes');

JI = JaccardIndex(all, ImGT);
DC = (2 * JI) / (1 + JI);

if display
    subplot(1, 2, 1);
    imshow(all);
    title('Nuclei Segmentation');
    subplot(1, 2, 2);
    imshow(ImGT);
    title('Ground Truth');
end

end

