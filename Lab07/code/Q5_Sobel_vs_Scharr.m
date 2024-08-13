clear; clc;

frame = imread('../data/Im.jpg');
sigma = 2;
n_x_sigma = 6;
alpha = 0.04;
threshold = 20;
r = 6;
filter_size = 2 * n_x_sigma * sigma;
g = fspecial('gaussian', max(1, fix(filter_size)), sigma);

%% Sobel
sobel_x = [1 0 -1; 2 0 -2; 1 0 -1];
sobel_y = sobel_x';
[I1, r1, c1, count1] = FindCorners(frame, sobel_x, sobel_y, g, threshold, r, alpha);
figure();
imagesc(uint8(I1));
hold on;
plot(c1, r1, 'or', 'MarkerSize', 5, 'LineWidth', 1);

%% Scharr
scharr_x = [3 0 -3; 10 0 -10; 3 0 -3];
scharr_y = scharr_x';
[I2, r2, c2, count2] = FindCorners(frame, scharr_x, scharr_y, g, threshold, r, alpha);
figure();
imagesc(uint8(I2));
hold on;
plot(c2, r2, 'or', 'MarkerSize', 5, 'LineWidth', 1);
