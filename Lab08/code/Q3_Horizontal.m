clear; close all; clc;

image = imread('../data/Q3.jpg');
sz = size(image);
resize = 1/3;
image = imresize(image, [floor(sz(1)*resize), floor(sz(2)*resize)]);
image_rt = imrotate(image, 90);
sz = size(image_rt);
figure();
imshow(image);

%% apply scaling
scaling = 3/4;
image_scaling_height = imresize(image_rt, [sz(1), floor(sz(2)*scaling)]);
image_scaling_height = imrotate(image_scaling_height, -90);
figure();
imshow(image_scaling_height);
imwrite(uint8(image_scaling_height), '../results/Q3_Scaling.jpg');

%% apply cropping
cropping = 3/4;
image_crop_height = imcrop(image_rt, [1, 1, floor(sz(2)*cropping), sz(1)]);
image_crop_height = imrotate(image_crop_height, -90);
figure();
imshow(image_crop_height);
imwrite(uint8(image_crop_height), '../results/Q3_Cropping.jpg');

%% apply seam carving reduce
reduce = 1/4;
image_seamCarving_reduce = seamCarvingReduce(double(image_rt), floor(sz(2)*reduce));
image_seamCarving_reduce = imrotate(image_seamCarving_reduce, -90);
figure();
imshow(uint8(image_seamCarving_reduce));
imwrite(uint8(image_seamCarving_reduce), '../results/Q3_SeamCarvingReduce.jpg');

%% apply seam carving insert
insert = 1/4;
image_seamCarving_insert = seamCarvingInsert(double(image_rt), floor(sz(2)*insert));
image_seamCarving_insert = imrotate(image_seamCarving_insert, -90);
figure();
imshow(uint8(image_seamCarving_insert));
imwrite(uint8(image_seamCarving_insert), '../results/Q3_SeamCarvingInsert.jpg');
