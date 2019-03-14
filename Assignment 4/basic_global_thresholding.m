function basic_global_thresholding(img, tolerance, display_img_hist, hist_eq, display_binary_count_hist)
if nargin < 3
    display_binary_count_hist = false;
    display_img_hist = false;
    hist_eq = false;
end

if nargin < 4
    display_binary_count_hist = false;
    hist_eq = false;
end

if nargin < 5
    display_binary_count_hist = false;
end

if hist_eq
    input_img = histeq(img);
    img = histeq(img);
else
    input_img = img;
end

% Randomly select an initial estimate for T.
row = reshape(img, numel(img), 1);
new_T = double(row(randi(length(row) - 1)));
old_T = double(0);

% Avoid divide by 0 case
if new_T == 255
    new_T = new_T - 1;
elseif new_T == 0
    new_T = new_T + 1;
end

mu1 = mean(img(img > new_T));
mu2 = mean(img(img <= new_T));

while abs(new_T - old_T) > tolerance
    disp(new_T);
    old_T = new_T;
    new_T = (mu1 + mu2) / 2;
    mu1 = mean(img(img > new_T));
    mu2 = mean(img(img <= new_T));
end

disp(new_T);
    
img = input_img > new_T;

% Plotting according to different arguments
% 
% Plot the thresholded images
% Plot the image histogram with a read vertical specifies the threshold
% value
% Plot the histogram of the number binary values

num_img = 1;
if display_binary_count_hist
    num_img = num_img + 1;
end
if display_img_hist
    num_img = num_img + 1;
    subplot(1, num_img, 1);
    imshow(img);
    title(strcat('Threshold at Convergence: ', num2str(new_T)), 'FontSize', 7);
    subplot(1, num_img, 2);
    imhist(input_img);
    hold on;
    line([new_T, new_T], ylim, 'LineWidth', 1, 'Color', 'r');
else
    subplot(1, num_img, 1);
    imshow(img);
    title(strcat('Threshold at Convergence: ', num2str(new_T)), 'FontSize', 12);
end

if display_binary_count_hist
    subplot(1, num_img, num_img);
    [counts, binary_level] = imhist(img, 2);
    bar(binary_level, counts, 'BarWidth', 1);
end
    
if hist_eq
    suptitle('With Histogram Equalization');
else
    suptitle('Without Histogram Equalization');
end

end


