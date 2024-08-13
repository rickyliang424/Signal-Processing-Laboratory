close all; clear; clc;

name = "einstein";
image = im2single(imread('../data/' + name + '.bmp'));
figure(1); imshow(image);

%% Gaussian filter
cutoff_frequency = 2;
size = cutoff_frequency*4+1;
gaussian_filter = fspecial('Gaussian', size, cutoff_frequency);
image1 = my_imfilter(image, gaussian_filter);
figure(2); imshow(image1);
% imwrite(image1, name + '_gaussian.jpg', 'quality', 95);

%% Box filter
box_filter = ones(size,size) / (size*size);
image2 = my_imfilter(image, box_filter);
figure(3); imshow(image2);
% imwrite(image2, name + '_box.jpg', 'quality', 95);
