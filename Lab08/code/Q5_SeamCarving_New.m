clear; close all; clc;

image = imread('../data/Q3.jpg');
sz = size(image);
resize = 1/3;
image = imresize(image, [floor(sz(1)*resize), floor(sz(2)*resize)]);
sz = size(image);
figure();
imshow(image);

insert = 1/4;

%% apply seam carving insert (old)
image_SeamCarving_old = seamCarvingInsert(double(image), floor(sz(2)*insert));
figure();
imshow(uint8(image_SeamCarving_old));
imwrite(uint8(image_SeamCarving_old), '../results/Q5_SeamCarving_old.jpg');

%% apply seam carving insert (new)
image_SeamCarving_new = Q5_seamCarvingInsert(double(image), floor(sz(2)*insert));
figure();
imshow(uint8(image_SeamCarving_new));
imwrite(uint8(image_SeamCarving_new), '../results/Q5_SeamCarving_new.jpg');
