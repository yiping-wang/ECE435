function basic_global_thresholding(img, tolerance, display_hist, hist_eq)
if nargin < 3
    display_hist = false;
    hist_eq = false;
end

if nargin < 4
    hist_eq = false;
end

if hist_eq
    input_img = histeq(img);
    img = histeq(img);
else
    input_img = img;
end

% Randomly select an initial estimate for T.
row = reshape(img, numel(img), 1);
old_T = row(randi(length(row)-1));
mu1 = mean(img(img>old_T));
mu2 = mean(img(img<=old_T));
new_T = (mu1 + mu2)/2;
disp(old_T);
disp(new_T);
while abs(new_T - old_T) > tolerance
    old_T = new_T;
    mu1 = mean(img(img>old_T));
    mu2 = mean(img(img<=old_T));
    new_T = (mu1 + mu2)/2;
    disp(new_T);
end
    
img = input_img>new_T;

if display_hist
    subplot(1, 2, 1);
    imshow(img);
    title(strcat('Threshold at Convergence: ', num2str(new_T)));
    subplot(1, 2, 2);
    [counts, binary_level] = imhist(img, 2);
    bar(binary_level, counts, 'BarWidth', 1);
    if hist_eq
        suptitle('With Histogram Equalization');
    else
        suptitle('Without Histogram Equalization');
    end
else
    imshow(img);
    title(strcat('Threshold at Convergence: ', num2str(new_T)));
    if hist_eq
        suptitle('With Histogram Equalization');
    else
        suptitle('Without Histogram Equalization');
    end
end

end


