IM = imread('dataset/real/EDF000', 'png');
%figure, imshow(IM);

r = 4; % Larger values increase size of superpixels by including pixels of greater distance
v = 4; % Larger values increase size of superpixels by including pixels of greater intenisty difference
iter = 50; % Number of iterations of meanshift run

IM_MS = naivemeans(IM, r, v, iter);
%figure, imshow(IM_MS);
%imwrite(IM_MS, "meanshift.png", "png");

Canny = edge(IM_MS, 'Canny');
%figure, imshow(Canny);
%imwrite(Canny, "canny.png", "png");
