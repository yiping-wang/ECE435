function [ index ] = JaccardIndex(genImg, gtImg)
% Measuring Region Similarity
% Union
union = sum(sum(genImg | gtImg));
% Intersecion
intersection = sum(sum(genImg & gtImg));
% Jaccard Index
index = intersection / union;
end