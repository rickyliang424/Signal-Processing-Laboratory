clear; clc;

frame = imread('../data/Im.jpg');
sigma = 2;
n_x_sigma = 6;
alpha = 0.04;
threshold = 20;
r = 6;
dx = [-1 0 1; -1 0 1; -1 0 1];
dy = dx';
filter_size = 2 * n_x_sigma * sigma;

%% Rectangular
g1 = ones(filter_size);
[I1, r1, c1, count1] = FindCorners(frame, dx, dy, g1, threshold, r, alpha);
figure();
imagesc(uint8(I1));
hold on;
plot(c1, r1, 'or', 'MarkerSize', 5, 'LineWidth', 1);

%% Gaussian
g2 = fspecial('gaussian', max(1, fix(filter_size)), sigma);
[I2, r2, c2, count2] = FindCorners(frame, dx, dy, g2, threshold, r, alpha);
figure();
imagesc(uint8(I2));
hold on;
plot(c2, r2, 'or', 'MarkerSize', 5, 'LineWidth', 1);
