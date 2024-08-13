clear; close all; clc;

file = "Q2_2";
image = imread('../data/' + file + '.jpg');
sz = size(image);
resize = 1/5;
image = imresize(image, [floor(sz(1)*resize), floor(sz(2)*resize)]);
sz = size(image);
figure();
imshow(image)

%% apply seam carving reduce
reduce = 1/3;
image_SeamCarving_reduce = seamCarvingReduce(double(image), floor(sz(2)*reduce));
figure();
imshow(uint8(image_SeamCarving_reduce));
% imwrite(uint8(image_SeamCarving_reduce), '../results/' + file + '_SeamCarving_reduce.jpg');

%% apply seam carving insert
insert = 1/4;
image_SeamCarving_insert = seamCarvingInsert(double(image), floor(sz(2)*insert));
figure();
imshow(uint8(image_SeamCarving_insert));
% imwrite(uint8(image_SeamCarving_insert), '../results/' + file + '_SeamCarving_insert.jpg');
