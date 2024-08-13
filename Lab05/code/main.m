close all; clear; clc;

%% read image
filename = '../data/image.jpg';
I = imread(filename);
figure('name', 'source image');
imshow(I);

%% call functions
% output = function(input1, input2, ...);

% grayscale function
I2 = grayscale(I);

% flip function
I3 = my_flip(I,0);

% rotation function
I4 = rotation(I, pi/6);

% resize function
I5 = resize(I, 0.6);

% shear transformation
I6 = shear(I, -0.8, 0.2);

%% show image
figure('name', 'grayscale image'),
imshow(I2);

figure('name', 'flipped image'),
imshow(I3);

figure('name', 'rotated image'),
imshow(I4);

figure('name', 'resized image'),
imshow(I5);

figure('name', 'shear image'),
imshow(I6);

%% write image
% save image for your report

% filename2 = '../results/gray_image.jpg';
% imwrite(I2, filename2);

% filename3 = '../results/flip_image_0.jpg';
% imwrite(I3, filename3);

% filename4 = '../results/rotated_image.jpg';
% imwrite(I4, filename4);

% filename5 = '../results/resized_image.jpg';
% imwrite(I5, filename5);

% filename6 = '../results/shear_image.jpg';
% imwrite(I6, filename6);
