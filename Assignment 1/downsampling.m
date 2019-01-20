function downsampling(name, rate)
% display the input image in the left
subplot(1, 2, 1);
A = imread(name);
imshow(A);
title('Input');
% obtain the size of input image
dimA = size(A);
% display the output image in the right
subplot(1, 2, 2);
% matrix indexing with step 'rate'
B = A(1:rate:dimA(1), 1:rate:dimA(2));
imshow(B);
title('Output');
end