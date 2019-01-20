function bitresolution(name, power)
subplot(1, 2, 1);
% input image is 8-bit grey scale
A = imread(name);
imshow(A);
% double-check the input image is 8-bit gray scale by finding the 
% the max and min of grey value
% [MAX,INDEX] = max(A(:));
% [MIN,INDEX] = min(A(:));
title('Input');
subplot(1, 2, 2);
% lower intensity resolution by powers of 2 (power = 3, 4, 5)
B = round(A / (2^power));
% double-check the image is (8-power)-bit by find the 
% the max and min of grey value
% [MAX,INDEX] = max(B(:))
% [MIN,INDEX] = min(B(:))
% specify the display range by subtract power from 8
imshow(B, [0, 2^(8 - power)]);
title('Output');
end