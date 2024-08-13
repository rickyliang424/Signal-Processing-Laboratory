%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script tests your implementation of seamCarving function, and you can 
% also use it for resizing your own images.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clear all
clear; close all; clc;

%% Load data
image = imread('../data/sea.jpg');
sz = size(image);
% resize image to one-third size
image = imresize(image, [floor(sz(1)/3), floor(sz(2)/3)]);
sz = size(image);
figure();
imshow(image)

%% Image resizing
% apply scaling 
image_scaling_width = imresize(image, [sz(1), floor(sz(2)/2)]);
figure();
imshow(image_scaling_width);

% apply cropping 
image_crop_width = imcrop(image, [1, 1, floor(sz(2)/2), sz(1)]);  %[xmin ymin width height]
figure();
imshow(image_crop_width);

% apply seam carving reduce
image_seamCarving_reduce = seamCarvingReduce(double(image), floor(sz(2)/2));
figure();
imshow(uint8(image_seamCarving_reduce));
% imwrite(uint8(image_seamCarving_reduce), '../results/seamCarving_reduce.jpg');

% apply seam carving insert
image_seamCarving_insert = seamCarvingInsert(double(image), floor(sz(2)/4));
figure();
imshow(uint8(image_seamCarving_insert));
% imwrite(uint8(image_seamCarving_insert), '../results/seamCarving_insert.jpg');
